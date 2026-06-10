# Decision & Implementation Note: 3D Vessel Viewer & Project Reorganization

## 1. 3D Vessel Viewer Design
To achieve a live wireframe visualization similar to the `VesselViewer` mod, we implemented a custom offline 3D wireframe rendering pipeline:
- **Challenge**: Scanning part bounding boxes (`part:bounds`) in kOS causes a physical physics tick delay per part. Rescanning on every staging event causes unacceptable script freeze (e.g., ~1 second for 50 parts).
- **Solution**: 
  - **One-time scan**: Run `DASA/VesselScan.ks` exactly once at launch (PRELAUNCH stage) to export a complete structural blueprint (`telemetry/vessel_structure.json`) containing part coordinates relative to the ship facing vector, parent connections, and bounding box dimensions.
  - **Real-time UID tracking**: The normal 1-second telemetry loop in `DASA/minmus_mission.ks` broadcasts only the array of currently attached part UIDs. 
  - **Visualizer Diffing**: The dashboard UI compares the active UID list with the initial structure, dynamically stripping any staged or destroyed parts from the visualizer.
  - **Attitude Basis**: Pitch/yaw/roll from `ship:facing` are Euler angles relative to KSP raw coordinates. To show the vessel rotating relative to the ground, we calculate the projection of `forevector` and `topvector` onto the local **East-North-Up (ENU) horizon frame** basis.
  - **Smooth Interpolation**: The visualizer interpolates the attitude vectors at 60 FPS using `requestAnimationFrame`, keeping the movement fluid despite the 1-second telemetry update rate.
  - **Dual Modes**: Supports **Attitude 3D** (with perspective projection and a ground plane grid) and **Blueprint** (static orthographic projection).

## 2. Directory Reorganization
To scale the codebase, the root directory was reorganized:
- **`dashboard/`**: Contains `telemetry_dashboard.html`.
- **`logs/`**: Holds `log.txt` (mission events) and `mission_history.log` (CSV data).
- **`telemetry/`**: Stores `telemetry.json` (live data) and `vessel_structure.json` (static structure).
- **`DASA/`**: Holds main mission scripts (`minmus_mission.ks`, `VesselScan.ks`).
- **`SpaceCore/`**: Core space autopilot libraries (untouched by telemetry-specific files).

All references in scripts, the Express Node server, and the PowerShell server (`start_telemetry_server.ps1`) have been updated to map to these new relative folders.
