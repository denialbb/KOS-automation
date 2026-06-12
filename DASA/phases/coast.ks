@LAZYGLOBAL OFF.

setStage("Coasting").
spinload(10).
spinload_clear().
logMsg("Transfer burn complete. Coasting to " + TARGET:NAME + " SOI.").
IF SHIP:BODY:NAME = TARGET:NAME {
    logMsg("Already in " + TARGET:NAME + " SOI.").
} ELSE {
    IF ORBIT:HASNEXTPATCH AND ORBIT:NEXTPATCH:BODY:NAME = TARGET:NAME {
        LOCAL timeToSOI IS ETA:TRANSITION.
        safeCoast(TIME:SECONDS + timeToSOI).
        WAIT UNTIL SHIP:BODY:NAME = TARGET:NAME.
        logMsg("Entered " + TARGET:NAME + " SOI!").
    } ELSE {
        logMsg("WARNING: No trajectory to " + TARGET:NAME + " detected. Skipping coast.").
    }
}
