@lazyGlobal on.

if not hasnode {
    print "ExeNode: No maneuver node present. Aborting.".
    if defined logMsg { logMsg("ExeNode called with no active maneuver node. Skipping."). }
    abort.
}

if not addons:available("MJ") {
    print "ExeNode: MechJeb Addon not available! Aborting.".
    abort.
}

set nd to nextnode.

clearscreen.
set running to true.
when true then {
    if not running {
        // cleanup
    } else {
        print "[MJ] Node Execution" at (0,2).
        print "Total maneuver delta-V: "+ round(nd:deltav:mag,1)+" m/s       " at (0,3).
        local tLeft is max(0, nd:eta).
        local h is floor(tLeft / 3600).
        local m is floor(mod(tLeft, 3600) / 60).
        local s is floor(mod(tLeft, 60)).
        local hStr is "" + h. if h < 10 { set hStr to "0" + h. }
        local mStr is "" + m. if m < 10 { set mStr to "0" + m. }
        local sStr is "" + s. if s < 10 { set sStr to "0" + s. }
        print "Time to maneuver: T- " + hStr + ":" + mStr + ":" + sStr + "       " at (0,4).
        print "Remaining delta-V: "+round(nd:deltav:mag,1)+" m/s       " at (0,5).
        preserve.
    }
}

// Release kOS steering/throttle
unlock steering.
unlock throttle.
set ship:control:pilotmainthrottle to 0.

print "[MJ] Engaging MechJeb Node Executor...".
set addons:mj:node:enabled to true.

wait until not hasnode.

print "[MJ] Node execution complete.".
set addons:mj:node:enabled to false.
set running to false.
sas on.
clearscreen.