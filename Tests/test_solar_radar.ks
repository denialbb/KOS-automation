@LAZYGLOBAL OFF.

CLEARSCREEN.
PRINT "=================================".
PRINT " RADAR SOLAR OPTIMIZATION TESTER ".
PRINT "=================================".

GLOBAL logFileName IS "0:/logs/solar_radar_test_log.txt".

// Start fresh for each test run
IF EXISTS(logFileName) {
    DELETEPATH(logFileName).
}

// Force a full part-tree rescan by deleting the cache json
LOCAL cachePath IS "0:/telemetry/deployables_cache.json".
IF EXISTS(cachePath) {
    DELETEPATH(cachePath).
}

GLOBAL FUNCTION logMsg {
    PARAMETER msg.
    LOCAL timeStr IS "[" + TIME:CLOCK + "] ".
    LOCAL fullMsg IS timeStr + msg.
    PRINT fullMsg.
    LOG fullMsg TO logFileName.
}

logMsg("Starting radar solar optimization test script...").

// Load the solar optimization radar library
RUNPATH("0:/DASA/solar_optimization.ks").

logMsg("Radar Library loaded successfully.").
logMsg("Triggering optimizeSunExposure()...").

optimizeSunExposure().

logMsg("Radar Optimization complete!").
logMsg("Final target roll angle is: " + ROUND(targetRoll) + " degrees.").

UNLOCK STEERING.
SAS ON.

logMsg("SAS Locked. Test script finished.").
