@LAZYGLOBAL OFF.
parameter targetInc.

IF NOT ADDONS:AVAILABLE("MJ") OR NOT ADDONS:MJ:HASSUFFIX("PLANNER") OR NOT ADDONS:MJ:HASSUFFIX("NODE") {
    PRINT "MechJeb Planner or Node Executor not supported by this addon version! Falling back to SpaceCore/ChangeInc.ks".
    RUNPATH("0:/SpaceCore/ChangeInc.ks", targetInc).
} ELSE {
    print "[MJ] Planning change of Inclination to " + targetInc + " degrees".
    addons:mj:planner:changeinclination(targetInc).
    runpath("0:/MJ/ExeNode.ks").
}
