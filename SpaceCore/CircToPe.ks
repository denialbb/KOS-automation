SET WarpStopTime TO 30. //custom value

CLEARSCREEN.

//display info
SET running TO TRUE.
WHEN TRUE THEN {
	IF NOT running {
		// cleanup
	} ELSE {
	PRINT "Apoapsis: "+ROUND(APOAPSIS)+" m       " AT (0,2).
	PRINT "Periapsis: "+ROUND(PERIAPSIS)+" m       " AT (0,3).
	PRINT "Time to periapsis: "+ROUND(ETA:PERIAPSIS)+"s       " AT (0,4).
	PRINT "Running: uCircToPe" AT (0,6).

    LOCAL r_dist IS BODY:RADIUS + SHIP:ALTITUDE.
    LOCAL grav IS BODY:MU / (r_dist * r_dist).
    LOCAL twr IS 0.
    IF AVAILABLETHRUST > 0 AND MASS > 0 { SET twr TO AVAILABLETHRUST / (MASS * grav). }
    PRINT "--- TELEMETRY ----------" AT(0,30).
    PRINT "TWR: " + ROUND(twr, 2) + "        " AT(0,31).
    PRINT "Q:   " + ROUND(SHIP:DYNAMICPRESSURE, 4) + " kPa   " AT(0,32).
    PRINT "EC:  " + ROUND(SHIP:ELECTRICCHARGE) + "       " AT(0,33).

    PRESERVE.
	}
}


//staging
SET InitialStageThrust TO MAXTHRUST.
WHEN TRUE THEN {
	IF NOT running {
		// cleanup
	} ELSE IF MAXTHRUST < InitialStageThrust {
	WAIT 1.
	STAGE.
		IF MAXTHRUST > 0 {
		SET InitialStageThrust TO MAXTHRUST.
	}
	PRESERVE.
	} ELSE {
		PRESERVE.
	}
}


WAIT UNTIL SHIP:Q = 0.
	LOCK STEERING TO RETROGRADE.
	SET TargetV TO ((BODY:MU)/(BODY:RADIUS+PERIAPSIS))^0.5.
	SET PeriapsisV TO (2*BODY:MU*((1/(BODY:RADIUS+PERIAPSIS))-(1/ORBIT:semimajoraxis/2)))^0.5.
	SET BurnDeltaV TO abs(TargetV-PeriapsisV).
	IF AVAILABLETHRUST = 0 {
	    PRINT "Waiting for active engine...".
	    WAIT UNTIL AVAILABLETHRUST > 0.
	}
	SET BurnTime TO (BurnDeltaV*MASS)/AVAILABLETHRUST.

WAIT 1.
RCS ON.
UNLOCK STEERING.
SAS ON.
WAIT 0.1.
SET sasmode TO "RETROGRADE".
SET WARPMODE TO "physics".
SET warp TO 1.
PRINT "Warping to periapsis" AT (0,0).
SET BurnMoment TO TIME:SECONDS + ETA:PERIAPSIS.
WAIT UNTIL TIME:SECONDS >= (BurnMoment-BurnTime/2-WarpStopTime).
SET warp TO 0.

SAS OFF.
LOCK STEERING TO RETROGRADE.
WAIT UNTIL VANG(SHIP:FACING:FOREVECTOR,STEERING:FOREVECTOR) <  5 AND TIME:SECONDS > BurnMoment-BurnTime/2.
	SET THROTTLE TO 1.
	PRINT "Circularization burn started" AT (0,0).

WAIT UNTIL TargetV > SHIP:VELOCITY:ORBIT:MAG.
	SET THROTTLE TO 0.
	UNLOCK STEERING.
	RCS OFF.
	PRINT "Circularization burn completed" AT (0,0).
	LOCK THROTTLE TO 0. UNLOCK THROTTLE.
	CLEARSCREEN.

RCS OFF.
SAS ON.
SET running TO FALSE.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
CLEARSCREEN.