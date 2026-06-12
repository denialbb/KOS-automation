---
name: kos-debug
description: >-
  Automates the process of checking KerboScript execution logs, identifying issues, resolving syntax/runtime errors, and updating debugging documentation.
---

# kOS Log Debugger & Error Resolver

## Overview
This local instruction-only skill directs the agent on how to diagnose and resolve compiler or runtime errors in Kerbal Space Program's kOS (KerboScript) scripts. It establishes a standard workflow for log extraction, telemetry fallback, error resolution, and documenting findings.

## Dependencies
*   No external skill dependencies.
*   Uses local reference files:
    *   [debugging_lessons.md](file:///c:/Program%20Files%20%28x86%29/Steam/steamapps/common/Kerbal%20Space%20Program/Ships/Script/gemini_notes/debugging_lessons.md)
    *   [ksp_wiki_minmus.md](file:///c:/Program%20Files%20%28x86%29/Steam/steamapps/common/Kerbal%20Space%20Program/Ships/Script/gemini_notes/ksp_wiki_minmus.md) (and other celestial wiki reference sheets)

## Quick Start
To trigger this skill, the user can prompt:
> *"Use the `kos-debug` skill to check the log, find the crash reason, and resolve the code issue."*

## Workflow

### 1. Retrieve the Log Entries
*   **Mandatory Log Parser:** You MUST always use `watch_kos_errors.py` to inspect the main Unity log (`KSP.log`). Do NOT read the raw file directly or use simple PowerShell/Select-String commands.
*   To extract recent errors from the tail end of the log, execute:
    `python watch_kos_errors.py --tail-lines 200`
*   To scan the entire log file from the beginning (useful if the crash happened earlier):
    `python watch_kos_errors.py --extract-all`
*   To stream log updates in real-time during execution/debugging, use:
    `python watch_kos_errors.py --watch`

### 2. Telemetry Fallback
*   If `KSP.log` has no new kOS entries (due to file locking or delayed writes), read the local mission logs:
    *   `0:/telemetry.json` (Structured JSON status)
    *   `0:/log.txt` (Mission milestones)
*   If the issue remains unclear, ask the user for clarification.

### 3. Diagnose the Issue
*   Compare the error message and line number from the log with the syntax rules in [debugging_lessons.md](file:///c:/Program%20Files%20%28x86%29/Steam/steamapps/common/Kerbal%20Space%20Program/Ships/Script/gemini_notes/debugging_lessons.md):
    *   **Double Quotes:** Ensure no single quotes (`'`) are used for strings.
    *   **No Escaping:** Ensure no backslashes (`\"`) are used. Use `char(34)` or doubled double-quotes (`""`) instead.
    *   **Variable Scope:** Ensure variables are declared using `local` or `global` before assignment if `@lazyGlobal off` is active.
    *   **Clobbering:** Ensure variables do not clobber built-in keywords (e.g. `processor`, `target`, `body`).

### 4. Resolve the Bugs
*   Edit the target `.ks` script using code replace tools to implement the fixes.

### 5. Document & Report
*   If a new syntax rule or kOS limitation was discovered, add it to [debugging_lessons.md](file:///c:/Program%20Files%20%28x86%29/Steam/steamapps/common/Kerbal%20Space%20Program/Ships/Script/gemini_notes/debugging_lessons.md).
*   Provide the user with a summary of:
    1.  The error message identified.
    2.  The files and lines changed.
    3.  A summary of the fix.

## Common Mistakes
*   **Bypassing the python log watcher:** Reading `KSP.log` directly or scanning it without `watch_kos_errors.py` is inefficient and error-prone. Always run the script.
*   **Using backslashes for escaping double quotes:** This will break kOS compilation. Always construct JSON strings using a `local q is char(34).` helper.
*   **Ignoring celestial/terrain safety altitudes:** Mountains on Minmus reach over $5.7 \text{ km}$ high. Always cross-reference orbits with KSP Wiki parameters to ensure orbital altitudes are safely above the terrain peaks.
