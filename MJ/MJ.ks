@LAZYGLOBAL OFF.

GLOBAL FUNCTION mjAvailable {
    RETURN ADDONS:AVAILABLE("MJ").
}

GLOBAL FUNCTION mjReleaseControl {
    UNLOCK STEERING.
    UNLOCK THROTTLE.
    SET SHIP:CONTROL:NEUTRALIZE TO TRUE.
}

GLOBAL FUNCTION mjWaitForModule {
    PARAMETER modName.
    PARAMETER timeout.

    LOCAL t0 IS TIME:SECONDS.
    UNTIL ADDONS:MJ:HASMODULE(modName) OR (TIME:SECONDS - t0 > timeout) {
        WAIT 0.5.
    }
    RETURN ADDONS:MJ:HASMODULE(modName).
}

GLOBAL FUNCTION debugLog {
    PARAMETER msg.
    IF DEFINED logMsg {
        logMsg("[DEBUG] " + msg).
    } ELSE {
        PRINT "[DEBUG] " + msg.
    }
}

GLOBAL FUNCTION mjLog {
    PARAMETER msg.
    debugLog("[MJ] " + msg).
}
