@LAZYGLOBAL OFF.
parameter targetAp.

if not addons:available("MJ") {
    print "MechJeb Addon not available!".
    abort.
}

print "[MJ] Planning change of Apoapsis to " + targetAp + "km".
local targetApM is targetAp * 1000.
addons:mj:planner:changeapoapsis(targetApM).

runpath("0:/MJ/ExeNode.ks").
