# Solar Optimization and Debugging Breakthroughs

## 1. Modded Solar Panels and kOS
When working with mods that overhaul power systems (like Kerbalism or Kopernicus), standard KSP solar panel modules (`ModuleDeployableSolarPanel`) often have their native fields completely hidden or removed. 

**The UI is a Lie:** Even if the right-click part UI window displays metrics like "Solar Panel EC" or "exposure 93%", this data is often dynamically drawn into the UI window by the mod's code and is **not** exposed as a standard `KSPField`. 
Because of this, `pMod:HASFIELD("energy flow")` or `"sun exposure"` will completely fail to find anything on the module, returning empty lists and crashing scripts that rely on finding these fields.

## 2. The `SHIP:SENSORS:LIGHT` Trick
To bypass the nightmare of parsing custom module fields for different mods, kOS provides a native environmental sensor: `SHIP:SENSORS:LIGHT`.

This suffix natively aggregates the total solar intensity/wattage hitting **all** functional solar panels on the entire vessel. 
- It works universally, regardless of the mod installed.
- It returns `0` if the panels are in shadow or retracted.
- It provides a single, clean floating-point number representing the current power generation capacity of the vessel's solar array.
- Using this eliminates the need to cache and loop through individual solar panel modules for power optimization!

## 3. How to Debug Interactable Fields
If you ever need to see exactly what kOS can natively see and interact with on a part, do **not** use `pMod:ALLFIELDS`. 

In kOS, `ALLFIELDS` returns a list of string representations that include type information (e.g., `"(settable) solar panel, is String"`). If you try to iterate over this list and pass those strings into `GETFIELD()`, the script will immediately crash because a field with that literal type-infused string does not exist.

**The Solution:** Always use `pMod:ALLFIELDNAMES` (and `ALLEVENTNAMES` / `ALLACTIONNAMES`).
This returns a clean list of strings containing exactly the names of the fields, which can safely be fed directly into `pMod:GETFIELD()`.

### Example Debug Script
```kerboscript
FOR p IN SHIP:parts {
    IF p:TITLE:CONTAINS("TargetPart") {
        PRINT "Found Part: " + p:TITLE.
        FOR mStr IN p:MODULES {
            LOCAL m IS p:GETMODULE(mStr).
            PRINT "  Module: " + m:NAME.
            FOR f IN m:ALLFIELDNAMES {
                PRINT "      - '" + f + "' = " + m:GETFIELD(f).
            }
        }
    }
}
```

## 4. Detecting Planetary Shadow
Before running power-draining solar optimization sweeps, it's critical to determine if the sun is actually occluded by a celestial body. 

This can be calculated geometrically by comparing the angle between the Sun and the Body to the angular radius of the Body:
```kerboscript
LOCAL angToBody IS VANG(SUN:POSITION, BODY:POSITION).
LOCAL bodyAngularRadius IS ARCSIN(BODY:RADIUS / BODY:DISTANCE).
IF angToBody < bodyAngularRadius {
    // The sun is blocked by the planet!
}
```
