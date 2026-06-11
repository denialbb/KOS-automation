DECLARE PARAMETER TargetAltitudeKm.     //altitude of one of the apsis of target orbit (the second one is semi-major axis of the body you are departing from)

SET running TO TRUE.
SET WarpStopTime TO 30. //custom value

SET TargetAlt TO TargetAltitudeKm*1000.

IF ORBIT:inclination > 10 {
    RUNPATH("0:/SpaceCore/ChangeInc",0).
}

IF ORBIT:eccentricity > 0.05 {
    RUNPATH("0:/SpaceCore/CircToPe").
}

CLEARSCREEN.
PRINT "Running: uEject" AT (0,7).

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



//calculations

FUNCTION BPA {       //body prograde angle - basically what has to be equal to an ejection angle
    LOCAL BPAPure IS 90-(BODY:ORBIT:VELOCITY:ORBIT:direction-VELOCITY:ORBIT:direction):yaw.
    IF BPAPure < 0 {
        SET BPAPure TO BPAPure + 360.
    }
    RETURN BPAPure.
}


SET TargetV TO sqrt(2*(BODY:BODY:MU/BODY:ORBIT:semimajoraxis-BODY:BODY:MU/(TargetAlt+BODY:BODY:RADIUS+BODY:ORBIT:semimajoraxis))).
SET BodyV TO abs(TargetV-BODY:ORBIT:VELOCITY:ORBIT:MAG).
SET SpecMechEnEsc TO BodyV^2/2-BODY:MU/BODY:soiradius. 
SET VDep TO sqrt(2*(BODY:MU/ORBIT:semimajoraxis+SpecMechEnEsc)).
SET EscV TO sqrt(2*(BODY:MU/ORBIT:semimajoraxis-BODY:MU/(ORBIT:semimajoraxis+BODY:soiradius))).
IF EscV > VDep {
    SET VDep TO EscV.
}
SET EjdV TO VDep-VELOCITY:ORBIT:MAG.
SET BurnTime TO (EjdV*MASS)/AVAILABLETHRUST.


SET SpecMechEn TO VDep^2/2-BODY:MU/ORBIT:semimajoraxis.
SET HypSMA TO -BODY:MU/2/SpecMechEn.
SET Ecc TO 1-ORBIT:semimajoraxis/HypSMA.
SET EjAngle TO arcsin(1/Ecc)+90.
IF TargetAlt+BODY:BODY:RADIUS < BODY:ORBIT:semimajoraxis {
    SET EjAngle TO EjAngle+180.
}

IF EjAngle > 360 {
    SET EjAngle TO 360-EjAngle.
}


SET TAOffset TO BPA-(360-ORBIT:trueanomaly).
IF TAOffset < 0 {
    SET TAOffset TO TAOffset+360.
}

SET EjTA TO 360-(EjAngle-TAOffset).
IF EjTA < 0 {
    SET EjTa TO EjTa+360.
}

SET EjEccA TO 2*arctan(tan(EjTA/2)/sqrt((1+ORBIT:eccentricity)/(1-ORBIT:eccentricity))).
IF EjEccA<0 {
	SET EjEccA TO EjEccA+360.
}

SET EjMA TO EjEccA - ORBIT:eccentricity*sin(EjEccA)*180/CONSTANT:pi.
IF EjMA<0 {
	SET EjMA TO EjMA+360.
}


SET TimeToBurn TO SHIP:ORBIT:period/360*(EjMA-ORBIT:meananomalyatepoch).
IF TimeToBurn<0 {
    SET TimeToBurn TO TimeToBurn + ORBIT:period.
}




//burn

CLEARSCREEN.
RCS ON.
SAS OFF.

WAIT 1.
LOCK STEERING TO PROGRADE.
SET WARPMODE TO "rails".
PRINT "Warping to burn moment" AT (0,0).
SET BurnMoment TO TIME:SECONDS + TimeToBurn.
WARPTO(BurnMoment-BurnTime/2-WarpStopTime).

WAIT UNTIL VANG(SHIP:FACING:FOREVECTOR,STEERING:FOREVECTOR) <  5 AND TIME:SECONDS > BurnMoment-BurnTime/2.
	SET THROTTLE TO 1.
    PRINT "Burn started                  " AT (0,0).


IF TargetAlt < BODY:ALTITUDE + BODY:BODY:RADIUS {
    WAIT UNTIL SHIP:patches:tostring:contains("ORBIT of "+BODY:BODY:NAME) AND ORBIT:nextpatch:PERIAPSIS < TargetAlt.
}

IF TargetAlt > BODY:ALTITUDE + BODY:BODY:RADIUS {
    WAIT UNTIL SHIP:patches:tostring:contains("ORBIT of "+BODY:BODY:NAME) AND ORBIT:nextpatch:APOAPSIS > TargetAlt.
}


SET THROTTLE TO 0.
PRINT "Burn completed" AT (0,0).

RCS OFF.
SAS ON.
UNLOCK STEERING.
LOCK THROTTLE TO 0. UNLOCK THROTTLE.
SET running TO FALSE.
CLEARSCREEN.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
