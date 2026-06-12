@LAZYGLOBAL ON.
DECLARE PARAMETER FairingDeployment IS FALSE, TargetAltitudeKm IS 75,RelativeInclinationDegr IS 0, FairingDeploymentAltitudeKm IS 60.

SET PitchStartVelocity TO 100.			//custom value
SET TargetRoll TO SHIP:FACING:roll +90.
SET TargetAltitude TO TargetAltitudeKm*1000.
SET FairingDeploymentAltitude TO FairingDeploymentAltitudeKm*1000.
SET RelativeInclination TO RelativeInclinationDegr.
SET running TO TRUE.

CLEARSCREEN.

//display info
WHEN TRUE THEN {
	IF NOT running {
		// cleanup
	} ELSE {
	PRINT "Altitude: "+ROUND(ALTITUDE)+" m       " AT(0,3).
	PRINT "Apoapsis: "+ROUND(APOAPSIS)+" m       " AT (0,4).
	PRINT "Pitch: "+ROUND(90-VANG(SHIP:UP:FOREVECTOR,SHIP:FACING:FOREVECTOR))+" degrees       " AT(0,5).
	PRINT "Orbital velocity: "+ROUND(SHIP:VELOCITY:ORBIT:MAG)+" m/s       " AT (0,6).
	PRINT "Running: uAscent" AT (0,8).

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


SAS OFF.
LOCK THROTTLE TO 1.

IF MAXTHRUST = 0 {
	STAGE.
    PRINT "Stage " + stage_num + " separation".
	SET stage_num TO stage_num + 1.
    PRINT "Stage " + stage_num + " ignition".
}

//staging
SET n TO 1.
SET InitialStageThrust TO MAXTHRUST.
WHEN TRUE THEN {
	IF NOT running {
		// cleanup
	} ELSE IF MAXTHRUST < (InitialStageThrust - 10) OR MAXTHRUST = 0 {
	WAIT 1.
	STAGE.
		IF MAXTHRUST > 0 {
		PRINT "Stage "+n+" separation. Stage "+(n+1)+" ignition." AT(0,1).
        PRINT "Stage " + n + " separation.".

        LOCAL ec IS 0.
        LOCAL ecMax IS 1.
        FOR r IN SHIP:RESOURCES {
            IF r:NAME = "ElectricCharge" {
                SET ec TO r:AMOUNT.
                SET ecMax TO MAX(0.1, r:CAPACITY).
            }
        }
        LOCAL ecPct IS ROUND((ec/ecMax)*100, 1).
        LOCAL histFile IS "0:/logs/mission_history.log".
        IF EXISTS(histFile) {
            LOG ROUND(MISSIONTIME) + ",Staging," + SHIP:BODY:NAME + "," + ROUND(SHIP:ALTITUDE) + "," + ROUND(SHIP:PERIAPSIS) + "," + ROUND(SHIP:APOAPSIS) + "," + ROUND(SHIP:ORBIT:inclination, 1) + "," + ecPct + "," + ROUND(SHIP:VELOCITY:ORBIT:MAG) TO histFile.
        }

		SET n TO n+1.
		SET InitialStageThrust TO MAXTHRUST.
	}
	PRESERVE.
	} ELSE {
		PRESERVE.
	}
}


//pitch
LOCK STEERING TO HEADING((90-RelativeInclination),90,TargetRoll).
PRINT "Ascent Program" AT (0,0).

WAIT UNTIL SHIP:VELOCITY:SURFACE:MAG > PitchStartVelocity.
SET PitchStartAltitude TO ALTITUDE.
LOCK TargetPitch TO 90-((SHIP:APOAPSIS-PitchStartAltitude)*1.4)/((TargetAltitude-PitchStartAltitude)/90).
LOCK STEERING TO HEADING((90-RelativeInclination),TargetPitch,TargetRoll).

WAIT UNTIL TargetPitch < 0.
LOCK STEERING TO HEADING(90-RelativeInclination,0,TargetRoll).


//cutoff
WAIT UNTIL SHIP:APOAPSIS > TargetAltitude.
	PRINT "Engine cutoff                                  " AT(0,1).
	LOCK THROTTLE TO 0.
	UNLOCK STEERING.
	SAS ON.
	WAIT 0.1.
	SET sasmode TO "PROGRADE".

	SET WARPMODE TO "physics".
	SET warp TO 1.


//fairing
IF FairingDeployment = TRUE {
	WAIT UNTIL SHIP:ALTITUDE > FairingDeploymentAltitude.
		STAGE.
		PRINT "Fairing deployed                        " AT(0,1).
}



WAIT UNTIL SHIP:Q = 0.
	SET warp TO 0.
	UNLOCK STEERING.
	SAS ON. // ADDITION: Turn on SAS when coasting to prevent uncontrolled rotation
	WAIT 0.1.
	SET sasmode TO "PROGRADE".
	LOCK THROTTLE TO 0. UNLOCK THROTTLE.
	SET running TO FALSE.
	CLEARSCREEN.
	SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.


