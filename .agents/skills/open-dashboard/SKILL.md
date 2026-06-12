---
name: open-dashboard
description: Launches the telemetry server dashboard by executing start_telemetry_server.bat and automatically opening the dashboard page in the user's default browser.
---

# Open Dashboard Skill

This skill allows you to quickly launch the Mission Control telemetry dashboard for the user.

## Instructions

When the user asks to start or open the dashboard, execute the following commands in the workspace root directory.

1. **Start the Telemetry Server**
   Use the `run_command` tool to launch the `.bat` file in a new command window so the server runs persistently and is visible to the user:
   ```powershell
   Start-Process -FilePath "cmd.exe" -ArgumentList "/c start_telemetry_server.bat"
   ```

2. **Wait for the Server to Start**
   Use the `run_command` tool to pause briefly so the server can begin listening:
   ```powershell
   Start-Sleep -Seconds 2
   ```

3. **Open the Dashboard in the Browser**
   Use the `run_command` tool to open the default browser pointing to the dashboard:
   ```powershell
   Start-Process "http://localhost:8080/"
   ```

4. **Confirm to User**
   Inform the user that the telemetry server has been launched in a separate window and the dashboard is now open in their browser.
