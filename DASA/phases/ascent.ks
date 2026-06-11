@LAZYGLOBAL OFF.

GLOBAL skipDeployment IS FALSE.

IF SHIP:STATUS = "PRELAUNCH" OR SHIP:STATUS = "LANDED" OR (SHIP:STATUS = "FLYING" AND SHIP:ALTITUDE < 70000) {
    setStage("Pre-Launch").
    SAS ON.
    logMsg("Vessel is pre-launch/flying. Waiting for staging to initiate launch.").
    WAIT UNTIL MAXTHRUST > 0.

    logMsg("Launch detected! Ascending to 80km orbit.").
    setStage("Ascent").
    RUNPATH("0:/MJ/MJAscent.ks", FALSE, 80, 0, 60).

    IF SHIP:PERIAPSIS < 70000 {
        logMsg("Circularizing at Apoapsis.").
        setStage("Circularization").
        RUNPATH("0:/MJ/MJCircToAp.ks").
    }
} ELSE {
    IF PANELS {
        SET skipDeployment TO TRUE.
    }
    FOR p IN SHIP:parts {
        HUD_loading().
        FOR m IN p:modules {
            LOCAL mName IS m:tostring:tolower.
            IF mName:contains("solar") OR mName:contains("panel") {
                LOCAL pMod IS p:getmodule(m).
                IF pMod:hasfield("state") {
                    LOCAL st IS pMod:getfield("state"):tolower.
                    IF st:contains("extend") {
                        SET skipDeployment TO TRUE.
                    }
                }
            }
        }
    }
    IF skipDeployment {
        logMsg("Vessel already in orbit with panels active. Skipping jettison & deployment.").
    } ELSE {
        logMsg("Vessel already in orbit. Proceeding with mission.").
        spinload(10).
        spinload_clear().
        CLEARSCREEN.
    }
}
