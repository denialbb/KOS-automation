@lazyGlobal on.
declare parameter FairingDeployment is false, TargetAltitudeKm is 75,RelativeInclinationDegr is 0, FairingDeploymentAltitudeKm is 60.

set PitchStartVelocity to 100.			//custom value
set TargetRoll to ship:facing:roll +90.
set TargetAltitude to TargetAltitudeKm*1000.
set FairingDeploymentAltitude to FairingDeploymentAltitudeKm*1000.
set RelativeInclination to RelativeInclinationDegr.
set running to true.

clearscreen.

//display info
when true then {
	if not running {
		// cleanup
	} else {
	print "Altitude: "+round(altitude)+" m       " at(0,3).
	print "Apoapsis: "+round(apoapsis)+" m       " at (0,4).
	print "Pitch: "+round(90-vang(ship:up:forevector,ship:facing:forevector))+" degrees       " at(0,5).
	print "Orbital velocity: "+round(ship:velocity:orbit:mag)+" m/s       " at (0,6).
	print "Running: uAscent" at (0,8).
    
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


sas off.
lock throttle to 1.

if maxthrust = 0 {
	stage.
}

//staging
set n to 1.
set InitialStageThrust to maxthrust.
when true then {
	if not running {
		// cleanup
	} else if maxthrust < (InitialStageThrust - 10) or maxthrust = 0 {
	wait 1.
	stage.
		if maxthrust > 0 {
		print "Stage "+n+" separation. Stage "+(n+1)+" ignition." at(0,1).
		
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
        
		set n to n+1.
		set InitialStageThrust to maxthrust.
	}
	preserve.
	} else {
		preserve.
	}
}


//pitch
lock steering to heading((90-RelativeInclination),90,TargetRoll).
print "Ascent Program" at (0,0).

wait until ship:velocity:surface:mag > PitchStartVelocity.
lock TargetPitch to 90-((ship:apoapsis-PitchStartAltitude)*1.4)/((TargetAltitude-PitchStartAltitude)/90).
set PitchStartAltitude to altitude.
lock steering to heading((90-RelativeInclination),TargetPitch,TargetRoll).

wait until TargetPitch < 0.
lock steering to heading(90-RelativeInclination,0,TargetRoll).


//cutoff
wait until ship:apoapsis > TargetAltitude.
	print "Engine cutoff                                  " at(0,1).
	lock throttle to 0.
	unlock steering.
	sas on.
	wait 0.1.
	set sasmode to "PROGRADE".

	set warpmode to "physics".
	set warp to 1.


//fairing
if FairingDeployment = true {
	wait until ship:altitude > FairingDeploymentAltitude.
		stage.
		print "Fairing deployed                        " at(0,1).
}



wait until ship:q = 0.
	set warp to 0.
	unlock steering.
	sas on. // ADDITION: Turn on SAS when coasting to prevent uncontrolled rotation
	wait 0.1.
	set sasmode to "PROGRADE".
	lock throttle to 0. unlock throttle.
	set running to false.
	clearscreen.
	set ship:control:pilotmainthrottle to 0.


