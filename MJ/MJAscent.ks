@LAZYGLOBAL OFF.

PARAMETER FairingDeployment IS FALSE.
PARAMETER TargetAltitudeKm IS 100.
PARAMETER RelativeInclinationDegr IS 0.
PARAMETER FairingDeploymentAltitudeKm IS 60.
PARAMETER running IS TRUE.

RUNONCEPATH("0:/MJ/MJ.ks").
RUNONCEPATH("0:/DASA/HUD.ks").

IF NOT mjAvailable() {
    PRINT "[MJ] MechJeb not available! Falling back to SpaceCore/Ascent.ks".
    RUNPATH("0:/SpaceCore/Ascent.ks", FairingDeployment, TargetAltitudeKm, RelativeInclinationDegr, FairingDeploymentAltitudeKm).
} ELSE {
    mjLog("Starting MechJeb Ascent...").

    //display info is now handled explicitly in the main loop

    // Configure MechJeb Ascent Autopilot
    LOCAL asc IS ADDONS:MJ:ASCENT.

    IF asc:HASSUFFIX("DESIREDALTITUDE") {
        SET asc:DESIREDALTITUDE TO TargetAltitudeKm * 1000.
    } ELSE IF asc:HASSUFFIX("DSRALT") {
        SET asc:DSRALT TO TargetAltitudeKm * 1000.
    } ELSE IF asc:HASSUFFIX("ORBITALT") {
        SET asc:ORBITALT TO TargetAltitudeKm * 1000.
    }

    IF asc:HASSUFFIX("DESIREDINCLINATION") {
        SET asc:DESIREDINCLINATION TO RelativeInclinationDegr.
    } ELSE IF asc:HASSUFFIX("INC") {
        SET asc:INC TO RelativeInclinationDegr.
    } ELSE IF asc:HASSUFFIX("INCLINATION") {
        SET asc:INCLINATION TO RelativeInclinationDegr.
    }

    IF asc:HASSUFFIX("AUTOSTAGE") {
        SET asc:AUTOSTAGE TO TRUE.
    }

    IF FairingDeployment {
        IF asc:HASSUFFIX("FAIRINGMINALTITUDE") {
            SET asc:FAIRINGMINALTITUDE TO FairingDeploymentAltitudeKm * 1000.
        }
        IF asc:HASSUFFIX("AUTODEPLOYANTENNAS") {
            SET asc:AUTODEPLOYANTENNAS TO TRUE.
        }
        IF asc:HASSUFFIX("AUTODEPLOYSOLARPANELS") {
            SET asc:AUTODEPLOYSOLARPANELS TO TRUE.
        }
    }

    mjReleaseControl().

    mjLog("Engaging Ascent Autopilot").
    SET asc:ENABLED TO TRUE.

    LOCAL isCoasting IS FALSE.
    LOCAL circularizing IS FALSE.
    LOCAL tmo_min IS FALSE.
    LOCAL vessel IS ADDONS:MJ:VESSEL.

    UNTIL SHIP:STATUS = "ORBITING" AND SHIP:ALTITUDE > SHIP:BODY:ATM:HEIGHT {
        LOCAL apo TO SHIP:APOAPSIS.
        LOCAL r_dist IS BODY:RADIUS + SHIP:ALTITUDE.
        LOCAL grav IS BODY:MU / (r_dist * r_dist).
        LOCAL twr IS 0.
        IF AVAILABLETHRUST > 0 AND MASS > 0 { SET twr TO AVAILABLETHRUST / (MASS * grav). }

        HUD_print_header("TELEMETRY").
        HUD_print_ascent(twr, SHIP:DYNAMICPRESSURE, SHIP:VELOCITY:ORBIT:MAG, SHIP:ALTITUDE, apo).


        IF NOT isCoasting AND apo >= TargetAltitudeKm * 1000 * 0.99 {
            mjLog("Apoapsis reached, coasting...").
            SET isCoasting TO TRUE.
        }

        IF NOT two_min AND vessel:ORBITTIMETOAP < 120 {
            mjLog("Approaching circularization burn.").
            logMsg("2 minutes to apoapsis.").
            SET two_min TO TRUE.
        }

        IF NOT circularizing AND SHIP:THRUST > 0 {
            mjLog("Circularizing...").
            logMsg("Circularization Burn start.").
            SET circularizing TO TRUE.
        }

        WAIT 0.5.
    }
    SET running TO FALSE.

    mjLog("Ascent complete. Disabling Ascent Autopilot").
    logMsg("Circularization Burn complete.").
    SET asc:ENABLED TO FALSE.
}
