@LAZYGLOBAL OFF.
PARAMETER targetPe.

IF NOT ADDONS:AVAILABLE("MJ") OR NOT ADDONS:MJ:HASSUFFIX("PLANNER") OR NOT ADDONS:MJ:HASSUFFIX("NODE") {
    PRINT "MechJeb Planner or Node Executor not supported by this addon version! Falling back to SpaceCore/ChangePe.ks".
    RUNPATH("0:/SpaceCore/ChangePe.ks", targetPe).
} ELSE {
    PRINT "[MJ] Planning change of Periapsis to " + targetPe + "km".
    LOCAL targetPeM IS targetPe * 1000.
    LOCAL PLANNER IS ADDONS:MJ:PLANNER.
    LOCAL success IS FALSE.
    
    IF PLANNER:HASSUFFIX("CHANGEPE") {
        SET success TO PLANNER:CHANGEPE(targetPeM, "APOAPSIS").
    } ELSE IF PLANNER:HASSUFFIX("CHANGEPERIAPSIS") {
        PLANNER:CHANGEPERIAPSIS(targetPeM).
        SET success TO TRUE.
    }
    
    IF success {
        RUNPATH("0:/MJ/ExeNode.ks").
    } ELSE {
        PRINT "WARNING: MechJeb failed to plan Periapsis change. Falling back to SpaceCore/ChangePe.ks".
        RUNPATH("0:/SpaceCore/ChangePe.ks", targetPe).
    }
}
