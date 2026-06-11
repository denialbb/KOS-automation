@LAZYGLOBAL OFF.
PARAMETER targetInc.

IF NOT ADDONS:AVAILABLE("MJ") OR NOT ADDONS:MJ:HASSUFFIX("PLANNER") OR NOT ADDONS:MJ:HASSUFFIX("NODE") {
    PRINT "MechJeb Planner or Node Executor not supported by this addon version! Falling back to SpaceCore/ChangeInc.ks".
    RUNPATH("0:/SpaceCore/ChangeInc.ks", targetInc).
} ELSE {
    PRINT "[MJ] Planning change of Inclination to " + targetInc + " degrees".
    LOCAL PLANNER IS ADDONS:MJ:PLANNER.
    LOCAL success IS FALSE.
    
    IF PLANNER:HASSUFFIX("CHANGEINCLINATION") {
        PLANNER:CHANGEINCLINATION(targetInc).
        SET success TO TRUE.
    }
    
    IF success {
        RUNPATH("0:/MJ/ExeNode.ks").
    } ELSE {
        PRINT "WARNING: MechJeb inclination change not supported by this addon version. Falling back to SpaceCore/ChangeInc.ks".
        RUNPATH("0:/SpaceCore/ChangeInc.ks", targetInc).
    }
}
