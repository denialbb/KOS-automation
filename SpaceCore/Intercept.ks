//WORKS ONLY FOR PROGRADE ORBITS

DECLARE PARAMETER TargetPeriapsisKm IS 200.

SET running TO TRUE.
SET WarpStopTime TO 30. //custom value

SET TPeriapsis TO TargetPeriapsisKm*1000.

CLEARSCREEN.

PRINT "Running: uIntercept" AT (0,7).

PRINT "Set target to proceed" AT (0,0).
WAIT UNTIL hastarget.

UNTIL abs(TARGET:ORBIT:inclination-SHIP:ORBIT:inclination) < 0.11 {
    PRINT "Reduce relative inclination to 0.1 degrees or less to proceed" AT (0,0).
    PRINT "Current relative inclination: " + ROUND(abs(TARGET:ORBIT:inclination-SHIP:ORBIT:inclination),2) + " degrees       " AT (0,3).
}
WAIT 2.
UNTIL abs(TARGET:ORBIT:inclination-SHIP:ORBIT:inclination) < 0.11 {
    PRINT "Reduce relative inclination to 0.1 degrees or less to proceed" AT (0,0).
    PRINT "Current relative inclination: " + ROUND(abs(TARGET:ORBIT:inclination-SHIP:ORBIT:inclination),2) + " degrees       " AT (0,3).
}
CLEARSCREEN.

RCS ON.
SAS OFF.
SET THROTTLE TO 0.

IF ORBIT:eccentricity > 0.05 {
    RUNPATH("0:/SpaceCore/CircToPe").
}

PRINT "Running: uIntercept" AT (0,7).

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


SET TransferSMA TO (MAX(APOAPSIS,TARGET:APOAPSIS)+MIN(PERIAPSIS,TARGET:PERIAPSIS))/2+BODY:RADIUS.
SET TransferTime TO sqrt(4*CONSTANT:pi^2*TransferSMA^3/CONSTANT:g/BODY:MASS)/2.

SET ReqPhaseAngle TO 180-360/TARGET:ORBIT:period*TransferTime.
LOCK ShipAngle TO obt:lan+obt:argumentofperiapsis+obt:trueanomaly.
LOCK TargetAngle TO TARGET:obt:lan+TARGET:obt:argumentofperiapsis+TARGET:obt:trueanomaly.
LOCK PhaseAngle TO TargetAngle-ShipAngle-360*FLOOR((TargetAngle-ShipAngle)/360).
SET PhaseAngleRate TO 360/TARGET:ORBIT:period-360/ORBIT:period.

IF ORBIT:semimajoraxis<TARGET:ORBIT:semimajoraxis {
    LOCK Dir TO PROGRADE.
    LOCK dAngle TO PhaseAngle-ReqPhaseAngle-360*FLOOR((PhaseAngle-ReqPhaseAngle)/360).
}

ELSE {
    LOCK Dir TO RETROGRADE.
    LOCK dAngle TO ReqPhaseAngle-PhaseAngle-360*FLOOR((ReqPhaseAngle-PhaseAngle)/360).
}

LOCK TimeToRPA TO abs(dAngle/PhaseAngleRate).

SET V TO sqrt(BODY:MU/ORBIT:semimajoraxis).
SET TV TO sqrt(2*BODY:MU*((1/(BODY:RADIUS+PERIAPSIS))-(1/TransferSMA/2))).
SET dV TO abs(TV-V).
SET BurnTime TO (dV*MASS)/AVAILABLETHRUST.


WAIT 1.
LOCK STEERING TO Dir.
SET WARPMODE TO "rails".
PRINT "Warping to transfer burn point" AT (0,0).
SET BurnMoment TO TIME:SECONDS + TimeToRPA.
WARPTO(BurnMoment-BurnTime/2-WarpStopTime).

WAIT UNTIL VANG(SHIP:FACING:FOREVECTOR,STEERING:FOREVECTOR) <  5 AND TIME:SECONDS > BurnMoment-BurnTime/2.
	SET THROTTLE TO 1.
    PRINT "Burn started                  " AT (0,0).

WAIT UNTIL SHIP:patches:tostring:contains("ORBIT of "+TARGET:NAME).
    SET THROTTLE TO 0.1.

WAIT UNTIL ORBIT:nextpatch:PERIAPSIS < TPeriapsis OR ORBIT:nextpatch:inclination > 90.
   	SET THROTTLE TO 0.
    PRINT "Burn completed" AT (0,0).

    RCS OFF.
    SAS ON.
	UNLOCK STEERING.
	LOCK THROTTLE TO 0. UNLOCK THROTTLE.
	SET running TO FALSE.
	CLEARSCREEN.
    SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
