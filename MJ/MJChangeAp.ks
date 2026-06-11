@LAZYGLOBAL OFF.
parameter targetAp.

IF NOT ADDONS:AVAILABLE("MJ") OR NOT ADDONS:MJ:HASSUFFIX("PLANNER") OR NOT ADDONS:MJ:HASSUFFIX("NODE") {
    PRINT "MechJeb Planner or Node Executor not supported by this addon version! Falling back to SpaceCore/ChangeAp.ks".
    RUNPATH("0:/SpaceCore/ChangeAp.ks", targetAp).
} ELSE {
    print "[MJ] Planning change of Apoapsis to " + targetAp + "km".
    local targetApM is targetAp * 1000.
    addons:mj:planner:changeapoapsis(targetApM).
    runpath("0:/MJ/ExeNode.ks").
}
