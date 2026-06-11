@LAZYGLOBAL OFF.
parameter targetPe.

IF NOT ADDONS:AVAILABLE("MJ") OR NOT ADDONS:MJ:HASSUFFIX("PLANNER") OR NOT ADDONS:MJ:HASSUFFIX("NODE") {
    PRINT "MechJeb Planner or Node Executor not supported by this addon version! Falling back to SpaceCore/ChangePe.ks".
    RUNPATH("0:/SpaceCore/ChangePe.ks", targetPe).
} ELSE {
    print "[MJ] Planning change of Periapsis to " + targetPe + "km".
    local targetPeM is targetPe * 1000.
    addons:mj:planner:changeperiapsis(targetPeM).
    runpath("0:/MJ/ExeNode.ks").
}
