# Minmus Automation Mission - Decision & Design Notes

This note documents our design decisions, orbital mechanics formulations, and subsystem management strategies for the Minmus automation flight computer.

## 1. Orbital Mechanics Strategy

### A. Plane Alignment
Minmus's orbit is inclined at $6^\circ$ relative to Kerbin. To minimize transfer delta-V, we align our orbital plane with Minmus before the transfer burn.
- **Node Identification:**
  - Let $\vec{n}_{\text{ship}} = (\vec{v} \times \vec{r}):normalized$.
  - Let $\vec{n}_{\text{tgt}} = (\vec{v}_{\text{tgt}} \times \vec{r}_{\text{tgt}}):normalized$.
  - Relative inclination: $i_{\text{rel}} = \arccos(\vec{n}_{\text{ship}} \cdot \vec{n}_{\text{tgt}})$.
  - Ascending Node (AN) position vector: $\vec{r}_{\text{AN}} = (\vec{n}_{\text{tgt}} \times \vec{n}_{\text{ship}}):normalized$.
  - Descending Node (DN) position vector: $\vec{r}_{\text{DN}} = -\vec{r}_{\text{AN}}$.
- **Burn Mechanics:**
  - At the node, delta-V vector: $\Delta\vec{v} = v \cdot \vec{u}_{\text{tgt}} - v \cdot \vec{u}_{\text{curr}}$.
  - The node is created at the exact node crossing time using Keplerian Time-of-Flight math.

### B. Hohmann Transfer & Numerical Optimization
- **Analytical Guess:**
  - Transfer semi-major axis: $a_{\text{trans}} = (r_{\text{ship}} + r_{\text{Minmus}}) / 2$.
  - Transfer time: $t_{\text{trans}} = \pi \sqrt{a_{\text{trans}}^3 / \mu}$.
  - Target phase angle: $\phi_{\text{tgt}} = 180^\circ - \frac{360^\circ}{T_{\text{Minmus}}} \cdot t_{\text{trans}}$.
- **Numerical Search (Hill-Climber):**
  - KSP orbits can be perturbed by eccentricity and the relative positions.
  - We create a maneuver node at the estimated time and delta-V, then run a coordinate descent search in `time` and `prograde dV` to find a Minmus encounter.
  - Once an encounter is found, we minimize the difference between the predicted periapsis and the user's target periapsis.

### C. Capture and Circularization
- **Capture Burn:**
  - Retrograde burn at Minmus periapsis to lower apoapsis below the SOI boundary.
  - Target periapsis velocity: $v_{\text{tgt}} = \sqrt{\mu_{\text{Minmus}} (2/r_{\text{peri}} - 1/a_{\text{tgt}})}$ where $a_{\text{tgt}} = (r_{\text{peri}} + r_{\text{apo\_tgt}}) / 2$.
- **Adjustment Burns:**
  - Fine-tuning of inclination, periapsis, and circularization inside Minmus SOI using standard node execution.

---

## 2. Subsystems Management

### A. Power & Solar Tracking
- When coasting in LKO or deep space, the ship will lock its steering to `sun:position` (or a configured offset) to ensure solar panels receive full exposure.
- `panels on` is asserted periodically.

### B. APU Automation
- Active monitoring of Electric Charge.
- APUs (Fuel Cells/Generators) are turned ON when charge drops below 20% and turned OFF when it rises above 90%.
- Dynamic event detection scans all parts and modules for events containing `start`/`stop` and `cell`/`gen`/`apu`/`power`.

### C. Science Experiment Automation
- Periodically scan all parts for science and sensor modules (`ModuleScienceExperiment`, `ModuleSensorExperiment`, `ModuleKerbalismScience`, etc.).
- Automatically trigger the experiments using `deploy()` and relevant events (`start`, `run`).
- Deploy transmitters/antennas for data transmission.

---

## 3. Mission Architecture (Modular Refactor)

The `DASA/minmus_mission.ks` script has been refactored from a monolithic script into a modular, phase-based task-runner architecture:
- **Mission Runner (`DASA/core/mission_runner.ks`)**: A core engine that iterates through a configured `mission_sequence` array, dynamically loading and executing phases.
- **Phase Modules (`DASA/phases/`)**: Individual mission stages (`boot.ks`, `ascent.ks`, `deployment.ks`, `transfer.ks`, `coast.ks`, `capture.ks`) are self-contained and executed sequentially by the runner.
- **Utilities (`DASA/utils/`)**: Reusable subsystems and helper functions (`logging.ks`, `telemetry.ks`, `power.ks`, `science.ks`, `math.ks`, `coasting.ks`) are imported as needed.
- **Mission Configuration (`DASA/minmus_mission.ks`)**: Acts strictly as a configuration file, setting up the target parameters, defining the `mission_sequence` array, and invoking the runner.
