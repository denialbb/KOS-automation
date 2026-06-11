@LAZYGLOBAL OFF.
PARAMETER targetAp.

IF NOT ADDONS:AVAILABLE("MJ") OR NOT ADDONS:MJ:HASSUFFIX("PLANNER") OR NOT ADDONS:MJ:HASSUFFIX("NODE") {
    PRINT "MechJeb Planner or Node Executor not supported by this addon version! Falling back to SpaceCore/ChangeAp.ks".
    RUNPATH("0:/SpaceCore/ChangeAp.ks", targetAp).
} ELSE {
    PRINT "[MJ] Planning change of Apoapsis to " + targetAp + "km".
    LOCAL targetApM IS targetAp * 1000.
    LOCAL PLANNER IS ADDONS:MJ:PLANNER.
    LOCAL success IS FALSE.
    
    IF PLANNER:HASSUFFIX("CHANGEAP") {
        SET success TO PLANNER:CHANGEAP(targetApM, "PERIAPSIS").
    } ELSE IF PLANNER:HASSUFFIX("CHANGEAPOAPSIS") {
        PLANNER:CHANGEAPOAPSIS(targetApM).
        SET success TO TRUE.
    }
    
    IF success {
        RUNPATH("0:/MJ/ExeNode.ks").
    } ELSE {
        PRINT "WARNING: MechJeb failed to plan Apoapsis change. Falling back to SpaceCore/ChangeAp.ks".
        RUNPATH("0:/SpaceCore/ChangeAp.ks", targetAp).
    }
}
