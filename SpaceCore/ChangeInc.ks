@LAZYGLOBAL ON.
SET better TO 1.
DECLARE PARAMETER TInc, WhichNode IS better.    //better if more efficient, closer if faster.

SET WarpStopTime TO 30. //custom value
SET IncAccuracy TO 0.1. //custom value

SET running TO TRUE.
SET closer TO 123.

CLEARSCREEN.

//display info
WHEN TRUE THEN {
	IF NOT running {
		// cleanup
	} ELSE {
	PRINT "Inclination: "+ROUND(ORBIT:inclination,1)+" degrees       " AT (0,2).
	PRINT "Target inclination: "+ROUND(TInc,1)+" degrees       " AT (0,3).
	PRINT "Running: uChangeInc" AT (0,5).
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


//calculations

LOCK Inc TO ORBIT:inclination.

SET ANTrA TO 360-ORBIT:argumentofperiapsis.
SET DNTrA TO ANTrA + 180.
IF DNTrA >= 360 {
    SET DNTrA TO DNTrA-360.
}

SET ANEccA TO 2*arctan(tan(ANTrA/2)/sqrt((1+ORBIT:eccentricity)/(1-ORBIT:eccentricity))).
IF ANEccA<0 {
	SET ANEccA TO ANEccA+360.
}
SET DNEccA TO 2*arctan(tan(DNTrA/2)/sqrt((1+ORBIT:eccentricity)/(1-ORBIT:eccentricity))).
IF DNEccA<0 {
	SET DNEccA TO DNEccA+360.
}

SET ANMA TO ANEccA - ORBIT:eccentricity*sin(ANEccA)*180/CONSTANT:pi.
IF ANMA<0 {
	SET ANMA TO ANMA+360.
}
SET DNMA TO DNEccA - ORBIT:eccentricity*sin(DNEccA)*180/CONSTANT:pi.
IF DNMA<0 {
	SET DNMA TO DNMA+360.
}

SET ANAlt TO ORBIT:semimajoraxis*(1-ORBIT:eccentricity^2)/(1+ORBIT:eccentricity*cos(ANTrA)).
SET DNAlt TO ORBIT:semimajoraxis*(1-ORBIT:eccentricity^2)/(1+ORBIT:eccentricity*cos(DNTrA)).

SET ANV TO sqrt(2*BODY:MU*((1/ANAlt)-(1/ORBIT:semimajoraxis/2))).
SET DNV TO sqrt(2*BODY:MU*((1/DNAlt)-(1/ORBIT:semimajoraxis/2))).

SET ANdV TO 2*sin(abs(TInc-Inc)/2)*ANV.
SET DNdV TO 2*sin(abs(TInc-Inc)/2)*DNV.

SET dV TO MIN(ANdV,DNdV).
SET BurnTime TO (dV*MASS)/AVAILABLETHRUST.

FUNCTION TimeToAN {
    LOCAL TimeToANPure IS SHIP:ORBIT:period/360*(ANMA-ORBIT:meananomalyatepoch).
    IF TimeToANPure<0 {
        SET TimeToANPure TO TimeToANPure + ORBIT:period.
    }

    RETURN TimeToANPure.
}

FUNCTION TimeToDN {
    LOCAL TimeToDNPure IS SHIP:ORBIT:period/360*(DNMA-ORBIT:meananomalyatepoch).
    IF TimeToDNPure<0 {
        SET TimeToDNPure TO TimeToDNPure + ORBIT:period.
    }

    RETURN TimeToDNPure.
}

//burn

RCS ON.
SAS OFF.

IF WhichNode = better {
    IF ANdV<DNdV {
        LOCK STEERING TO VCRS(SHIP:VELOCITY:ORBIT,BODY:position).
	    SET WARPMODE TO "rails".
	    PRINT "Warping to ascending node" AT (0,0).
		SET BurnMoment TO TIME:SECONDS + TimeToAN.
	    WARPTO(BurnMoment-BurnTime/2-WarpStopTime).

	    WAIT UNTIL VANG(SHIP:FACING:FOREVECTOR,STEERING) <  5 AND TIME:SECONDS > BurnMoment-BurnTime/2.
	    	LOCK THROTTLE TO 1.
		    PRINT "Burn started             " AT (0,0).

		WAIT UNTIL abs(TInc-Inc)<=IncAccuracy*10.
	    	LOCK THROTTLE TO 0.1.

	    WAIT UNTIL abs(TInc-Inc)<=IncAccuracy.
	    	LOCK THROTTLE TO 0.
		    PRINT "Burn completed" AT (0,0).
    }

    IF DNdV<ANdV {
        LOCK STEERING TO VCRS(SHIP:VELOCITY:ORBIT,-BODY:position).
	    SET WARPMODE TO "rails".
	    PRINT "Warping to descending node" AT (0,0).
	    SET BurnMoment TO TIME:SECONDS + TimeToDN.
	    WARPTO(BurnMoment-BurnTime/2-WarpStopTime).

	    WAIT UNTIL VANG(SHIP:FACING:FOREVECTOR,STEERING) <  5 AND TIME:SECONDS > BurnMoment-BurnTime/2.
	    	LOCK THROTTLE TO 1.
		    PRINT "Burn started              " AT (0,0).

		WAIT UNTIL abs(TInc-Inc)<=IncAccuracy*10.
	    	LOCK THROTTLE TO 0.1.

	    WAIT UNTIL abs(TInc-Inc)<=IncAccuracy.
	    	LOCK THROTTLE TO 0.
		    PRINT "Burn completed" AT (0,0).
    }
	SET running TO FALSE.
}


IF running = TRUE AND WhichNode = closer {
	IF TimeToAN < TimeToDN {
        LOCK STEERING TO VCRS(SHIP:VELOCITY:ORBIT,BODY:position).
	    SET WARPMODE TO "rails".
	    PRINT "Warping to ascending node" AT (0,0).
	    SET BurnMoment TO TIME:SECONDS + TimeToAN.
	    WARPTO(BurnMoment-BurnTime/2-WarpStopTime).

	    WAIT UNTIL VANG(SHIP:FACING:FOREVECTOR,STEERING) <  5 AND TIME:SECONDS > BurnMoment-BurnTime/2.
	    	LOCK THROTTLE TO 1.
		    PRINT "Burn started             " AT (0,0).

		WAIT UNTIL abs(TInc-Inc)<=IncAccuracy*10.
	    	LOCK THROTTLE TO 0.1.

	    WAIT UNTIL abs(TInc-Inc)<=IncAccuracy.
	    	LOCK THROTTLE TO 0.
		    PRINT "Burn completed" AT (0,0).
    }

    IF TimeToAN > TimeToDN {
        LOCK STEERING TO VCRS(SHIP:VELOCITY:ORBIT,-BODY:position).
	    SET WARPMODE TO "rails".
	    PRINT "Warping to descending node" AT (0,0).
		SET BurnMoment TO TIME:SECONDS + TimeToDN.
	    WARPTO(BurnMoment-BurnTime/2-WarpStopTime).

	    WAIT UNTIL VANG(SHIP:FACING:FOREVECTOR,STEERING) <  5 AND TIME:SECONDS > BurnMoment-BurnTime/2.
	    	LOCK THROTTLE TO 1.
		    PRINT "Burn started              " AT (0,0).

		WAIT UNTIL abs(TInc-Inc)<=IncAccuracy*10.
	    	LOCK THROTTLE TO 0.1.

	    WAIT UNTIL abs(TInc-Inc)<=IncAccuracy.
	    	LOCK THROTTLE TO 0.
		    PRINT "Burn completed" AT (0,0).
    }
}


IF WhichNode <> better AND WhichNode <> closer {
	PRINT "WhichNode parameter has to be 'better' or 'closer'" AT (0,0).
	WAIT 5.
}

LOCK THROTTLE TO 0. UNLOCK THROTTLE.
UNLOCK STEERING.
SET running TO FALSE.
CLEARSCREEN.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.