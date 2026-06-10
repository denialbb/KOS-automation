@lazyGlobal on.
set WarpStopTime to 30. //custom value

set nd to nextnode.
if availablethrust = 0 {
    print "Waiting for active engine...".
    wait until availablethrust > 0.
}
set BurnTime to (nd:deltav:mag*mass)/availablethrust.
set NodedV0 to nd:deltav.

clearscreen.

//display info
set running to true.
when true then {
	if not running {
		// cleanup
	} else {
    print "Total maneuver delta-V: "+ round(NodedV0:mag,1)+" m/s       " at (0,3).
    print "Remaining maneuver delta-V: "+round(nd:deltav:mag,1)+" m/s       " at (0,4).
    local tLeft is max(0, nd:eta).
    local h is floor(tLeft / 3600).
    local m is floor(mod(tLeft, 3600) / 60).
    local s is floor(mod(tLeft, 60)).
    local hStr is "" + h. if h < 10 { set hStr to "0" + h. }
    local mStr is "" + m. if m < 10 { set mStr to "0" + m. }
    local sStr is "" + s. if s < 10 { set sStr to "0" + s. }
    print "Time to maneuver: T- " + hStr + ":" + mStr + ":" + sStr + "       " at (0,5).
    print "Running: uExeNode" at (0,7).
    preserve.
	}
}


rcs on.
sas off.
lock throttle to 0.


//staging
set InitialStageThrust to maxthrust.
when true then {
	if not running {
		// cleanup
	} else if maxthrust < (InitialStageThrust - 10) or maxthrust = 0 {
	wait 1.
	stage.
		if maxthrust > 0 {
        logMsg("Stage separated during node execution").
        local ec is 0.
        local ecMax is 1.
        for r in ship:resources {
            if r:name = "ElectricCharge" {
                set ec to r:amount.
                set ecMax to max(0.1, r:capacity).
            }
        }
        local ecPct is round((ec/ecMax)*100, 1).
        local histFile is "0:/mission_history.log".
        if exists(histFile) {
            log round(missiontime) + ",Staging," + ship:body:name + "," + round(ship:altitude) + "," + round(ship:periapsis) + "," + round(ship:apoapsis) + "," + round(ship:orbit:inclination, 1) + "," + ecPct + "," + round(ship:velocity:orbit:mag) to histFile.
        }
		set InitialStageThrust to maxthrust.
	}
	preserve.
	} else {
		preserve.
	}
}


wait 1.
lock steering to nd:deltav.
set warpmode to "rails".
print "Warping to burn point" at (0,0).
set BurnMoment to time:seconds + nd:eta.
warpto(BurnMoment-BurnTime/2-WarpStopTime).

wait until vang(ship:facing:forevector,steering) <  1 and time:seconds > BurnMoment-BurnTime/2.
	lock throttle to 1.
    print "Burn started                  " at (0,0).

wait until nd:deltav:mag/NodedV0:mag < 0.05.
    lock throttle to 0.1.

wait until vdot(NodedV0, nd:deltav) < 0.
   	lock throttle to 0.
    print "Burn completed" at (0,0).

    rcs off.
    sas on.
	unlock steering.
	lock throttle to 0. unlock throttle.
    remove nd.
    set running to false.
	clearscreen.
    set ship:control:pilotmainthrottle to 0.