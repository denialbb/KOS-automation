@LAZYGLOBAL OFF.

// Clean up old log files only if starting a new mission (pre-launch)
IF SHIP:STATUS = "PRELAUNCH" {
    IF EXISTS("0:/logs/mission_history.log") {
        DELETEPATH("0:/logs/mission_history.log").
    }
    IF EXISTS("0:/logs/log.txt") {
        DELETEPATH("0:/logs/log.txt").
    }
}

// Load Dependencies
RUNONCEPATH("0:/DASA/HUD.ks").
RUNONCEPATH("0:/MJ/MJ.ks").
RUNONCEPATH("0:/DASA/solar_optimization.ks").

// Load Utilities
RUNONCEPATH("0:/DASA/utils/logging.ks").
RUNONCEPATH("0:/DASA/utils/telemetry.ks").
RUNONCEPATH("0:/DASA/utils/power.ks").
RUNONCEPATH("0:/DASA/utils/math.ks").
RUNONCEPATH("0:/DASA/utils/coasting.ks").
RUNONCEPATH("0:/DASA/utils/cache.ks").

// Define Mission Configuration
SET TARGET TO BODY("Minmus").

GLOBAL mission_sequence IS LIST(
    "boot",
    "ascent",
    "deployment",
    "transfer",
    "coast",
    "capture",
    "science_loop"
).

// Start the Mission Runner
RUNPATH("0:/DASA/core/mission_runner.ks").
