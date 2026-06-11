@LAZYGLOBAL OFF.

RUNONCEPATH("0:/MJ/MJ.ks").

IF NOT mjAvailable() OR NOT ADDONS:MJ:HASSUFFIX("PLANNER") OR NOT ADDONS:MJ:HASSUFFIX("NODE") {
    PRINT "[MJ] MechJeb Planner or Node Executor not supported by this addon version! Falling back to SpaceCore/CircToAp.ks".
    RUNPATH("0:/SpaceCore/CircToAp.ks").
} ELSE {
    LOCAL planner IS ADDONS:MJ:PLANNER.
    LOCAL nodeExecutor IS ADDONS:MJ:NODE.
    LOCAL success IS FALSE.
    
    mjLog("Planning Circularization at Apoapsis").
    
    IF planner:HASSUFFIX("CIRCULARIZE") {
        SET success TO planner:CIRCULARIZE("APOAPSIS").
    } ELSE IF planner:HASSUFFIX("CIRCULARIZEAPOAPSIS") {
        planner:CIRCULARIZEAPOAPSIS().
        SET success TO TRUE.
    }
    
    IF success {
        WAIT UNTIL HASNODE.
        mjLog("Node planned. Executing via MechJeb...").
        
        mjReleaseControl().
        SET nodeExecutor:ENABLED TO TRUE.
        
        UNTIL NOT HASNODE {
            IF NEXTNODE:ETA < 10 {
                mjLog("Executing Node - dV: " + ROUND(NEXTNODE:DELTAV:MAG, 2)).
            }
            WAIT 0.5.
        }
        
        SET nodeExecutor:ENABLED TO FALSE.
        mjLog("Circularization complete.").
    } ELSE {
        mjLog("Could not plan circularization via MechJeb! Falling back to SpaceCore/CircToAp.ks").
        RUNPATH("0:/SpaceCore/CircToAp.ks").
    }
}
