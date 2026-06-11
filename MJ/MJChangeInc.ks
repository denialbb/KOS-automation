@LAZYGLOBAL OFF.
parameter targetInc.

if not addons:available("MJ") {
    print "MechJeb Addon not available!".
    abort.
}

print "[MJ] Planning change of Inclination to " + targetInc + " degrees".
addons:mj:planner:changeinclination(targetInc).

runpath("0:/MJ/ExeNode.ks").
