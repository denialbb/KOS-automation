SET CheckForMovement TO TRUE. //set to false if you want the countdown to run in any situation

CLEARSCREEN.

PRINT "Running: uCountdown" AT (0,2).

SET T TO -10. //custom value



IF CheckForMovement = TRUE {

	IF SHIP:VELOCITY:SURFACE:MAG < 1 {
		UNTIL T>0 {
			PRINT "T"+T+" seconds    " AT(0,0).
			WAIT 1.
			SET T TO T+1.
		}
	}
}


IF CheckForMovement = FALSE {
	UNTIL T>0 {
		PRINT "T"+T+" seconds    " AT(0,0).
		WAIT 1.
		SET T TO T+1.
	}
}

CLEARSCREEN.