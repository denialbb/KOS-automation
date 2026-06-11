@LAZYGLOBAL OFF.

RUNONCEPATH("0:/DASA/utils/cache.ks").

IF NOT skipDeployment {
    LOCAL fairingModules IS LIST().
    LOCAL deployableModules IS LIST().
    LOCAL solarPanelsLocal IS LIST().

    IF isCacheValid() {
        loadDeployablesFromCache(fairingModules, deployableModules, solarPanelsLocal).
    } ELSE {
        // Walk the parts tree once to categorize all modules
        FOR p IN SHIP:parts {
            HUD_loading().
            LOCAL pName IS p:NAME:tolower.
            LOCAL pTitle IS p:title:tolower.
            LOCAL isAntennaOrPanelPart IS FALSE.
            IF pName:contains("solar") OR pName:contains("panel") OR pName:contains("antenna")
               OR pName:contains("dish") OR pName:contains("comm") OR pName:contains("trans")
               OR pName:contains("ray") OR pName:contains("reflector") {
                SET isAntennaOrPanelPart TO TRUE.
            }
            IF pTitle:contains("solar") OR pTitle:contains("panel") OR pTitle:contains("antenna")
               OR pTitle:contains("dish") OR pTitle:contains("comm") OR pTitle:contains("trans")
               OR pTitle:contains("ray") OR pTitle:contains("reflector") {
                SET isAntennaOrPanelPart TO TRUE.
            }

            FOR m IN p:modules {
                LOCAL mName IS m:tostring:tolower.
                LOCAL pMod IS p:getmodule(m).

                // Fairings
                IF mName:contains("fairing") OR mName:contains("jettison") OR mName:contains("shroud") {
                    fairingModules:ADD(pMod).
                }

                // Deployables
                LOCAL isDeployableModule IS FALSE.
                IF mName:contains("solar") OR mName:contains("panel") OR mName:contains("antenna")
                   OR mName:contains("transmit") OR mName:contains("comm") OR mName:contains("animate")
                   OR mName:contains("deploy") OR mName:contains("dish") OR mName:contains("boom") {
                    SET isDeployableModule TO TRUE.
                }
                IF isAntennaOrPanelPart OR isDeployableModule {
                    deployableModules:ADD(pMod).
                }

                // Solar Panels for Optimization
                IF mName:contains("deployablesolarpanel") OR mName:contains("solar") {
                    IF pMod:HASFIELD("energy flow") {
                        solarPanelsLocal:ADD(pMod).
                    }
                }
            }
        }
        saveDeployablesCache(fairingModules, deployableModules, solarPanelsLocal).
    }

    logMsg("Jettisoning all fairings...").
    FOR pMod IN fairingModules {
        FOR ev IN pMod:alleventnames {
            LOCAL evLower IS ev:tolower.
            IF evLower:contains("deploy") OR evLower:contains("jettison") OR evLower:contains("open") OR evLower:contains("release") {
                pMod:doevent(ev).
                logMsg("Jettisoned fairing: " + ev + " on " + pMod:part:title).
                HUD_loading().
            }
        }
    }

    spinload(10). // Wait for fairing separation physics

    logMsg("Deploying solar panels, bays, and antennas.").
    PANELS ON.
    bays ON.

    FOR pMod IN deployableModules {
        FOR ev IN pMod:alleventnames {
            LOCAL evLower IS ev:tolower.
            IF evLower:contains("extend") OR evLower:contains("deploy") OR evLower:contains("open")
               OR evLower:contains("activate") OR evLower:contains("toggle") OR evLower:contains("start") {
                IF NOT (evLower:contains("retract") OR evLower:contains("close") OR evLower:contains("stop")
                        OR evLower:contains("disable") OR evLower:contains("shutdown") OR evLower:contains("jettison")) {
                    pMod:doevent(ev).
                    logMsg(pMod:part:title + ": " + ev).
                    HUD_loading().
                }
            }
        }
    }
}
spinload_clear().
