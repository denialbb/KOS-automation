@LAZYGLOBAL OFF.

PRINT "Starting Science Loop Test...".
// Ensure dependencies are loaded
RUNONCEPATH("0:/DASA/utils/logging.ks").
RUNONCEPATH("0:/DASA/utils/cache.ks").

// We can just run the science loop directly
RUNPATH("0:/DASA/phases/science_loop.ks").
