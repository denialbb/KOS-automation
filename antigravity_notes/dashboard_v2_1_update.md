# DASA Telemetry Dashboard v2.1 Update Report

## Overview
Following the comprehensive telemetry audit (`dasa_telemetry_audit.md`), the dashboard, backend server, and kOS telemetry pipeline were significantly upgraded to v2.1. This update resolves critical performance bottlenecks, styling inconsistencies, and physics edge-cases while introducing eight new major features designed to enhance real-time mission situational awareness.

## Performance & Core Fixes
The core rendering and data parsing pipelines were refactored for efficiency:
- **DOM Thrashing Eliminated**: The Resources panel now uses a `resourcesDirty` flag, updating the DOM only when resource capacity or allocations change, rather than clearing and rebuilding the entire structure at 60 FPS.
- **O(1) Part Lookups**: Replaced O(n²) string lookups inside the telemetry processing loop with a precomputed JavaScript `Map`, vastly speeding up execution.
- **Deterministic Colors**: Resource graph colors are now generated using a stable string hashing algorithm rather than `Math.random()`, ensuring consistent aesthetics across browser reloads.
- **Async Safety**: `setInterval` fetching was replaced with chained `setTimeout` promises to prevent overlapping HTTP requests and subsequent race conditions during server stalls.

## Mesh & Backend Improvements
- **Quaternion Rotations**: The offline `.mu` python mesh exporter (`mu_mesh_export.py`) was upgraded with a quaternion math utility. Angled parts (e.g. swept wings, deployed antennas, fins) now correctly apply their local rotation quaternions to their rendered vertices, correctly displaying their orientation in the web viewer.
- **Pause Detection**: The kOS script (`telemetry.ks`) now detects when the KSP engine is paused or time warp is 0, emitting a `"paused": true` signal. This prevents the Node.js server from incorrectly logging false "SIGNAL LOST" alarms during game pauses.
- **Deployables Cache**: Added server routing to serve a newly tracked `deployables_cache.json` which maps active science instruments and fairings.

## New Features (Phase 2 Additions)
The following panels and mechanics were added to the HUD:

1. **Orbit Diagram Panel**: A 2D visualization rendering the planetary body (scaled dynamically to Kerbin, Mun, Minmus radii), the orbital ellipse, Ap/Pe markers, and live maneuver node/target offsets.
2. **Maneuver Burn Timer**: The maneuver block now displays an accurate burn countdown window (T +/- t_half), estimating the required burn duration based on active Thrust-to-Weight Ratio (TWR). It features a visual progress bar and flashes amber/red at T-60s and T-10s.
3. **Critical Threshold Alert System**: A declarative alert engine that scans telemetry arrays for critical danger states (Low Electric Charge, Max-Q zone, Periapsis in Atmo). When triggered, a CSS-animated pulse bar appears and an `AudioContext` beep alerts the user.
4. **WebSocket Push Telemetry**: Replaced HTTP polling for the main data feed with a real-time WebSocket connection. The backend uses `fs.watch` to instantly push JSON updates when the kOS computer writes the telemetry file, eliminating polling latency.
5. **Deployables Status Panel**: Parses kOS dictionaries to track whether fairings, antennas, and science sensors are "STAGED", "JETTISONED", or active, displaying them dynamically below the Resources panel.
6. **Telemetry Data Export**: Added a CSV export button, allowing engineers to download the session's historical flight telemetry charts directly to a `.csv` file for post-mission analysis.
7. **Blueprint Part Category Filter**: Added interactive toggle chips to the Blueprint view mode to isolate specific vessel components, dimming non-matching categories down to 8% opacity.
8. **Periapsis-in-Atmosphere Warning**: Added a persistent inline warning next to the periapsis readout if the projected periapsis drops below the active celestial body's atmospheric limit.
