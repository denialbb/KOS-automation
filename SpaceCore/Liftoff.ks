SET TimeAfterIgnition TO 3.		//custom value

CLEARSCREEN.

PRINT "Running: uLiftoff" AT (0,2).

IF MAXTHRUST=0 {STAGE.}
SET THROTTLE TO 1.
PRINT "Ignition          " AT (0,0).

WAIT TimeAfterIgnition.
IF SHIP:VELOCITY:SURFACE:MAG < 1 {STAGE.}
PRINT "Liftoff!          " AT (0,0).
WAIT 3.
CLEARSCREEN.