@LAZYGLOBAL OFF.

GLOBAL FUNCTION safeCoast { // STOPS ONE MINUTE BEFORE TARGET T
    PARAMETER targetTime.
    setStage("Coasting").

    // Point the right/starboard side at the sun by facing 90 degrees away in yaw, and apply targetRoll
    UNTIL TIME:SECONDS >= targetTime - 60 {
        LOCK STEERING TO LOOKDIRUP(SUN:POSITION, SUN:NORTH:VECTOR) * R(0, -90, targetRoll).
        checkPower().
        runAllScience().
        optimizeRoll().

        LOCAL timeLeft IS targetTime - TIME:SECONDS.
        IF timeLeft > 3600 {
            LOCAL nextStop IS MIN(TIME:SECONDS + 3600, targetTime - 60).
            SET WARPMODE TO "rails".
            logMsg("Warping to next stop.").
            WARPTO(nextStop).
            WAIT UNTIL TIME:SECONDS >= nextStop - 5.
        } ELSE IF timeLeft > 300 {
            LOCAL nextStop IS targetTime - 60.
            SET WARPMODE TO "rails".
            logMsg("Warping to next stop.").
            WARPTO(nextStop).
            WAIT UNTIL TIME:SECONDS >= nextStop - 5.
        } ELSE {
            WAIT 1.
        }
    }
    logMsg("Ending Coasting Phase.").
    UNLOCK STEERING.
}
