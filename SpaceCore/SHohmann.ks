DECLARE PARAMETER Altitude1km, Altitude2km.
SET running TO TRUE.

SET WarpStopTime TO 30.	//custom value

IF Altitude1km > Altitude2km {
	SET TargetAp TO Altitude1km*1000.
	SET TargetPe TO Altitude2km*1000.
}

ELSE {
	SET TargetAp TO Altitude2km*1000.
	SET TargetPe TO Altitude1km*1000.
}


IF TargetAp = TargetPe AND running = TRUE {
    
    SET TargetAlt TO TargetAp.

    IF TargetAlt > APOAPSIS AND running = TRUE {
        RUNPATH("0:/SpaceCore/ChangeAp",TargetAlt/1000).
        RUNPATH("0:/SpaceCore/ChangePe",TargetAlt/1000).
        SET running TO FALSE.
    }

    IF TargetAlt < APOAPSIS AND running = TRUE {
        RUNPATH("0:/SpaceCore/ChangePe",TargetAlt/1000).
        RUNPATH("0:/SpaceCore/ChangeAp",TargetAlt/1000).
        SET running TO FALSE.
    }
}

ELSE {

    IF TargetPe > PERIAPSIS AND running = TRUE{
        RUNPATH("0:/SpaceCore/ChangeAp",TargetAp/1000).
        RUNPATH("0:/SpaceCore/ChangePe",TargetPe/1000).
        SET running TO FALSE.
    }

    IF TargetPe < PERIAPSIS AND running = TRUE{
        RUNPATH("0:/SpaceCore/ChangePe",TargetPe/1000).
        RUNPATH("0:/SpaceCore/ChangeAp",TargetAp/1000).
        SET running TO FALSE. 
    }
}