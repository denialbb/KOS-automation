# Removing Complex Coasting Routine

**Decision Date:** 2026-06-12

## Context
MechJeb's "Execute Node" module inherently handles warping to maneuver nodes. Previous implementations used a custom `safeCoast` routine that warped time in small chunks, stopping periodically to orient solar panels and run science. This proved unnecessarily complex and redundant when using MechJeb for node execution.

## Changes
1. **Simplified `safeCoast`**:
   - Refactored `DASA/utils/coasting.ks`. The complex chunking loop was removed.
   - Introduced `orientForPower()`, which points the craft's solar panels at the sun and runs the optimization routine.
   - `safeCoast` now just calls `orientForPower()` and performs a single, continuous warp to the `targetTime`. This is useful for coasting to SOI changes or Periapsis where there is no node.
2. **Transfer Phase Update**:
   - In `DASA/phases/transfer.ks`, calls to `safeCoast` before executing a maneuver node were replaced with `orientForPower()`.
   - The craft now orients its panels to top up power right before MechJeb takes over to handle the warp and burn.
3. **Execution Script (`ExeNode.ks`) Update**:
   - Removed the manual `WARPTO` logic from `MJ/ExeNode.ks` since MechJeb natively handles the time warp to the node. 
