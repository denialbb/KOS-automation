# Deployables Caching Design Notes

## Problem Context
When executing mission scripts in kOS, especially in complex spacecraft with many parts, scanning the entire parts tree is computationally expensive. Because kOS is an interpreted language running within Kerbal Space Program's physical update cycle:
- String operations (`contains`, `tolower`) on part and module names scale with $O(N \times M)$ where $N$ is the number of parts and $M$ is the number of modules per part.
- Walking the parts tree on boot or reboot introduces latency.
- Interrupted power or saving/loading state often triggers a reboot, forcing the script to re-run the slow tree walk.

## Solution: JSON Caching of Module References
Since kOS `Part` and `PartModule` references cannot be directly serialized to disk, we serialize their identifiers:
1. `part:UID` (unique identifier within the flight session).
2. `pMod:name` (the string identifier of the module).

### Cache Structure (`0:/telemetry/deployables_cache.json`)
```json
{
  "vessel_name": "My Probe",
  "root_uid": "4294871234",
  "part_count": 45,
  "fairings": [
    ["4294871250", "ModuleProceduralFairing"]
  ],
  "deployables": [
    ["4294871260", "ModuleDeployableAntenna"],
    ["4294871270", "ModuleDeployableSolarPanel"]
  ],
  "solar_panels": [
    ["4294871270", "ModuleDeployableSolarPanel"]
  ]
}
```

### Cache Validation Strategy
The cache is valid if and only if:
- The cache file exists.
- The stored `vessel_name` matches `SHIP:NAME`.
- The stored `root_uid` matches `SHIP:ROOTPART:UID`.
- The stored `part_count` matches `SHIP:PARTS:LENGTH`.

If a vessel stages parts or docks, the root part UID or the part count will change, invalidating the cache. This is self-healing, as the script will fall back to a full scan and write a fresh cache.

### Performance Gains
Reconstructing lists of `PartModule`s from the cache:
1. Map `SHIP:parts` into a `LEXICON` keyed by `part:UID` (single $O(N)$ pass, no string matching).
2. For each cached item, look up the part by UID in $O(1)$ and fetch the module using `part:getmodule(moduleName)` ($O(1)$).
This reduces the complexity from a nested string-scanning loop to simple dictionary lookups, bypassing interpreted string comparisons.
