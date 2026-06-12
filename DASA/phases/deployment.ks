@LAZYGLOBAL OFF.

RUNONCEPATH("0:/DASA/utils/cache.ks").

IF NOT skipDeployment {
    initDeployablesCache().

    logMsg("Jettisoning all fairings...").
    FOR pMod IN cachedFairings {
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

    FOR pMod IN cachedDeployables {
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
