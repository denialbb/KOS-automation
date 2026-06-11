# MechJeb kOS Integration Suffixes Reference

This document serves as a reference guide for the MechJeb integration suffixes available in kOS via the `kOS.MechJeb2.Addon` (v0.0.4+).

## 1. Initializing and Checking Addon Availability

To ensure scripts do not crash on vessels without MechJeb or when the mod is not installed:

```kerboscript
// Check if MechJeb addon is available
IF ADDONS:AVAILABLE("MJ") {
    LOCAL mj IS ADDONS:MJ.
}
```

> [!WARNING]
> **Suffix Compatibility & Availability**
> Depending on the compiled version of the `kOS.MechJeb2.Addon` DLL, the `PLANNER` and `NODE` wrappers may not be exposed. Accessing them when they are not present will throw a fatal `KOSSuffixUseException`. 
> Always verify their existence using `HASSUFFIX` before calling them:
> ```kerboscript
> IF NOT ADDONS:AVAILABLE("MJ") OR NOT ADDONS:MJ:HASSUFFIX("PLANNER") OR NOT ADDONS:MJ:HASSUFFIX("NODE") {
>     // Fall back to native kOS logic
> }
> ```

---

## 2. Core Addon Wrapper (`ADDONS:MJ`)

The top-level `ADDONS:MJ` object provides status indicators and sub-wrappers.

### Suffixes:
- **`CORE`**: Returns a status wrapper.
  - **`RUNNING`**: (`Boolean`) `TRUE` if a MechJeb core module is active and bound.
- **`VERSION`**: (`String`) Returns the version of the integration addon (e.g., `0.0.4`).
- **`VESSEL`** (or **`VESSELINFO`**): Accesses the `VesselStateWrapper` for vessel telemetry.
- **`INFO`**: Accesses the `MechJebInfoItemsWrapper` for MechJeb's internal telemetry calculations.
- **`ASCENT`** (or **`ASCENTGUIDANCE`**): Accesses the `MechJebAscentWrapper` for the Ascent Autopilot.
- **`PLANNER`**: Accesses the maneuver planner methods.
- **`NODE`** (or **`NODEEXECUTOR`**): Accesses the maneuver node execution autopilot.

---

## 3. Ascent Autopilot (`ADDONS:MJ:ASCENT`)

Allows programmatic control of MechJeb's Classic Ascent Autopilot.

### Suffixes & Properties:
- **`ENABLED`**: (`Boolean`, Get/Set) `TRUE` to engage the autopilot; `FALSE` to disengage.
- **`ORBITALT`**: (`Scalar`, Get/Set) Target orbit altitude in meters.
- **`INCLINATION`**: (`Scalar`, Get/Set) Target orbit inclination in degrees.
- **`AUTOSTAGE`**: (`Boolean`, Get/Set) `TRUE` to let MechJeb handle stage activation during ascent.
- **`SUFFIXNAMES`**: (`List` of `String`) Returns all available properties on the Ascent wrapper.

---

## 4. Maneuver Planner (`ADDONS:MJ:PLANNER`)

Exposes MechJeb's automated maneuver calculation and node placement.

### Suffixes & Methods:
- **`CHANGEAPOAPSIS(altitude_in_meters)`**: Generates a node to modify the apoapsis to the target altitude.
- **`CHANGEPERIAPSIS(altitude_in_meters)`**: Generates a node to modify the periapsis to the target altitude.
- **`CHANGEINCLINATION(inclination_in_degrees)`**: Generates a node to match or target a specific orbital inclination.
- **`CIRCULARIZE()`** or **`CIRCULARIZEAPOAPSIS()`**: Generates a circularization node (typically placed at the next apoapsis).
- **`SUFFIXNAMES`**: (`List` of `String`) Returns all available methods on the Planner wrapper.

---

## 5. Node Executor (`ADDONS:MJ:NODE`)

Interfaces with MechJeb's maneuver node execution module.

### Suffixes & Properties:
- **`ENABLED`**: (`Boolean`, Get/Set) `TRUE` to engage MechJeb steering and throttle to execute the next planned maneuver node. Disengages automatically when no nodes remain.

---

## 6. Vessel State and Info Items (`ADDONS:MJ:VESSEL` & `ADDONS:MJ:INFO`)

Provides wrappers for high-fidelity telemetry calculations performed by MechJeb.

- **`VESSEL`**: Wraps state variables including velocity vectors, aerodynamic forces, and attitude parameters.
- **`INFO`**: Exposes MechJeb's library of registered info items (e.g., TWR, current stage $\Delta v$, total vacuum/atmospheric $\Delta v$, target relative distance, and relative velocity).
