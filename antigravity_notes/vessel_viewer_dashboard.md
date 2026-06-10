# 3D Telemetry Dashboard - Vessel Viewer Implementation

This document summarizes the implementation of the 3D Vessel Viewer built into the `telemetry_dashboard.html`, combining procedural geometry and an offline `.mu` mesh pipeline.

## Phase 1: Enhanced Procedural Rendering
To provide a fast, responsive fallback when real meshes aren't available, we enhanced the `telemetry_dashboard.html` 2D Canvas rendering:
1. **Depth Cueing:** `project()` now returns a `zDepth`. The `drawLine()` function calculates the average Z depth of the two points to compute opacity (fading distant parts) and applies dashed line patterns for back-faces.
2. **Detailed Procedural Shapes:** Instead of simple boxes, the script dynamically identifies parts based on their name/title and uses optimized `drawProceduralPart()` logic:
   - Command Pods -> Truncated cones
   - Fuel Tanks -> Ribbed cylinders
   - Engines -> Bell nozzle shapes
   - Solar Panels -> 2D grids
   - Aerodynamics -> Fin/wing triangles
   - Decouplers -> Rings
3. **Color Coding:** Parts are colored based on their function (e.g. Command = Green, Tank = Cyan, Engine = Red, Science = Purple).
4. **Interactive Controls:** Added mouse/touch support for panning (Right-click or Shift+click drag) and zooming (Mouse wheel), along with the existing Attitude and Blueprint view modes.
5. **Connection Loss Logging:** Both Node.js and PowerShell servers now track telemetry file staleness and append events to `logs/log.txt` when connection to the KSC is lost.

## Phase 2: Offline `.mu` Mesh Pipeline
Since kOS cannot export raw meshes at runtime, and in-game mods like VesselViewer use proprietary Unity shaders that cannot be exported to the browser, an offline tool was built: `telemetry_server/mu_mesh_export.py`.

1. **`io_object_mu` Integration:** We cloned the open-source `taniwha/io_object_mu` Blender plugin to extract its core `mu.py` parser.
- `io_object_mu` provides full coordinate transformations relative to the Unity origin, enabling realistic reconstruction.
- To maintain browser performance, the parsing script decimates triangles (max 250 triangles per part) and strips unused vertices. This reduces JSON payloads by over 80% (e.g. from 10MB to 1.8MB).

2. **Mesh Generation:** The Python script parses all `.cfg` files in `GameData/` to build a database of part names mapping to their respective `.mu` model files.
3. **Structure Matching:** By reading `vessel_structure.json` exported by kOS, the script finds matching `.mu` files and extracts vertex and triangle data.
4. **Decimation and Export:** To keep the browser performant, `mu_mesh_export.py` limits the number of triangles and writes the simplified geometry to `vessel_mesh.json`.
5. **Dashboard Integration:** `telemetry_dashboard.html` fetches `vessel_mesh.json` periodically. For every part, it prefers rendering the real `.mu` mesh (using a backface-culled wireframe approach). If the mesh is missing, it falls back seamlessly to the enhanced procedural rendering.

## Setup Requirements
To use the real-geometry Mesh Pipeline:
1. Ensure Python (`uv`) is installed.
2. Run `uv run python telemetry_server/mu_mesh_export.py` to generate the `vessel_mesh.json` for the current craft.
3. The dashboard will automatically update and display the complex meshes.

## Future Optimization
- Implement an automated hook so that when kOS exports a new `vessel_structure.json`, the Node.js server automatically runs `mu_mesh_export.py` in the background.
- Further refine the Python decimation algorithm to preserve silouhettes instead of simple index skipping.
