# VesselViewer Rendering Research

## How VesselViewer Works
- Unity C# plugin; renders entirely in-engine via `Camera.SetReplacementShader()` + `RenderTexture`
- Collects meshes via `GetComponentsInChildren<MeshFilter>()` on each `part.partTransform`
- Replaces all materials with wireframe/solid shaders, renders to off-screen texture
- Displays on RPM cockpit MFD or GUI window
- **Exports nothing** — all geometry stays in Unity GPU memory

## kOS Cannot Access Mesh Data
- kOS provides `Part:BOUNDS` (AABB), `Part:POSITION`, `Part:FACING`, `Part:NAME`, `Part:UID`
- No access to `MeshFilter`, `Mesh.vertices`, `Mesh.triangles`, or Unity internals
- `Part:BOUNDS` forces a physics tick per call (~1s for 50 parts)

## Viable Paths to Better Visuals
1. **Enhanced Procedural Canvas 2D** (chosen for now): Detailed wireframes from bounding boxes + name heuristics. Zero dependencies, fast, lightweight.
2. **Offline .mu Pipeline** (future): Python parser (`io_object_mu/mu.py`) reads KSP `.mu` model files → extract real vertices → write simplified JSON → dashboard renders actual part shapes.
3. **C# KSP Plugin** (heavy): Runtime mesh export via `MeshFilter.sharedMesh.vertices`. Most powerful but highest effort.

## Decision
Proceeding with Enhanced Procedural Canvas 2D (Phase 1). The .mu pipeline is the best Phase 2 candidate — real mesh fidelity with moderate effort, no runtime mod needed.
