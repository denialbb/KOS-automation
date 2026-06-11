@LAZYGLOBAL OFF.

PARAMETER FairingDeployment IS FALSE.
PARAMETER TargetAltitudeKm IS 100.
PARAMETER RelativeInclinationDegr IS 0.
PARAMETER FairingDeploymentAltitudeKm IS 60.

RUNONCEPATH("0:/MJ/MJ.ks").

IF NOT mjAvailable() {
    PRINT "[MJ] MechJeb not available! Falling back to SpaceCore/Ascent.ks".
    RUNPATH("0:/SpaceCore/Ascent.ks", FairingDeployment, TargetAltitudeKm, RelativeInclinationDegr, FairingDeploymentAltitudeKm).
} ELSE {
    mjLog("Starting MechJeb Ascent...").
    
    // Print diagnostic block for available suffixes
    IF ADDONS:MJ:HASSUFFIX("ASCENT") {
        mjLog("Ascent Suffixes available: " + ADDONS:MJ:ASCENT:SUFFIXNAMES:JOIN(", ")).
    }
    
    // Configure MechJeb Ascent Autopilot
    IF ADDONS:MJ:ASCENT:HASSUFFIX("ORBITALT") {
        SET ADDONS:MJ:ASCENT:ORBITALT TO TargetAltitudeKm * 1000.
    }
    IF ADDONS:MJ:ASCENT:HASSUFFIX("INCLINATION") {
        SET ADDONS:MJ:ASCENT:INCLINATION TO RelativeInclinationDegr.
    }
    IF ADDONS:MJ:ASCENT:HASSUFFIX("AUTOSTAGE") {
        SET ADDONS:MJ:ASCENT:AUTOSTAGE TO TRUE.
    }
    
    mjReleaseControl().
    
    mjLog("Engaging Ascent Autopilot").
    SET ADDONS:MJ:ASCENT:ENABLED TO TRUE.
    
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
    
    mjLog("Ascent complete. Disabling Ascent Autopilot").
    SET ADDONS:MJ:ASCENT:ENABLED TO FALSE.
}
