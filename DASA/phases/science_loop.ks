@LAZYGLOBAL OFF.

RUNONCEPATH("0:/DASA/utils/cache.ks").

GLOBAL FUNCTION runScienceLoop {
    logMsg("Initializing Science Loop...").
    initDeployablesCache().

    UNTIL FALSE {
        logMsg("--- Science Collection Cycle Start ---").
        
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
            PRINT "Debugging events for " + pMod:part:title + ":".
            FOR ev IN pMod:alleventnames {
                PRINT " - Event: " + ev.
            }
            
            FOR ev IN pMod:alleventnames {
                LOCAL evLower IS ev:tolower.
                
                // Transmit data first to free up space
                IF evLower:contains("transmit") OR evLower:contains("send") {
                    PRINT "Transmitting data: " + ev + " on " + pMod:part:title.
                    logMsg("Transmitting data: " + ev + " on " + pMod:part:title).
                    pMod:doevent(ev).
                }
            }
            
            // Short wait to allow transmission to start/finish
            WAIT 1.
            
            FOR ev IN pMod:alleventnames {
                LOCAL evLower IS ev:tolower.
                
                // Deploy / Start experiments
                IF evLower:contains("deploy") OR evLower:contains("start") OR evLower:contains("run") OR evLower:contains("observe") OR evLower:contains("log") {
                    // Avoid stopping or retracting
                    IF NOT (evLower:contains("retract") OR evLower:contains("stop") OR evLower:contains("disable") OR evLower:contains("reset")) {
                        PRINT "Activating experiment: " + ev + " on " + pMod:part:title.
                        logMsg("Activating experiment: " + ev + " on " + pMod:part:title).
                        pMod:doevent(ev).
                    }
                }
            }
        }

        logMsg("--- Science Collection Cycle Complete ---").
        logMsg("Waiting 1 hour until next cycle...").
        
        LOCAL waitEnd IS TIME:SECONDS + 3600.
        UNTIL TIME:SECONDS >= waitEnd {
            WAIT 1.
        }
    }
}

runScienceLoop().
