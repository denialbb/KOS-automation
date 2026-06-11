# MechJeb and kOS Integration

## 1. Overview
The implementation strategy for utilizing MechJeb within kOS heavily relies on the `ADDONS:MJ` wrapper API. We have developed a series of scripts inside the `MJ/` directory to seamlessly integrate MechJeb's autopilot and maneuver planning capabilities into the primary kOS workflow. Our design pattern ensures that if MechJeb is absent from the vessel or installation, scripts gracefully fall back to native kOS `SpaceCore` algorithms.

## 2. General Integration Logic (`MJ.ks`)
- **Availability Check**: Prior to invoking any MJ suffix, scripts always verify `ADDONS:AVAILABLE("MJ")` (wrapped by `mjAvailable()`).
- **Control Handoff**: When MechJeb takes control of the vessel, kOS must release its locks. This is performed by explicitly unlocking steering and throttle via `mjReleaseControl()`:
  ```kerboscript
  UNLOCK STEERING.
  UNLOCK THROTTLE.
  SET SHIP:CONTROL:NEUTRALIZE TO TRUE.
  ```
- **Module Readiness**: Because MechJeb modules might not initialize instantly on scene load, `mjWaitForModule(modName, timeout)` is used to safely poll `ADDONS:MJ:HASMODULE(modName)` until it returns true or times out.

## 3. Ascent Autopilot (`MJAscent.ks`)
The ascent autopilot is interfaced via `ADDONS:MJ:ASCENT`.
- Configuration is done programmatically by checking `HASSUFFIX` for compatibility before setting properties like `ORBITALT`, `INCLINATION`, and `AUTOSTAGE`.
- After configuration and releasing control locks, the autopilot is engaged via `SET ADDONS:MJ:ASCENT:ENABLED TO TRUE`.
- The script continues to run a monitoring loop to manage custom event triggers (e.g., Fairing Deployment at specific altitudes) and logs these milestones to `0:/mission_history.log`.

## 4. Maneuver Planner (`MJChangeAp.ks` & Node Execution)
- The maneuver planner is accessed via `ADDONS:MJ:PLANNER`.
- We use API methods such as `addons:mj:planner:changeapoapsis(targetApM)` to instruct MechJeb to generate maneuver nodes.
- Execution of these nodes is then delegated to a node execution script (`ExeNode.ks`), which relies on MechJeb's node executor to perform the burn precisely.

## 5. Core Addon API Reference

### Core MechJeb API (`ADDONS:MJ`)
- `ADDONS:AVAILABLE("MJ")`: (`Boolean`) Validates the presence of the kOS-MechJeb plugin.
- `ADDONS:MJ:HASMODULE(modulename)`: (`Boolean`) Checks if the active MJ part has a specific module.
- `ADDONS:MJ:MODULES`: (`List`) Returns a list of strings representing the names of the available MechJeb modules on the vessel.

### Ascent Autopilot (`ADDONS:MJ:ASCENT`)
- `ORBITALT`: (`Scalar`) Target orbit altitude in meters.
- `INCLINATION`: (`Scalar`) Target orbit inclination in degrees.
- `AUTOSTAGE`: (`Boolean`) Enables or disables MechJeb's automatic staging feature during ascent.
- `ENABLED`: (`Boolean`) Master toggle for the ascent autopilot. Set to `TRUE` to activate.

### Maneuver Planner (`ADDONS:MJ:PLANNER`)
*Note: Planner methods generally append a node to the vessel's flight plan.*
- `CHANGEAPOAPSIS(altitude_in_meters)`: Generates a maneuver node to modify the apoapsis.
- `CHANGEPERIAPSIS(altitude_in_meters)`: Generates a maneuver node to modify the periapsis.
- `CIRCULARIZE()`: Generates a circularization node (usually at the next apsis).

### Node Executor (`ADDONS:MJ:NODEEXECUTOR` / `ADDONS:MJ:EXECUTE`)
- `ENABLED` / `EXECUTE_ALL_NODES`: (`Boolean`) Set to `TRUE` to command MechJeb to execute the maneuver nodes currently in the flight plan.

---
*Note: This documentation should be expanded as more modules (e.g., Rendezvous Planner, Landing Autopilot) are integrated.*

## 6. Integration Test Suite
To verify the compatibility and functionality of the kOS MechJeb2 Addon bindings, a dedicated test suite is located in the `Tests/` directory:
- `TestRunner.ks`: A menu-driven interface to run all or specific wrappers.
- `CoreWrapperTest.ks`: Verifies top-level addon connectivity and status.
- `VesselWrapperTest.ks`: Asserts that basic vessel telemetry and attitude are exposed.
- `InfoWrapperTest.ks`: Asserts that MechJeb telemetry calculations (TWR, vac delta-V, target details) are correct.
- `AscentWrapperTest.ks`: Tests Classic Ascent autopilot parameters (inclination, turn heights, autostage parameters).
- `ManeuverPlannerWrapperTest.ks`: Verifies planner bindings and node generation methods.
- `ManeuverPlannerBasicTest.ks`: Plans changes to Pe, Ap, and SMA, validating node construction.
- `NodeExecutorWrapperTest.ks`: Tests MechJeb node executor toggles (autowarp, active status).

### How to Run the Tests
1. Load a vessel with a kOS CPU and MechJeb unit.
2. Open the kOS terminal and run:
   ```kerboscript
   cd("Tests").
   run TestRunner.
   ```
3. Use the menu choices to run the desired test suite. Note that while Core, Vessel, and Info tests can be run safely anywhere (even on the launchpad), maneuver planner and ascent tests are best run in space or during active flight scenarios to satisfy KSP physics/orbital constraints.
