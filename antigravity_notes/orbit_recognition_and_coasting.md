# Design Notes: Automatic LKO Recognition on Reboot

This document records the design decisions and logic details for recognizing the vessel's orbit state on boot and altering the state machine accordingly.

## 1. Orbit State Classification

When the vessel reboots, we need to classify its state into one of two categories:

1. **LKO-bound / LKO-active:** The mission needs to perform the launch, circularization, deployment, and transfer burns.
2. **Post-Transfer / Coasting:** The transfer burns have already been done. The ship should default to a coasting stage (orienting panels, warping to SOI transition if trajectory exists) and then return control to the user.

### Classification Logic

We check the following conditions on startup:

- **Body:** Is the vessel orbiting or on the surface of Kerbin? `SHIP:BODY:NAME = "Kerbin"`.
- **Status:** If the status is `PRELAUNCH`, `LANDED`, `FLYING`, or `SUB_ORBITAL`, we are still on Kerbin or ascending, meaning we are LKO-bound.
- **Altitude range:** If the status is `ORBITING`, we check if the orbit is "Low". Standard Low Kerbin Orbit (LKO) is above the atmosphere (70km) and below 250km:
  - `SHIP:PERIAPSIS > 70000`
  - `SHIP:APOAPSIS < 250000`

If all these match, the vessel is in LKO. If not, it is outside LKO.

## 2. State Machine Modification

The state machine uses a global `mission_sequence` list of strings representing phase scripts in `DASA/phases/`:

- Full sequence: `LIST("boot", "ascent", "deployment", "transfer", "coast", "capture", "science_loop")`.

Upon reboot:
- If the vessel is classified as LKO-active, we preserve the full sequence.
- If the vessel is classified as outside LKO, we override the sequence to:
  `SET mission_sequence TO LIST("boot", "coast").`

Because `coast.ks` will finish executing upon reaching the target's SOI (or immediately skip if already inside target SOI or if no trajectory exists), the mission runner loop finishes. Since there are no further phases, the script terminates naturally. In kOS, when the main script terminates, control of the terminal is returned to the user, allowing interactive commands.

## 3. Robust Coasting Phase

To ensure the coasting phase does not hang when started from an arbitrary state (e.g. if the vessel is already inside the target's SOI, or if there's no active trajectory to the target):
- If `SHIP:BODY:NAME = TARGET:NAME`, skip the transition wait.
- If `ORBIT:HASNEXTPATCH = TRUE` and the next patch body matches `TARGET`, wait for the transition using `safeCoast`.
- Otherwise, log a warning and exit the phase immediately.
