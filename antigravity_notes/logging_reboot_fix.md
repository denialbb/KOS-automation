# Logging Behavior on CPU Reboot Fix

## Problem
During the flight of automated probes, the kOS computer may reboot due to power loss, quickloads, or other execution interrupts. 
Currently, at the beginning of the main mission script `0:/DASA/minmus_mission.ks`, the log files `0:/logs/log.txt` and `0:/logs/mission_history.log` are deleted:
```kerboscript
IF exists("0:/logs/mission_history.log") {
    deletepath("0:/logs/mission_history.log").
}
IF exists("0:/logs/log.txt") {
    deletepath("0:/logs/log.txt").
}
```
As a result, any reboot during flight wipes the entire log history, preventing persistent logging across the entire mission lifecycle.

## Solution
1. **Conditional Deletion:** Only delete the log files when the mission is initialized fresh. We can detect this by checking if the vessel's status is `PRELAUNCH` (meaning it is still on the launchpad/runway before taking off).
2. **Style Guide Compliance:** Convert lowercase built-in functions (`exists`, `deletepath`, `open`) to ALL CAPS (`EXISTS`, `DELETEPATH`, `OPEN`, `READALL`) across modified files to adhere to our capitalization standard.
3. **Log Path Standardization:** Correct the path of `mission_history.log` in fallback autopilot scripts (`SpaceCore/Ascent.ks` and `SpaceCore/CircToAp.ks`) to log to `0:/logs/mission_history.log` instead of `0:/mission_history.log`.

## Files to Modify
- `0:/DASA/minmus_mission.ks` - Add `SHIP:STATUS = "PRELAUNCH"` check before deleting old log files and capitalize functions.
- `0:/DASA/utils/logging.ks` - Capitalize built-in functions and suffixes (`EXISTS`, `OPEN`, `READALL`, `DELETEPATH`).
- `0:/DASA/utils/telemetry.ks` - Capitalize built-in functions (`EXISTS`, `DELETEPATH`).
- `0:/DASA/VesselScan.ks` - Capitalize built-in functions (`EXISTS`, `DELETEPATH`).
- `0:/DASA/phases/boot.ks` - Capitalize `EXISTS`.
- `0:/boot/probe_boot.ks` - Capitalize `EXISTS`.
- `0:/SpaceCore/Ascent.ks` - Update log path to `0:/logs/mission_history.log` and capitalize `EXISTS`.
- `0:/SpaceCore/CircToAp.ks` - Update log path to `0:/logs/mission_history.log` and capitalize `EXISTS`.
