
* **OrbitEta Exceptions:** Attempting to add an `OrbitEta` structure to a scalar (like `TIME:SECONDS`) throws a compiler error. When getting the time to an orbit patch transition, use the global bound variable `ETA:TRANSITION` instead of attempting to read `ORBIT:nextpatch:ETA`.
