@LAZYGLOBAL OFF.

setStage("Coasting").
spinload(10).
spinload_clear().
logMsg("Transfer burn complete. Coasting to " + TARGET:NAME + " SOI.").
WAIT UNTIL ORBIT:hasnextpatch AND ORBIT:nextpatch:BODY:NAME = TARGET:NAME.
LOCAL timeToSOI IS ETA:TRANSITION.
safeCoast(TIME:SECONDS + timeToSOI).

WAIT UNTIL SHIP:BODY:NAME = TARGET:NAME.
logMsg("Entered " + TARGET:NAME + " SOI!").
