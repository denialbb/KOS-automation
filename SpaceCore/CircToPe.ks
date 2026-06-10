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
	print "Time to periapsis: "+round(eta:periapsis)+"s       " at (0,4).
	print "Running: uCircToPe" at (0,6).

    local r_dist is body:radius + ship:altitude.
    local grav is body:mu / (r_dist * r_dist).
    local twr is 0.
    if availablethrust > 0 and mass > 0 { set twr to availablethrust / (mass * grav). }
    print "--- TELEMETRY ----------" at(0,30).
    print "TWR: " + round(twr, 2) + "        " at(0,31).
    print "Q:   " + round(ship:dynamicpressure, 4) + " kPa   " at(0,32).
    print "EC:  " + round(ship:electriccharge) + "       " at(0,33).

    preserve.
	}
}


//staging
set InitialStageThrust to maxthrust.
when true then {
	if not running {
		// cleanup
	} else if maxthrust < InitialStageThrust {
	wait 1.
	stage.
		if maxthrust > 0 {
		set InitialStageThrust to maxthrust.
	}
	preserve.
	} else {
		preserve.
	}
}


wait until ship:q = 0.
	lock steering to retrograde.
	set TargetV to ((body:mu)/(body:radius+periapsis))^0.5.
	set PeriapsisV to (2*body:mu*((1/(body:radius+periapsis))-(1/orbit:semimajoraxis/2)))^0.5.
	set BurnDeltaV to abs(TargetV-PeriapsisV).
	if availablethrust = 0 {
	    print "Waiting for active engine...".
	    wait until availablethrust > 0.
	}
	set BurnTime to (BurnDeltaV*mass)/availablethrust.

wait 1.
rcs on.
unlock steering.
sas on.
wait 0.1.
set sasmode to "RETROGRADE".
set warpmode to "physics".
set warp to 1.
print "Warping to periapsis" at (0,0).
set BurnMoment to time:seconds + eta:periapsis.
wait until time:seconds >= (BurnMoment-BurnTime/2-WarpStopTime).
set warp to 0.

sas off.
lock steering to retrograde.
wait until vang(ship:facing:forevector,steering:forevector) <  5 and time:seconds > BurnMoment-BurnTime/2.
	set throttle to 1.
	print "Circularization burn started" at (0,0).

wait until TargetV > ship:velocity:orbit:mag.
	set throttle to 0.
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