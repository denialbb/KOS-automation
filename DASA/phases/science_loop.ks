@LAZYGLOBAL OFF.

RUNONCEPATH("0:/DASA/utils/cache.ks").

GLOBAL FUNCTION runScienceLoop {
    logMsg("Initializing Science Loop...").
    initDeployablesCache().

    UNTIL FALSE {
        logMsg("--- Science Collection Cycle Start ---").
        
        LOCAL numTransmissions IS 0.
        LOCAL numActivations IS 0.
        
        // Ensure antennas are deployed for transmission
        FOR pMod IN cachedDeployables {
            FOR ev IN pMod:alleventnames {
                LOCAL evLower IS ev:tolower.
                IF evLower:contains("extend") OR evLower:contains("deploy") OR evLower:contains("open") {
                    IF NOT (evLower:contains("retract") OR evLower:contains("close")) {
                        pMod:doevent(ev).
                    }
                }
            }
        }
        
        FOR pMod IN cachedExperiments {
            logDebug("Debugging events for " + pMod:part:title + ":").
            FOR ev IN pMod:alleventnames {
                IF ev <> "_" {
                    logDebug(" - Event: " + ev).
                }
            }
            
            FOR ev IN pMod:alleventnames {
                LOCAL evLower IS ev:tolower.
                
                // Transmit data first to free up space
                IF evLower:contains("transmit") OR evLower:contains("send") {
                    logMsg("Transmitting data: " + ev + " on " + pMod:part:title).
                    pMod:doevent(ev).
                    SET numTransmissions TO numTransmissions + 1.
                }
            }
            
            // Short wait to allow transmission to start/finish
            WAIT 1.
            
            FOR ev IN pMod:alleventnames {
                LOCAL evLower IS ev:tolower.
                
                // Deploy / Start experiments
                IF evLower:contains("deploy") OR evLower:contains("start") OR evLower:contains("run") OR evLower:contains("observ") OR evLower:contains("log") OR evLower:contains("perform") OR evLower:contains("take") OR evLower:contains("scan") {
                    // Avoid stopping or retracting
                    IF NOT (evLower:contains("retract") OR evLower:contains("stop") OR evLower:contains("disable") OR evLower:contains("reset")) {
                        logMsg("Activating experiment: " + ev + " on " + pMod:part:title).
                        pMod:doevent(ev).
                        SET numActivations TO numActivations + 1.
                    }
                }
            }
        }

        logMsg("--- Science Collection Cycle Complete ---").
        logMsg("Summary: Transmitted data from " + numTransmissions + " experiments.").
        logMsg("Summary: Activated " + numActivations + " experiments.").
        logMsg("Waiting 1 hour until next cycle...").
        
        LOCAL waitEnd IS TIME:SECONDS + 3600.
        UNTIL TIME:SECONDS >= waitEnd {
            WAIT 1.
        }
    }
}

runScienceLoop().
