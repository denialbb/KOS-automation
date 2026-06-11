@LAZYGLOBAL OFF.

logMsg("Mission Runner Initialized.").

IF NOT (DEFINED mission_sequence) {
    logMsg("CRITICAL ERROR: mission_sequence not defined!").
    logMsg("Switching to basic probe survival routine.").
    RUNPATH("0:/DASA/basic_probe_routine.ks").
}

// Ensure utility background triggers are running
LOCAL lastPowerCheck IS TIME:SECONDS + 60.
LOCAL lastTelemetryUpdate IS 0.

WHEN TIME:SECONDS > lastPowerCheck + 5 THEN {
    SET lastPowerCheck TO TIME:SECONDS.
    checkPower().
    PRESERVE.
}

WHEN TIME:SECONDS > lastTelemetryUpdate + 0.2 THEN {
    LOCAL hasConn IS homeconnection:isconnected.
    IF hasConn <> hadConnection {
        IF hasConn {
            logMsg("--- SIGNAL RESTORED: Reconnected to KSC. ---").
        } ELSE {
            logMsg("--- SIGNAL LOST: Connection to KSC lost. ---").
        }
        SET hadConnection TO hasConn.
    }

    IF telemetryStage = "Ascent" AND NOT maxQLogged {
        LOCAL currentQ IS SHIP:DYNAMICPRESSURE.
        IF currentQ > maxQVal {
            SET maxQVal TO currentQ.
            SET maxQTime TO MISSIONTIME.
        } ELSE IF currentQ < maxQVal - 0.01 AND maxQVal > 0.05 AND MISSIONTIME > maxQTime + 2 {
            SET maxQLogged TO TRUE.
            logMsg("Max Q reached: " + ROUND(maxQVal * 101.325, 2) + " kPa").
        }
    }

    updateTelemetry(telemetryStage).
    SET lastTelemetryUpdate TO TIME:SECONDS.
    PRESERVE.
}

LOCAL aborted IS FALSE.

WHEN ABORT THEN {
    SET aborted TO TRUE.
    setStage("Aborted").
    logMsg("--- MISSION ABORTED ---").
}

// Main execution loop
FOR phase IN mission_sequence {
    IF aborted {
        BREAK.
    }
    LOCAL phasePath IS "0:/DASA/phases/" + phase + ".ks".
    IF EXISTS(phasePath) {
        RUNPATH(phasePath).
    } ELSE {
        logMsg("ERROR: Phase script " + phasePath + " not found!").
    }
}

logMsg("Mission Runner Completed.").
