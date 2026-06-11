# DASA KSP Mission Control & Autopilot (KOSHUD)

A real-time telemetry dashboard, offline 3D part mesh visualizer, and autonomous orbital autopilot suite for Kerbal Space Program (KSP) using Kerbal Operating System (kOS).

---

## Project Overview

KOSHUD (DASA Mission Control) connects in-game flight systems to an external web-based dashboard. The system comprises an automated flight computer library, telemetry exporter, Node.js server, and an interactive HTML5 dashboard displaying attitude projections, vessel structure, and real-time flight metrics.

```mermaid
graph TD
    subgraph KSP Game Engine
        kOS[kOS Script Engine] -->|Writes Telemetry| TF[telemetry.json]
        kOS -->|Writes Structure| SF[vessel_structure.json]
    end

    subgraph Offline Mesh Parser
        MU[io_object_mu Parser] -->|Parses .mu Meshes| ME[mu_mesh_export.py]
        SF -->|References Parts| ME
        ME -->|Generates 3D Meshes| VF[vessel_mesh.json]
    end

    subgraph Node.js Web Server
        Express[Express Server] -->|Reads| TF
        Express -->|Reads| SF
        Express -->|Serves Assets| Dash[HTML5 Dashboard]
    end

    VF -->|Rendered in 3D| Dash
```

---

## Features

### Autopilot Suite (SpaceCore)
- Ascent profile automation and automated gravity turns.
- Circularization at Apoapsis and Periapsis.
- Orbital maneuver execution (Hohmann transfers, inclination adjustments, phasing, and intercepts).
- Docking and landing algorithms using RCS translation and suicide burn controls.

### Real-Time Telemetry Dashboard (v2)
- **Modular Dashboard Grid Layout**: Uses a responsive CSS grid including CRT typography, styling improvements (e.g. log border fades, science payload details), and error indicators.
- **Stacked Y-Axes Graph Drawer**: A collapsible history graph drawer featuring distinct stacked Y-axes for each active telemetry measure (Trajectory, Dynamics, and Resources), avoiding axis clutter.
- **Dynamic Velocity Scaling**: Velocity graphs automatically scale between m/s and km/s (switching at 300 m/s) to display orbital speed changes cleanly.
- **Interactive Resource Tabs**: Switch between interactive resource metrics with custom history graphs, cached colors to prevent gauge flashing, and abbreviated resource names.
- **Navball & Interpolation**: 60fps local ENU attitude projections, heading indicators, and smooth linear interpolation between 1 Hz telemetry packets.
- **Adaptive 3D Vessel Viewer**: Recalculates viewport scale and automatically centers the active vessel render when the graph drawer is toggled open or closed.

### Offline 3D Vessel Visualizer
- Offline extraction of KSP .mu binary model meshes from GameData.
- Mesh decimation to optimize JSON payload sizes.
- Real-time vessel structure rendering and part tracking.

---

## Repository Structure

- `DASA/`: Mission coordination framework and modular task-runner architecture.
  - `core/`: Contains the `mission_runner.ks` task-runner engine that executes mission sequences.
  - `phases/`: Phase modules (e.g., `boot.ks`, `ascent.ks`, `transfer.ks`, `capture.ks`).
  - `utils/`: Reusable mission utility functions (e.g., telemetry, power, science, logging).
  - `minmus_mission.ks`: Slim mission configuration file defining the sequence array and targets.
- `SpaceCore/`: Modular autopilot libraries (ascent, node execution, intercepts, landing, docking).
- `KOSmodore/`: Standard utility libraries (terminal interfaces, filesystem tools, GPS, hovering).
- `dashboard/`: Frontend HTML5/JS telemetry dashboard.
- `telemetry_server/`: Express.js backend and Python mesh parsing utilities.
- `telemetry/`: Telemetry and structure files generated during flight.
- `logs/`: Autopilot logs and event logs.
- `antigravity_notes/`: Design documentation, mathematical derivations, and project notes.

---

## Quick Start

### 1. Prerequisites
- **Kerbal Space Program** (v1.12.x) with the **kOS** mod.
- **Astrogator** and **kOS-Astrogator** mods (for maneuver node planning).
- **Node.js** (LTS) and **NPM**.
- **Python 3.x**.

> [!IMPORTANT]
> The automation scripts require the kOS option "Start on the Archive" to be enabled in KSP settings, as the library size exceeds standard in-game CPU memory limits.

### 2. Launching the System
1. Stage or boot the vessel in-game with the telemetry script active.
2. In the repository root, start the Node.js server and open the dashboard:
   ```powershell
   python launch_dashboard.py
   ```
3. Alternately, execute the server wrapper scripts directly:
   - `start_telemetry_server.bat`
   - `./start_telemetry_server.ps1`

### 3. Running Telemetry Diagnostics
The repository includes a headless diagnostics tool using Puppeteer to run telemetry tests and capture interface renders:
1. Navigate to the `telemetry_server/` directory.
2. Run the diagnostics script:
   ```powershell
   node telemetry_server/diagnose_dashboard.js
   ```
The diagnostics tool checks port availability (port 8080), spawns the Express.js telemetry server, launches a headless browser, monitors the console log for errors or exceptions, expands the historical graphs panel, listens to active telemetry for 20 seconds, captures a timestamped screenshot in `dashboard/.temp_diagnostics/`, and conducts a clean teardown.

---

## Dependencies and Licensing

The project components and their licenses are audited below:

| Component | License | Role |
| :--- | :--- | :--- |
| **Express.js** | MIT | Telemetry routing backend server. |
| **SpaceCore** | MIT | Reusable autopilot library. |
| **io_object_mu** | GNU GPL v2 | Mesh parser library (external dependency). |
| **kOS Mod** | GNU GPL v3 | Runtime environment. |
| **Astrogator & kOS-Astrogator** | GNU GPL v3 | Transfer calculation and node planning addon. |

To ensure repository compliance with the permissive MIT license, the GPL-licensed `io_object_mu` dependency is excluded from repository distribution via `.gitignore` and is cloned dynamically at runtime by `launch_dashboard.py`.

For the detailed dependency analysis and design choices, see [licensing_and_dependencies.md](file:///c:/Program%20Files%20%28x86%29/Steam/steamapps/common/Kerbal%20Space%20Program/Ships/Script/antigravity_notes/licensing_and_dependencies.md).