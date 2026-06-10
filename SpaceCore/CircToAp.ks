@lazyGlobal on.
set WarpStopTime to 30. //custom value

clearscreen.

//display info
set running to true.
when true then {
	if not running {
		// cleanup
	} else {
	print "Apoapsis: "+round(apoapsis)+" m       " at (0,2).
	print "Periapsis: "+round(periapsis)+" m       " at (0,3).
	print "Time to apoapsis: "+round(eta:apoapsis)+"s       " at (0,4).
	print "Running: uCircToAp" at (0,6).
    preserve.
	}
}


//staging
set InitialStageThrust to maxthrust.
when true then {
	if not running {
		// cleanup
	} else if maxthrust < (InitialStageThrust - 10) or maxthrust = 0 {
	wait 1.
	stage.
		if maxthrust > 0 {
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


wait until ship:q = 0.
	lock steering to prograde.
	set TargetV to ((body:mu)/(body:radius+apoapsis))^0.5.
	set ApoapsisV to (2*body:mu*((1/(body:radius+apoapsis))-(1/orbit:semimajoraxis/2)))^0.5.
	set BurnDeltaV to TargetV-ApoapsisV.
	if availablethrust = 0 {
	    print "Waiting for active engine...".
	    wait until availablethrust > 0.
	}
	set BurnTime to (BurnDeltaV*mass)/availablethrust.

wait 1.
rcs on.
unlock steering.
sas on.
set warpmode to "rails".
print "Warping to apoapsis" at (0,0).
set BurnMoment to time:seconds + eta:apoapsis.
warpto(BurnMoment-BurnTime/2-WarpStopTime).

sas off.
lock steering to prograde.
wait until vang(ship:facing:forevector,steering:forevector) <  5 and time:seconds > BurnMoment-BurnTime/2.
	lock throttle to 1.
	print "Circularization burn started" at (0,0).

wait until TargetV < ship:velocity:orbit:mag.
	lock throttle to 0.
	unlock steering.
	rcs off.
	print "Circularization burn completed" at (0,0).
	lock throttle to 0. unlock throttle.
	clearscreen.

rcs off.
sas on.
set running to false.
set ship:control:pilotmainthrottle to 0.
clearscreen.