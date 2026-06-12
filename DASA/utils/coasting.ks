@LAZYGLOBAL OFF.

GLOBAL FUNCTION orientForPower {
    logMsg("Orienting solar panels to sun...").
    LOCAL targetDir IS LOOKDIRUP(SUN:POSITION, SUN:NORTH:VECTOR) * R(0, -90, targetRoll).
    LOCK STEERING TO targetDir.
    LOCAL t0 IS TIME:SECONDS.
    WAIT UNTIL (VANG(SHIP:FACING:FOREVECTOR, targetDir:FOREVECTOR) < 2 AND VANG(SHIP:FACING:TOPVECTOR, targetDir:TOPVECTOR) < 2) OR TIME:SECONDS > t0 + 60.
    optimizeRoll().
    checkPower().
    runAllScience().
    UNLOCK STEERING.
}

GLOBAL FUNCTION safeCoast {
    PARAMETER targetTime.
    setStage("Coasting").

    orientForPower().

    LOCAL timeLeft IS targetTime - TIME:SECONDS.
    IF timeLeft > 60 {
        logMsg("Warping to target time...").
        SET WARPMODE TO "rails".
        WARPTO(targetTime - 60).
        WAIT UNTIL TIME:SECONDS >= targetTime - 65.
    }
    
    logMsg("Ending Coasting Phase.").
}
