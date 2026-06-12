#Requires -Version 5.1
<#
.SYNOPSIS
    Watches a KSP log file for kOS errors and emits structured NDJSON events to stdout.

.DESCRIPTION
    Scans or continuously tails KSP.log for lines that involve kOS and contain an
    error/exception indicator.  Each detected error is written as a self-contained
    JSON object on its own line (NDJSON), making it easy for an AI agent or any
    downstream process to consume, parse, and act on each event independently.

    Event types emitted:
        started      – script initialised successfully
        heartbeat    – periodic liveness ping (watch mode only)
        kos_error    – a kOS-related error or exception was detected
        script_error – the watcher itself encountered an unhandled exception
        stopped      – script is exiting (includes final error count)

.PARAMETER LogPath
    Full path to KSP.log.  Defaults to the standard Steam install location.

.PARAMETER TailLines
    Number of lines from the END of the file to process on startup (default 200).
    Increase this when investigating a crash that happened earlier in the session.

.PARAMETER ContextLines
    How many lines immediately preceding an error to include as context (default 5).

.PARAMETER StackLines
    Maximum number of stack-trace continuation lines to capture after an [EXC] entry
    (default 20).

.PARAMETER HeartbeatSec
    In watch mode, emit a heartbeat event every N seconds so the agent knows the
    script is still alive.  Set to 0 to disable (default 30).

.PARAMETER DedupeWindow
    Number of recent unique error fingerprints to remember.  Errors whose message
    hash matches a recent entry are silently suppressed to avoid event floods
    (default 50).

.PARAMETER Watch
    If specified, keep tailing the file for new content after the initial scan
    (equivalent to  tail -f  on Unix).  Without this flag the script exits after
    processing the last TailLines lines.

.EXAMPLE
    # One-shot scan of the last 500 lines, pretty-print with jq:
    .\watch_kos_errors.ps1 -TailLines 500 | jq .

.EXAMPLE
    # Continuously watch and pipe JSON events to an agent process:
    .\watch_kos_errors.ps1 -Watch -HeartbeatSec 15 | agent.exe --stdin-json

.EXAMPLE
    # Custom log location + watch:
    .\watch_kos_errors.ps1 -LogPath "D:\KSP\KSP.log" -Watch
#>

