@LAZYGLOBAL OFF.

// ------------------------------------------------------------------------
// Deployables Caching Utility Library
// Helps avoid long tree walk and string manipulation operations on system reboot.
// ------------------------------------------------------------------------

GLOBAL cacheFile IS "0:/telemetry/deployables_cache.json".

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
    DECLARE PARAMETER fairingsList, deployablesList, solarPanelsList.

    LOCAL cacheFairings IS LIST().
    FOR pMod IN fairingsList {
        cacheFairings:ADD(LIST(pMod:part:UID, pMod:NAME)).
    }

    LOCAL cacheDeployables IS LIST().
    FOR pMod IN deployablesList {
        cacheDeployables:ADD(LIST(pMod:part:UID, pMod:NAME)).
    }

    LOCAL cacheSolarPanels IS LIST().
    FOR pMod IN solarPanelsList {
        cacheSolarPanels:ADD(LIST(pMod:part:UID, pMod:NAME)).
    }

    LOCAL cache IS LEXICON(
        "vessel_name", SHIP:NAME,
        "root_uid", SHIP:ROOTPART:UID,
        "part_count", SHIP:PARTS:LENGTH,
        "fairings", cacheFairings,
        "deployables", cacheDeployables,
        "solar_panels", cacheSolarPanels
    ).

    WRITEJSON(cache, cacheFile).
    logMsg("Saved deployables list to cache: " + cacheFile).
}

GLOBAL FUNCTION loadDeployablesFromCache {
    DECLARE PARAMETER fairingModules, deployableModules, solarPanelsList.

    LOCAL cache IS READJSON(cacheFile).

    // Create a fast lookup map of the current parts
    LOCAL partMap IS LEXICON().
    FOR p IN SHIP:parts {
        SET partMap[p:UID] TO p.
    }

    IF cache:HASKEY("fairings") {
        FOR item IN cache["fairings"] {
            LOCAL pUid IS item[0].
            LOCAL mName IS item[1].
            IF partMap:HASKEY(pUid) {
                LOCAL p IS partMap[pUid].
                IF p:HASMODULE(mName) {
                    fairingModules:ADD(p:GETMODULE(mName)).
                    logMsg("Loaded fairing from cache: " + p:title).
                }
            }
        }
    }

    IF cache:HASKEY("deployables") {
        FOR item IN cache["deployables"] {
            LOCAL pUid IS item[0].
            LOCAL mName IS item[1].
            IF partMap:HASKEY(pUid) {
                LOCAL p IS partMap[pUid].
                IF p:HASMODULE(mName) {
                    deployableModules:ADD(p:GETMODULE(mName)).
                    logMsg("Loaded deployable from cache: " + p:title).
                }
            }
        }
    }

    IF cache:HASKEY("solar_panels") {
        FOR item IN cache["solar_panels"] {
            LOCAL pUid IS item[0].
            LOCAL mName IS item[1].
            IF partMap:HASKEY(pUid) {
                LOCAL p IS partMap[pUid].
                IF p:HASMODULE(mName) {
                    solarPanelsList:ADD(p:GETMODULE(mName)).
                    logMsg("Loaded solar panel from cache: " + p:title).
                }
            }
        }
    }

    logMsg("Successfully loaded deployables from cache.").
}
