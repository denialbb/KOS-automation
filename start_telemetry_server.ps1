$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8080/")
$listener.Start()
Write-Host "DASA Telemetry Server running!"
Write-Host "Open http://localhost:8080/ in your browser to view the Mission Control dashboard."
Write-Host "Press Ctrl+C to stop the server."

$global:wasConnected = $true
$global:lastKnownTime = 0

function Format-Time($t) {
    $hours = [math]::Floor($t / 3600)
    $mins = [math]::Floor(($t % 3600) / 60)
    $secs = [math]::Floor($t % 60)
    return "[T+ {0:D2}:{1:D2}:{2:D2}]" -f $hours, $mins, $secs
}

function Log-Event($message) {
    $logPath = "logs/log.txt"
    try {
        Add-Content -Path $logPath -Value $message
    } catch {
        Write-Host "Failed to write log: $_"
    }
}

while ($listener.IsListening) {
    try {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        try {
            if ($request.Url.LocalPath -eq "/") {
                $content = Get-Content -Path "dashboard/telemetry_dashboard.html" -Raw
                $buffer = [System.Text.Encoding]::UTF8.GetBytes($content)
                $response.ContentType = "text/html"
                $response.Headers.Add("Cache-Control", "no-store, no-cache, must-revalidate")
                $response.Headers.Add("Pragma", "no-cache")
                $response.Headers.Add("Expires", "0")
                $response.ContentLength64 = $buffer.Length
                $response.OutputStream.Write($buffer, 0, $buffer.Length)
            } elseif ($request.Url.LocalPath -eq "/favicon.ico") {
                $response.StatusCode = 204
            } elseif ($request.Url.LocalPath -eq "/telemetry.json") {
                $content = "{`"signalLost`": true}"
                try {
                    if (Test-Path "telemetry/telemetry.json") {
                        # Use FileShare safe read to avoid lock violations on Windows
                        $fileStream = New-Object System.IO.FileStream("telemetry/telemetry.json", [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
                        $reader = New-Object System.IO.StreamReader($fileStream)
                        $rawContent = $reader.ReadToEnd()
                        $reader.Close()
                        $fileStream.Close()

                        $fileItem = Get-Item "telemetry/telemetry.json"
                        $age = (Get-Date) - $fileItem.LastWriteTime
                        if ($age.TotalSeconds -gt 3.0) {
                            if ($global:wasConnected) {
                                $global:wasConnected = $false
                                Log-Event "$(Format-Time $global:lastKnownTime) SIGNAL LOST: Connection to KOS computer lost."
                            }
                            $data = ConvertFrom-Json $rawContent
                            if ($data -ne $null) {
                                $data | Add-Member -MemberType NoteProperty -Name "signalLost" -Value $true -Force
                                $content = ConvertTo-Json $data
                            } else {
                                $content = "{`"signalLost`": true}"
                            }
                        } else {
                            $data = ConvertFrom-Json $rawContent
                            if ($data -ne $null -and $data.time -ne $null) {
                                $global:lastKnownTime = $data.time
                            }
                            if (-not $global:wasConnected) {
                                $global:wasConnected = $true
                                Log-Event "$(Format-Time $global:lastKnownTime) Signal restored. Reconnected to KOS computer."
                            }
                            $content = $rawContent
                        }
                    }
                } catch {
                    $content = "{`"signalLost`": true}"
                }
                $buffer = [System.Text.Encoding]::UTF8.GetBytes($content)
                $response.ContentType = "application/json"
                $response.Headers.Add("Cache-Control", "no-store, no-cache, must-revalidate")
                $response.Headers.Add("Pragma", "no-cache")
                $response.Headers.Add("Expires", "0")
                $response.ContentLength64 = $buffer.Length
                $response.OutputStream.Write($buffer, 0, $buffer.Length)
            } elseif ($request.Url.LocalPath -eq "/vessel_structure.json") {
                if (Test-Path "telemetry/vessel_structure.json") {
                    $content = Get-Content -Path "telemetry/vessel_structure.json" -Raw
                    $buffer = [System.Text.Encoding]::UTF8.GetBytes($content)
                    $response.ContentType = "application/json"
                    $response.Headers.Add("Cache-Control", "no-store, no-cache, must-revalidate")
                    $response.Headers.Add("Pragma", "no-cache")
                    $response.Headers.Add("Expires", "0")
                    $response.ContentLength64 = $buffer.Length
                    $response.OutputStream.Write($buffer, 0, $buffer.Length)
                } else {
                    $buffer = [System.Text.Encoding]::UTF8.GetBytes("{`"parts`": []}")
                    $response.ContentType = "application/json"
                    $response.Headers.Add("Cache-Control", "no-store, no-cache, must-revalidate")
                    $response.Headers.Add("Pragma", "no-cache")
                    $response.Headers.Add("Expires", "0")
                    $response.ContentLength64 = $buffer.Length
                    $response.OutputStream.Write($buffer, 0, $buffer.Length)
                }
            } elseif ($request.Url.LocalPath -eq "/telemetry_dashboard.css") {
                if (Test-Path "dashboard/telemetry_dashboard.css") {
                    $content = Get-Content -Path "dashboard/telemetry_dashboard.css" -Raw
                    $buffer = [System.Text.Encoding]::UTF8.GetBytes($content)
                    $response.ContentType = "text/css"
                    $response.Headers.Add("Cache-Control", "no-store, no-cache, must-revalidate")
                    $response.Headers.Add("Pragma", "no-cache")
                    $response.Headers.Add("Expires", "0")
                    $response.ContentLength64 = $buffer.Length
                    $response.OutputStream.Write($buffer, 0, $buffer.Length)
                } else {
                    $response.StatusCode = 404
                }
            } elseif ($request.Url.LocalPath -eq "/vessel_mesh.json") {
                if (Test-Path "telemetry/vessel_mesh.json") {
                    $content = Get-Content -Path "telemetry/vessel_mesh.json" -Raw
                    $buffer = [System.Text.Encoding]::UTF8.GetBytes($content)
                    $response.ContentType = "application/json"
                    $response.Headers.Add("Cache-Control", "no-store, no-cache, must-revalidate")
                    $response.Headers.Add("Pragma", "no-cache")
                    $response.Headers.Add("Expires", "0")
                    $response.ContentLength64 = $buffer.Length
                    $response.OutputStream.Write($buffer, 0, $buffer.Length)
                } else {
                    $buffer = [System.Text.Encoding]::UTF8.GetBytes("{}")
                    $response.ContentType = "application/json"
                    $response.Headers.Add("Cache-Control", "no-store, no-cache, must-revalidate")
                    $response.Headers.Add("Pragma", "no-cache")
                    $response.Headers.Add("Expires", "0")
                    $response.ContentLength64 = $buffer.Length
                    $response.OutputStream.Write($buffer, 0, $buffer.Length)
                }
            } else {
                $response.StatusCode = 404
            }
        } finally {
            $response.Close()
        }
    } catch {
        # Ignore context errors
    }
}