param (
    [string] $LogPath      = "C:\Program Files (x86)\Steam\steamapps\common\Kerbal Space Program\KSP.log",
    [int]    $TailLines    = 200,
    [int]    $ContextLines = 5,
    [int]    $StackLines   = 20,
    [int]    $HeartbeatSec = 30,
    [int]    $DedupeWindow = 50,
    [switch] $Watch
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Compiled regexes (compiled once for the entire run – important for huge logs)
# ---------------------------------------------------------------------------

# KSP log line format:  [TAG HH:MM:SS.mmm] rest-of-message
$RE_KSP_LINE  = [regex]::new(
    '^\[(?<tag>[A-Z]{3})\s+(?<ts>[\d:.]+)\]\s*(?<msg>.*)$',
    [System.Text.RegularExpressions.RegexOptions]::Compiled
)

# A line is "kOS-related" when it explicitly names the kOS mod or its assemblies.
# \b word-boundaries prevent false matches like "cos", "akos", etc.
$RE_KOS       = [regex]::new(
    '(?i)\bkOS\b|kos\.|KOSException|KOSScript|kos:',
    [System.Text.RegularExpressions.RegexOptions]::Compiled -bor
    [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
)

# Signals an error condition on the line
$RE_ERROR     = [regex]::new(
    '(?i)\b(error|nre)\b|exception' +
    '|\[ERR\b|\[EXC\b' +
    '|NullReference|IndexOutOfRange|InvalidOperation' +
    '|ArgumentException|UnityException|KeyNotFoundException' +
    '|StackOverflow|OutOfMemory',
    [System.Text.RegularExpressions.RegexOptions]::Compiled -bor
    [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
)

# Stack-trace continuation lines (no KSP tag at the start, plus kOS code fragments)
$RE_STACK     = [regex]::new(
    '^  at |^\s+at |^\s+---\s|^UnityEngine\.|^System\.|^kOS\.|^\[LOG.*?\] Code Fragment|^File\s+Line:Col|^====|^[a-zA-Z0-9_]+:/',
    [System.Text.RegularExpressions.RegexOptions]::Compiled
)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

# Reusable SHA-256 instance (allocated once, disposed in finally)
$SHA256 = [System.Security.Cryptography.SHA256]::Create()

function Get-MessageHash([string]$text) {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($text)
    $hash  = $SHA256.ComputeHash($bytes)
    [Convert]::ToBase64String($hash).Substring(0, 16)
}

function Get-Severity([string]$tag) {
    switch ($tag) {
        'EXC'   { return 'exception' }
        'ERR'   { return 'error'     }
        'WRN'   { return 'warning'   }
        default { return 'info'      }
    }
}

# Emit a single NDJSON line to stdout — the agent reads these one by one
function Emit([hashtable]$obj) {
    $obj | ConvertTo-Json -Compress -Depth 6 | Write-Output
}

# ---------------------------------------------------------------------------
# Pre-flight checks
# ---------------------------------------------------------------------------

if (-not (Test-Path -LiteralPath $LogPath)) {
    # Even fatal errors go out as NDJSON so the agent can parse them uniformly
    Emit @{
        event   = 'fatal'
        at      = (Get-Date -Format 'o')
        message = "KSP.log not found at the specified path."
        path    = $LogPath
    }
    exit 1
}

# ---------------------------------------------------------------------------
# Runtime state
# ---------------------------------------------------------------------------

$errorCount    = 0

# Rolling pre-error context window (keeps last ContextLines+1 raw lines)
$contextBuf    = [System.Collections.Generic.Queue[string]]::new()

# Deduplication: O(1) lookup via HashSet, eviction order via Queue
$dedupeSet     = [System.Collections.Generic.HashSet[string]]::new()
$dedupeOrder   = [System.Collections.Generic.Queue[string]]::new()

$lastHeartbeat = [datetime]::UtcNow

# Stack-trace capture state
$inStack       = $false
[string[]]$stackCapture = @()
$pendingEvent  = $null      # event being held until we know if there's a stack

# ---------------------------------------------------------------------------
# Main stream
# ---------------------------------------------------------------------------

Emit @{
    event      = 'started'
    at         = (Get-Date -Format 'o')
    log_path   = $LogPath
    watch_mode = $Watch.IsPresent
    tail_lines = $TailLines
}

$gcParams = @{ Path = $LogPath; Tail = $TailLines }
if ($Watch) { $gcParams['Wait'] = $true }

try {
    Get-Content @gcParams | ForEach-Object {
        $raw = [string]$_

        # ── Heartbeat (watch mode only) ────────────────────────────────────
        if ($Watch -and $HeartbeatSec -gt 0) {
            $now = [datetime]::UtcNow
            if (($now - $lastHeartbeat).TotalSeconds -ge $HeartbeatSec) {
                Emit @{
                    event        = 'heartbeat'
                    at           = $now.ToString('o')
                    errors_so_far = $errorCount
                }
                $lastHeartbeat = $now
            }
        }

        # ── Stack-trace continuation ───────────────────────────────────────
        if ($inStack) {
            if ($RE_STACK.IsMatch($raw) -and $stackCapture.Count -lt $StackLines) {
                $stackCapture += $raw.Trim()
                return   # keep accumulating; 'return' = next pipeline item
            }

            # Stack is done — flush the pending event and fall through
            $pendingEvent['stack_trace'] = $stackCapture
            Emit $pendingEvent
            $inStack      = $false
            $stackCapture = @()
            $pendingEvent = $null
            # continue processing $raw below as a normal line
        }

        # ── Rolling pre-error context buffer ──────────────────────────────
        $contextBuf.Enqueue($raw)
        if ($contextBuf.Count -gt ($ContextLines + 1)) {
            [void] $contextBuf.Dequeue()
        }

        # ── Filter: must be kOS-related AND contain an error indicator ─────
        if (-not ($RE_KOS.IsMatch($raw) -and $RE_ERROR.IsMatch($raw))) { return }

        # ── Parse KSP log format ───────────────────────────────────────────
        $m   = $RE_KSP_LINE.Match($raw)
        $tag = if ($m.Success) { $m.Groups['tag'].Value } else { 'UNK' }
        $ts  = if ($m.Success) { $m.Groups['ts'].Value  } else { ''    }
        $msg = if ($m.Success) { $m.Groups['msg'].Value } else { $raw  }

        # ── Deduplication ─────────────────────────────────────────────────
        $hash = Get-MessageHash $msg
        if ($dedupeSet.Contains($hash)) { return }

        [void] $dedupeSet.Add($hash)
        $dedupeOrder.Enqueue($hash)
        if ($dedupeOrder.Count -gt $DedupeWindow) {
            $evicted = $dedupeOrder.Dequeue()
            [void] $dedupeSet.Remove($evicted)
        }

        $errorCount++

        # Context = lines immediately before this one (excludes current line)
        $ctx = @($contextBuf.ToArray() | Select-Object -SkipLast 1)

        $pendingEvent = [ordered]@{
            event       = 'kos_error'
            index       = $errorCount
            at          = (Get-Date -Format 'o')
            severity    = (Get-Severity $tag)
            ksp_tag     = $tag
            ksp_time    = $ts
            message     = $msg
            context     = $ctx
            stack_trace = @()       # filled in if [EXC] follows with stack frames
            raw_line    = $raw
        }

        # Always hold the event to check for following stack trace or code fragment lines
        $inStack = $true
        # Don't emit yet; wait for stack continuation lines
    }

    # EOF (one-shot mode) — flush any pending stack event
    if ($inStack -and $null -ne $pendingEvent) {
        $pendingEvent['stack_trace'] = $stackCapture
        Emit $pendingEvent
    }

} catch {
    Emit @{
        event   = 'script_error'
        at      = (Get-Date -Format 'o')
        message = $_.Exception.Message
        source  = $_.InvocationInfo.PositionMessage
    }
    exit 1
} finally {
    $SHA256.Dispose()
    Emit @{
        event        = 'stopped'
        at           = (Get-Date -Format 'o')
        total_errors = $errorCount
    }
}
