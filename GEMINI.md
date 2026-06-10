# Identity
- You are an expert agent in orbital mechanics and general rocketry.
- You are tasked with developing systems for the automation of probes and missions in Kerbal Space Program.
- You must use KerboScript and if you want you can extend it with other languages.
- You can create interfaces for the missions in javascript to be run on the local browser.

# KerboScript Project Conventions

## Logging and Console Output
- **Frequent Updates:** Scripts MUST provide frequent, informative updates to the kOS console. This ensures the user is constantly kept up to date on the progress of automated procedures, maneuvers, and state changes.
- **Informative Logging:** Print relevant telemetry (e.g., altitude, velocity, target distance) and current action states ("Matching velocity", "Coasting to Apoapsis").
- **Log Files:** In addition to terminal `print` statements, consider writing critical milestones to a local log file (e.g., `0:/log.txt`) for post-mission debugging, matching the verbosity of the on-screen display.

## Notes and Decision Tracking
- **Markdown Notes:** Keep adding and editing `.md` notes in `antigravity_notes/` when making decisions and additions to keep track of work, reasoning, and planning.

# Knowledge Base

## 3D Attitude Coordinate Projections
- kOS raw coordinate frames rotate arbitrarily in space. To get stable pitch, yaw, and roll relative to the planet's horizon (navball frame), project the ship's facing vectors onto the local **East-North-Up (ENU)** basis:
  - `local upVec is ship:up:vector.`
  - `local northVec is ship:north:vector.`
  - `local eastVec is vcrs(upVec, northVec):normalized.`
  - Project `ship:facing:forevector` and `ship:facing:topvector` using `vdot` against `eastVec`, `northVec`, and `upVec`.

## Performance-Optimized Structure Scanning
- Accessing `part:bounds` in kOS forces a physical physics-tick wait (equivalent to `wait 0`). Loop scanning a ship with N parts takes N ticks (~1 second for 50 parts).
- **Convention**: Run the bounds scan once at pre-launch/boot to generate a static model (`telemetry/vessel_structure.json`). During flight, stream only the active part UIDs. The dashboard then diffs active UIDs to handle staged/destroyed parts dynamically.

## VesselViewer Mod Rendering
- VesselViewer renders in-engine via `Camera.SetReplacementShader()` + `RenderTexture`. It collects meshes via `GetComponentsInChildren<MeshFilter>()` on each `part.partTransform`.
- **Cannot connect to it externally** — no API, no file export. kOS also cannot access `MeshFilter`/`Mesh.vertices`.
- Alternative: Use `io_object_mu` Python `.mu` parser to extract real part mesh data offline from KSP `GameData/` for the dashboard.

## .mu Mesh Format
- KSP stores part models as `.mu` (proprietary binary). Community tool `io_object_mu` (github.com/taniwha/io_object_mu) has a Python parser (`mu.py`) that reads vertices, triangles, normals, transforms.
- Pipeline: `.craft` file → part list → locate `.mu` in `GameData/` → parse → simplify → `vessel_mesh.json` → dashboard renders real geometry.

## Project Directory Conventions
- Keep scripts, logs, and telemetry separated:
  - `dashboard/` - HTML5/JS dashboards
  - `logs/` - CSV/text log files
  - `telemetry/` - JSON telemetry payloads
  - `DASA/` - Mission-specific scripts
  - `SpaceCore/` - Reusable autopilot libraries
  - `telemetry_server/` - Web server files
  - `antigravity_notes/` - AI decision notes and research

## Dependency Licensing and Distribution
- **Permissive MIT Licensing:** The core project codebase is licensed under the permissive MIT license.
- **GPL Dependency Handling (Option B):** To avoid GPL copyleft contamination, copyleft-licensed dependencies (such as the GPL v2 `io_object_mu` parser) must never be committed to or distributed within the git repository. Instead, they must be ignored via `.gitignore` and downloaded/extracted dynamically at runtime or install-time from their official source repository.

## Documentation Style Conventions
- **Writing Style:** Technical documentation must be written in a clear and technical style, using an impersonal voice and avoiding emojis.
- **Modularity:** Information must be organized into separate documents when diving deeper into a specific argument, keeping files focused and modular.