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


    // Print diagnostic block for available suffixes
    IF ADDONS:MJ:HASSUFFIX("ASCENT") {
        LOCAL suffixes IS ADDONS:MJ:ASCENT:SUFFIXNAMES:JOIN(", ").
        LOG suffixes TO "0:/logs/MJAscentSuffixes.log".
        mjLog("Ascent Suffixes available logged to MJAscentSuffixes.log").
    }

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

    mjReleaseControl().

    mjLog("Engaging Ascent Autopilot").
    SET asc:ENABLED TO TRUE.

    LOCAL fairingDeployed IS FALSE.
    LOCAL isCoasting IS FALSE.

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

        IF FairingDeployment AND NOT fairingDeployed AND SHIP:ALTITUDE > FairingDeploymentAltitudeKm * 1000 {
            mjLog("Deploying Fairing").
            STAGE.
            SET fairingDeployed TO TRUE.
            LOG "T+" + ROUND(MISSIONTIME) + " - Fairing deployed at " + ROUND(SHIP:ALTITUDE/1000,1) + "km" TO "0:/mission_history.log".
        }

        WAIT 0.5.
    }
    SET running TO FALSE.

    mjLog("Ascent complete. Disabling Ascent Autopilot").
    SET asc:ENABLED TO FALSE.
}
