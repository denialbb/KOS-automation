@LAZYGLOBAL OFF.
parameter targetPe.

if not addons:available("MJ") {
    print "MechJeb Addon not available!".
    abort.
}

print "[MJ] Planning change of Periapsis to " + targetPe + "km".
local targetPeM is targetPe * 1000.
addons:mj:planner:changeperiapsis(targetPeM).

runpath("0:/MJ/ExeNode.ks").
