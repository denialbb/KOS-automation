@LAZYGLOBAL OFF.

RUNONCEPATH("0:/MJ/MJ.ks").

IF NOT mjAvailable() {
    PRINT "[MJ] MechJeb not available! Falling back to SpaceCore/CircToAp.ks".
    RUNPATH("0:/SpaceCore/CircToAp.ks").
} ELSE {
    mjLog("Planner Suffixes: " + ADDONS:MJ:PLANNER:SUFFIXNAMES:JOIN(", ")).
    mjLog("Planning Circularization at Apoapsis").
    
    // According to kOS.MechJeb2.Addon, ADDONS:MJ:PLANNER has CIRCULARIZEAPOAPSIS or similar.
    IF ADDONS:MJ:PLANNER:HASSUFFIX("CIRCULARIZEAPOAPSIS") {
        ADDONS:MJ:PLANNER:CIRCULARIZEAPOAPSIS().
    } ELSE IF ADDONS:MJ:PLANNER:HASSUFFIX("CIRCULARIZE") {
        // Fallback or other possible name
        ADDONS:MJ:PLANNER:CIRCULARIZE("AP").
    } ELSE {
        mjLog("Could not find circularize suffix!").
    }
    
    WAIT UNTIL HASNODE.
    mjLog("Node planned. Executing via MechJeb...").
    
    mjReleaseControl().
    SET ADDONS:MJ:NODE:ENABLED TO TRUE.
    
    UNTIL NOT HASNODE {
        IF NEXTNODE:ETA < 10 {
            mjLog("Executing Node - dV: " + ROUND(NEXTNODE:DELTAV:MAG, 2)).
        }
        WAIT 0.5.
    }
    
    SET ADDONS:MJ:NODE:ENABLED TO FALSE.
    mjLog("Circularization complete.").
}
