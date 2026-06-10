# Probe Mission Plan

## Mission Requirements
1. **Activation:** The probe script must wait until it is staged before activating. Since it can be launched by a plane or rocket, checking for staging or a sudden change in state (e.g., vessel separation, engine ignition) is crucial. A loop waiting for `STAGE:READY` and a decrease in `SHIP:MASS`, or a check on `CORE:VESSEL` changing, could work. Given kOS behaviors, waiting until `MAXTHRUST > 0` or detecting a stage event is typically sufficient.
2. **Reaching Orbit:** Once active, the probe needs to reach orbit. We can leverage the existing `SpaceCore/Ascent.ks` and `SpaceCore/CircToAp.ks` scripts to handle the ascent profile and circularization, assuming the probe has its own engines.
3. **Deployment:** On the way to the station (e.g., after circularization or during the coast phase), the probe must deploy equipment. We'll deploy solar panels (`PANELS ON`) and activate science modules.
4. **Rendezvous:** We will use the `SpaceCore/Intercept.ks` script to perform a rendezvous with the target station.
5. **Docking:** `SpaceCore` does not seem to contain a dedicated docking script (`Landing.ks` exists but not docking). We will implement a custom docking sequence or approach logic.
6. **Logging:** Implement a logging function to write debug information to a file on the local volume (or archive) to trace the probe's steps.
7. **Style:** Adhere to the `kerboscript_style_guide.md` (lowercase keywords for complex scripts, explicit variable scope if lazyGlobal off, statement termination, etc.).

## Implementation Details (probe.ks)
- Enable `@lazyGlobal off.`.
- Create a `LogMessage` function that writes to `0:/probe_log.txt` (or local `1:/probe_log.txt`) with timestamps.
- Wait loop for staging/activation.
- Ascent sequence using `runpath("0:/SpaceCore/Ascent", false, 100, 0)`.
- Circularization using `runpath("0:/SpaceCore/CircToAp")`.
- Equipment deployment: `PANELS ON.`, loop through `SHIP:MODULES` or use action groups if needed.
- Target selection: Needs a target station. We might require a parameter or hardcode a target name (or wait for the user to select one, similar to `Intercept.ks`).
- Rendezvous: `runpath("0:/SpaceCore/Intercept", 0)`.
- Docking logic: Translate towards the target docking port using RCS.
