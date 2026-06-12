
* **OrbitEta Exceptions:** Attempting to add an `OrbitEta` structure to a scalar (like `TIME:SECONDS`) throws a compiler error. When getting the time to an orbit patch transition, use the global bound variable `ETA:TRANSITION` instead of attempting to read `ORBIT:nextpatch:ETA`.
* **Global Function Sharing:** Shared routines like `runAllScience()` used across both coasting phases and loops must be declared as `GLOBAL FUNCTION` inside a utility file (like `DASA/utils/cache.ks`) that is loaded early in the mission sequence, rather than being local to specific stage scripts, to avoid `KOSUndefinedIdentifierException` runtime errors.

