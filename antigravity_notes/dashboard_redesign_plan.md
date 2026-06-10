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
- **Layout:** CSS Grid, 3 columns (300px | flex | 300px), 2 rows (flex | 260px).
- **Panels:**
  - Left: Navball + Orbital telemetry + Maneuver node display.
  - Center: 3D Vessel Viewer (attitude/blueprint modes) with mouse + touch controls.
  - Right: Resource gauges + Target info.
  - Bottom-left: Telemetry history graphs with toggleable datasets.
  - Bottom-right: Mission log (milestones feed).

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
- **Engine:** Chart.js, loaded from CDN.
- **Datasets:** 6 total, organized into 3 logical groups:
  - Trajectory (Y1 left axis): Altitude (km), Velocity (m/s).
  - Dynamics (Y2 right axis): TWR, Dynamic Q (kPa).
  - Resources (Y3 right axis): Electric Charge %, Total Fuel %.
- **Toggles:** Each dataset has a clickable tab in the UI with a color swatch. Clicking toggles visibility. Trajectory and Dynamics are enabled by default; Resources are off by default.
- **Rolling window:** 300 data points (5 minutes at 1 Hz update rate).
- **Rendering:** `animation: false` for performance.

### 5. Interpolation Strategy
- kOS telemetry arrives at approximately 1 Hz (limited by file IO).
- The JS client maintains a `prevTelemetry` / `currTelemetry` buffer.
- At each `requestAnimationFrame` tick, the HUD values (altitude, velocity, TWR, Q) are linearly interpolated between the previous and current snapshots using `performance.now()` timing.
- Attitude vectors (`fore`, `top`) are lerped independently at a fixed 0.1 blend factor per frame for smooth 60fps navball and vessel viewer rotation.

### 6. Server (telemetry_server/server.js)
- Node.js + Express serving static files.
- Routes: `/` (dashboard HTML), `/telemetry.json`, `/vessel_structure.json`, `/vessel_mesh.json`.
- Signal-loss detection: if `telemetry.json` is stale (>3s), the server injects `signalLost: true` into the response.
