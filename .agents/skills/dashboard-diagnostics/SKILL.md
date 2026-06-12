---
name: dashboard-diagnostics
description: >-
  Launches the KSP Telemetry Server, runs a headless Puppeteer browser to verify page loading, listens to console errors and unhandled exceptions for 20 seconds, captures a timestamped screenshot, and shuts down the server.
---

# Dashboard Diagnostics

## Overview
This skill allows the agent to start the telemetry server and run a comprehensive browser-based diagnostic check on the telemetry dashboard. It listens for unhandled javascript exceptions, console errors, and network load failures while capturing screenshots to verify the visual state.

## Dependencies
- Node.js (installed)
- Puppeteer (automatically installed on first run)

## Quick Start
Run the diagnostic script inside the workspace:
```bash
node telemetry_server/diagnose_dashboard.js
```

## Utility Scripts
This script is a self-contained diagnostic suite.

### Running Diagnostics
Command:
```powershell
node telemetry_server/diagnose_dashboard.js
```
Expected output on success:
```text
==================================================
   DASA Telemetry Dashboard Diagnostics Tool
==================================================
[OK] Port 8080 is free.
[OK] Puppeteer is already installed.
[INFO] Spawning telemetry server...
[Server stdout] DASA Telemetry Server running!
[Server stdout] Open http://localhost:8080/ in your browser to view the Mission Control dashboard.
[Server stdout] Press Ctrl+C to stop the server.
[OK] Telemetry server is up and listening.
[INFO] Launching headless browser...
[Browser INFO] Navigating to dashboard...
[Browser OK] Navigation complete.
[INFO] Listening to dashboard for 20 seconds. Please feed telemetry from KSP if active...
[OK] Screenshot captured and saved to: .../dashboard/.temp_diagnostics/screenshot-2026-06-10T20-30-00-000Z.png
[INFO] Browser closed.
[INFO] Terminating telemetry server...

==================================================
              DIAGNOSTIC SUMMARY REPORT
==================================================
Fatal Javascript Exceptions: 0
Network Load Failures:      0
Console Errors:             0
Console Warnings:           0
--------------------------------------------------
[RESULT] Troubleshooting finished. NO ERRORS FOUND!
```

## Rate Limiting
Not applicable (runs locally on port 8080).

## Common Mistakes
1. **Port Occupied:** If the port is already in use, the script will exit with code 1. Make sure to close any other processes using port 8080.
2. **First-Run Timeout:** On the very first run, npm may take up to 30-60 seconds to download Chromium and Puppeteer. Ensure the machine has internet access on first execution.
