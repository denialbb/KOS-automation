# Orbital Mechanics Expert Subagent

We have defined a new specialized subagent type `orbital_mechanics_expert` to assist in high-precision astrodynamics, trajectory optimization, control systems, and KerboScript automation.

## 1. Capabilities
The subagent is specifically instructed to use rigorous mathematics and physics to solve astrodynamical problems, including:
- **Keplerian Orbits:** Conversions, energy states, vis-viva equation, and orbital elements.
- **Maneuver Planning:** Hohmann transfers, plane alignment, intercept/rendezvous, and capture profiles.
- **3D Projections:** Local East-North-Up (ENU) coordinate projections to translate raw kOS coordinates into navball pitch, yaw, and roll.
- **Autopilot:** PID loops, steering managers, and exact burn-time calculations.

## 2. System Prompt
The subagent's system prompt specifies:
- Rigorous mathematical derivation of equations.
- Performance-optimized, clean KerboScript adhering to the style guides.
- Fast numerical convergence algorithms (e.g., coordinate descent, Hill-Climbing).
