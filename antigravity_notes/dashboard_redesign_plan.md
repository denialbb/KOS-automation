# Dashboard Redesign Plan — v2

## Overview
Transform the KSP Mission Control Dashboard to a professional, minimalist interface. The design uses a structured CSS grid, dark theme (`#0F0F0F` / `#1A1A1A`), tabular monospace numerals, and a data-dense layout optimized for full-screen use.

## Architecture

### 1. Telemetry Generation (kOS)
- **File:** `DASA/minmus_mission.ks` (Telemetry loop).
- **Telemetry Points:**
  - `TWR` (Thrust-to-Weight Ratio): `ship:availablethrust / (ship:mass * local_gravity)`.
  - `Q` (Dynamic Pressure): `ship:dynamicpressure`.
  - `milestones`: Array of strings representing mission events, logged via `logMsg()` and printed to kOS terminal.
  - `maneuver`: Object with `hasNode`, `eta`, `dv` when a maneuver node exists.
  - `attitude`: ENU-projected `fore` and `top` vectors for the navball and vessel viewer.
- **Implementation:** All values are serialized directly into the JSON payload in `updateTelemetry()`.

### 2. Dashboard Interface (telemetry_dashboard.html)
- **Layout**: CSS Grid, 3 columns (300px | flex | 300px) and 2 rows (flex | collapsible drawer).
- **Collapsible Graph Drawer**: Positioned outside the center HUD container to prevent click event overlapping. It is toggled via an inline header toggle bar (`.graph-drawer-toggle`), expanding the graph container's height without breaking the grid.
- **Panels**:
  - Left: Navball + Orbital telemetry + Maneuver node display.
  - Center: 3D Vessel Viewer (attitude/blueprint modes) with mouse + touch controls.
  - Right: Resource gauges (with cached colors to eliminate flashing) + Target info.
  - Bottom Drawer: Stacked telemetry history graphs and the running mission event log.

### 3. Navball Design
The navball is a custom HTML5 Canvas drawing at 60fps via `requestAnimationFrame`. It features:
- Spherical sky/ground projection with gradient coloring (blue sky / brown ground).
- Horizon line with cardinal direction labels (N/S/E/W) positioned relative to heading.
- Pitch ladder lines: solid for positive pitch, dashed for negative; labels at 30-degree intervals.
- 10-degree heading tick marks along the horizon.
- Fixed overlay: center crosshair (cyan wings + dot), not affected by roll.
- Roll indicator arc at the top of the sphere with tick marks at standard intervals (0, ±10, ±20, ±30, ±45, ±60), plus a triangular roll pointer.
- Outer bezel ring.
- Digital readouts for HDG, PIT, ROL displayed below the navball.

### 4. Graph System
- **Engine**: Chart.js (loaded via CDN).
- **Stacked Y-Axes**: Telemetry measures (Trajectory, Dynamics, and Resources) are mapped to distinct, stacked Y-axes instead of sharing scale space. This provides clean visual separation, with auto-updating axis titles and hidden X-axis ticks to prevent overlap.
- **Custom Interactive Resource Tabs**: Users can switch between interactive resource history graphs (e.g., Electric Charge, Liquid Fuel, Oxidizer, Monopropellant) via dedicated tabs. Resource names are abbreviated, and gauges use cached colors to prevent rendering flashes.
- **Rolling Window**: 300 data points (5 minutes at 1 Hz update rate). X-axes are formatted dynamically using Mission Time (`T+`).
- **Dynamic Velocity Scaling**: Automatically rescales velocity telemetry from meters per second (`m/s`) to kilometers per second (`km/s`) when the velocity exceeds 300 m/s.
- **Time-Frozen Pause Logic**: Chart scrolling and updates are paused when the mission simulation time is frozen or paused, preventing empty trailing lines.

### 5. Canvas Scale and Centering Recalculation
- **Vessel Viewer Integration**: Toggling the bottom graph drawer changes the viewport size of the 3D Vessel Viewer canvas.
- **Centering & Scale Recalculation**: On drawer open/close events, the CSS layout reflows, and the canvas trigger recalculates the orthographic camera bounds and centers the vessel model. This prevents aspect-ratio distortion, clipping, or visual scaling bugs when the center-hud size changes.

### 6. Interpolation Strategy
- kOS telemetry arrives at approximately 1 Hz (limited by file IO).
- The JS client maintains a `prevTelemetry` / `currTelemetry` buffer.
- At each `requestAnimationFrame` tick, the HUD values (altitude, velocity, TWR, Q) are linearly interpolated between the previous and current snapshots using `performance.now()` timing.
- Attitude vectors (`fore`, `top`) are lerped independently at a fixed 0.1 blend factor per frame for smooth 60fps navball and vessel viewer rotation.

### 7. Server (telemetry_server/server.js)
- Node.js + Express serving static files.
- Routes: `/` (dashboard HTML), `/telemetry.json`, `/vessel_structure.json`, `/vessel_mesh.json`.
- Signal-loss detection: if `telemetry.json` is stale (>3s), the server injects `signalLost: true` into the response.
