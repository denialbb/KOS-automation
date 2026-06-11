@LAZYGLOBAL OFF.

PARAMETER FairingDeployment IS FALSE.
PARAMETER TargetAltitudeKm IS 100.
PARAMETER RelativeInclinationDegr IS 0.
PARAMETER FairingDeploymentAltitudeKm IS 60.
PARAMETER running IS TRUE.

RUNONCEPATH("0:/MJ/MJ.ks").

IF NOT mjAvailable() {
    PRINT "[MJ] MechJeb not available! Falling back to SpaceCore/Ascent.ks".
    RUNPATH("0:/SpaceCore/Ascent.ks", FairingDeployment, TargetAltitudeKm, RelativeInclinationDegr, FairingDeploymentAltitudeKm).
} ELSE {
    mjLog("Starting MechJeb Ascent...").

    //display info
    when TRUE then {
	    if not running {
		    // cleanup
	    } else {
        local r_dist is body:radius + ship:altitude.
        local grav is body:mu / (r_dist * r_dist).
        local twr is 0.

        if availablethrust > 0 and mass > 0 { set twr to availablethrust / (mass * grav). }

        print "----------- TELEMETRY ---" at(0,30).
        print "TWR: " + round(twr, 2) + "        " at(0,31).
        print "Q:   " + round(ship:dynamicpressure, 4) + " kPa   " at(0,32).
	    print "Velocity: "+round(ship:velocity:orbit:mag)+" m/s       " at (0,33).
	    print "Altitude: "+round(altitude)+" m       " at(0,34).
	    print "Apoapsis: "+round(apoapsis)+" m       " at (0,35).

        preserve.
        wait 0.1.
	    }
    }

    // Print diagnostic block for available suffixes
    IF ADDONS:MJ:HASSUFFIX("ASCENT") {
        local suffixes is ADDONS:MJ:ASCENT:SUFFIXNAMES:JOIN(", ").
        log suffixes to "0:/logs/MJAscentSuffixes.log".
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
    set running to FALSE.

    mjLog("Ascent complete. Disabling Ascent Autopilot").
    SET asc:ENABLED TO FALSE.
}
