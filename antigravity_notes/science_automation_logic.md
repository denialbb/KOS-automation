# Science Automation Logic
- Date: 2026-06-12
- Objective: Cache science experiments (Kerbalism and stock) and run them on an automated cycle.
- Implementation: 
  - Added `cachedExperiments` to `DASA/utils/cache.ks` which captures modules containing "experiment" or "science" in their names.
  - Wrote a new continuous routine script `DASA/phases/science_loop.ks`.
  - The science routine prints all available module events to terminal for debugging and verification of Kerbalism's specific module actions.
  - The script executes the transmission of data first, then after a brief wait, initiates deployments, observations, runs, and starts without triggering resets or stops.
  - To save CPU and run appropriately with Kerbalism's time-based gathering, the script executes an infinite loop that waits 3600 seconds (1 in-game hour) between passes.
