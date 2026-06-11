DECLARE PARAMETER PreTouchdownAltitude IS 30, ThrottleLevel IS 0.8, LandingVelocity IS 5.	//PreTouchdownAltitude - altitude of center of mass above the ground before TWR=1 descent 

CLEARSCREEN.
SET running TO TRUE.

//display info
WHEN TRUE THEN {
	IF NOT running {
		// cleanup
	} ELSE {
	PRINT "Radar altitude: "+ROUND(alt:radar)+" m       " AT(0,3).
	PRINT "Velocity: "+ROUND(VELOCITY:SURFACE:MAG)+" m/s       " AT (0,4).
	PRINT "Vertical velocity: "+ROUND(verticalspeed)+" m/s       " AT (0,5).
	PRINT "Horizontal velocity: "+ROUND(groundspeed)+" m/s       " AT (0,6).
	PRINT "Running: uLanding" AT (0,8).
    PRESERVE.
	}
}

SAS OFF.
RCS ON.
BRAKES ON.
SET THROTTLE TO 0.
LOCK STEERING TO srfretrograde.


//landing burn start
WAIT UNTIL (SHIP:VELOCITY:SURFACE:MAG^2/(2*alt:radar-PreTouchdownAltitude)+BODY:MU/(BODY:RADIUS+ALTITUDE)^2)*MASS > AVAILABLETHRUST*ThrottleLevel.
	SET THROTTLE TO ThrottleLevel.
	PRINT "Landing burn initiated" AT (0,0).

LOCK THROTTLE TO (SHIP:VELOCITY:SURFACE:MAG^2/(2*(alt:radar-PreTouchdownAltitude))+BODY:MU/(BODY:RADIUS+ALTITUDE)^2)*MASS/AVAILABLETHRUST.


//landing legs deployment
WHEN alt:radar < 700 THEN{
	GEAR ON.
}


//final descent
WAIT UNTIL SHIP:VELOCITY:SURFACE:MAG < LandingVelocity.
	SET TargetRoll TO SHIP:FACING:roll +90.
	LOCK STEERING TO HEADING(90,90,TargetRoll).
	LOCK THROTTLE TO BODY:MU/(BODY:RADIUS+ALTITUDE)^2*MASS/AVAILABLETHRUST.

//landing
WAIT UNTIL STATUS = "LANDED" OR STATUS = "SPLASHED" OR verticalspeed > 0.
	SET THROTTLE TO 0.
	PRINT "Landing completed       " AT (0,0).
	WAIT 5.
	UNLOCK STEERING.
	SAS ON.
	LOCK THROTTLE TO 0. UNLOCK THROTTLE.
	SET running TO FALSE.
	CLEARSCREEN.
	SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.