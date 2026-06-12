@LAZYGLOBAL OFF.

// ------------------------------------------------------------------------
// Deployables Caching Utility Library
// Helps avoid long tree walk and string manipulation operations on system reboot.
// ------------------------------------------------------------------------

GLOBAL cacheFile IS "0:/telemetry/deployables_cache.json".
GLOBAL cachedFairings IS LIST().
GLOBAL cachedDeployables IS LIST().
GLOBAL cachedSolarPanels IS LIST().
GLOBAL cachedExperiments IS LIST().
GLOBAL cacheLoaded IS FALSE.

GLOBAL FUNCTION isCacheValid {
    IF NOT EXISTS(cacheFile) {
        RETURN FALSE.
    }

    LOCAL cache IS READJSON(cacheFile).
    IF NOT cache:HASKEY("root_uid") OR NOT cache:HASKEY("part_count") OR NOT cache:HASKEY("vessel_name") {
        RETURN FALSE.
    }

    IF cache["root_uid"] = SHIP:ROOTPART:UID AND cache["part_count"] = SHIP:PARTS:LENGTH AND cache["vessel_name"] = SHIP:NAME {
        RETURN TRUE.
    }

    RETURN FALSE.
}

GLOBAL FUNCTION saveDeployablesCache {
    LOCAL cacheFairings IS LIST().
    FOR pMod IN cachedFairings {
        cacheFairings:ADD(LIST(pMod:part:UID, pMod:NAME)).
    }

    LOCAL cacheDeployables IS LIST().
    FOR pMod IN cachedDeployables {
        cacheDeployables:ADD(LIST(pMod:part:UID, pMod:NAME)).
    }

    LOCAL cacheSolarPanels IS LIST().
    FOR pMod IN cachedSolarPanels {
        cacheSolarPanels:ADD(LIST(pMod:part:UID, pMod:NAME)).
    }

    LOCAL cacheExperiments IS LIST().
    FOR pMod IN cachedExperiments {
        cacheExperiments:ADD(LIST(pMod:part:UID, pMod:NAME)).
    }

    LOCAL cache IS LEXICON(
        "vessel_name", SHIP:NAME,
        "root_uid", SHIP:ROOTPART:UID,
        "part_count", SHIP:PARTS:LENGTH,
        "fairings", cacheFairings,
        "deployables", cacheDeployables,
        "solar_panels", cacheSolarPanels,
        "experiments", cacheExperiments
    ).

    WRITEJSON(cache, cacheFile).
    logMsg("Saved deployables list to cache: " + cacheFile).
}

GLOBAL FUNCTION initDeployablesCache {
    IF cacheLoaded { RETURN. }

    IF isCacheValid() {
        LOCAL cache IS READJSON(cacheFile).
        LOCAL partMap IS LEXICON().
        FOR p IN SHIP:parts {
            SET partMap[p:UID] TO p.
        }

        IF cache:HASKEY("fairings") {
            FOR item IN cache["fairings"] {
                IF partMap:HASKEY(item[0]) {
                    LOCAL p IS partMap[item[0]].
                    IF p:HASMODULE(item[1]) {
                        cachedFairings:ADD(p:GETMODULE(item[1])).
                    }
                }
            }
        }

        IF cache:HASKEY("deployables") {
            FOR item IN cache["deployables"] {
                IF partMap:HASKEY(item[0]) {
                    LOCAL p IS partMap[item[0]].
                    IF p:HASMODULE(item[1]) {
                        cachedDeployables:ADD(p:GETMODULE(item[1])).
                    }
                }
            }
        }

        IF cache:HASKEY("solar_panels") {
            FOR item IN cache["solar_panels"] {
                IF partMap:HASKEY(item[0]) {
                    LOCAL p IS partMap[item[0]].
                    IF p:HASMODULE(item[1]) {
                        cachedSolarPanels:ADD(p:GETMODULE(item[1])).
                    }
                }
            }
        }

        IF cache:HASKEY("experiments") {
            FOR item IN cache["experiments"] {
                IF partMap:HASKEY(item[0]) {
                    LOCAL p IS partMap[item[0]].
                    IF p:HASMODULE(item[1]) {
                        cachedExperiments:ADD(p:GETMODULE(item[1])).
                    }
                }
            }
        }

        SET cacheLoaded TO TRUE.
        logMsg("Successfully loaded deployables from cache.").
    } ELSE {
        // Walk the parts tree once to categorize all modules
        FOR p IN SHIP:parts {
            FOR m IN p:modules {
                LOCAL mName IS m:tostring:tolower.
                LOCAL pMod IS p:getmodule(m).

                IF mName:contains("fairing") OR mName:contains("jettison") OR mName:contains("shroud") {
                    cachedFairings:ADD(pMod).
                }

                IF mName:contains("solar") OR mName:contains("panel") OR mName:contains("antenna")
                   OR mName:contains("transmit") OR (mName:contains("comm") AND NOT mName:contains("command"))
                   OR mName:contains("animate") OR mName:contains("deploy") 
                   OR mName:contains("dish") OR mName:contains("boom") {
                    cachedDeployables:ADD(pMod).
                }

                IF mName:contains("deployablesolarpanel") OR mName:contains("solar") {
                    IF pMod:HASFIELD("energy flow") OR pMod:HASFIELD("sun exposure") OR pMod:HASFIELD("flow") {
                        cachedSolarPanels:ADD(pMod).
                    }
                }

                IF mName:contains("experiment") OR mName:contains("science") {
                    cachedExperiments:ADD(pMod).
                }
            }
        }
        logMsg("Tree walk complete. Cache built successfully.").
        logMsg(" - Fairings found: " + cachedFairings:LENGTH).
        logMsg(" - Deployables found: " + cachedDeployables:LENGTH).
        logMsg(" - Solar Panels found: " + cachedSolarPanels:LENGTH).
        logMsg(" - Experiments found: " + cachedExperiments:LENGTH).
        
        saveDeployablesCache().
        SET cacheLoaded TO TRUE.
    }
}

GLOBAL FUNCTION runAllScience {
    initDeployablesCache().
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
}

