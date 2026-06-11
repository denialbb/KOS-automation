@LAZYGLOBAL OFF.

// ------------------------------------------------------------------------
// Probe Boot Script
// ------------------------------------------------------------------------

WAIT UNTIL SHIP:unpacked.

// Open the kOS terminal using the core processor's module
LOCAL coreProc IS core:part:getmodule("kOSProcessor").
IF coreProc:hasevent("Open Terminal") {
    coreProc:doevent("Open Terminal").
}

CLEARSCREEN.

PRINT "==========================================".
PRINT "      PROBE BOOT SEQUENCE INITIATED       ".
PRINT "==========================================".
WAIT 0.5.

// Play a boot sound sequence
LOCAL v0 IS getvoice(0).
v0:play(note(440, 0.2)).
WAIT 0.2.
v0:play(note(554, 0.2)).
WAIT 0.2.
v0:play(note(659, 0.4)).
WAIT 0.5.

// Print relevant probe information
PRINT " ".
PRINT "Vessel Name:     " + SHIP:NAME.
PRINT "Vessel Mass:     " + ROUND(SHIP:MASS, 2) + " t".
PRINT "Status:          " + SHIP:STATUS.
PRINT "Body:            " + SHIP:BODY:NAME.
PRINT "Altitude:        " + ROUND(SHIP:ALTITUDE) + " m".
PRINT " ".

// List and format resources
PRINT "--- Onboard Resources ---".
LOCAL resList IS LIST().
LIST RESOURCES IN resList.
IF resList:length = 0 {
    PRINT "No resources found.".
} ELSE {
    FOR res IN resList {
        LOCAL resAmount IS ROUND(res:AMOUNT, 2).
        LOCAL resCapacity IS ROUND(res:CAPACITY, 2).
        LOCAL pct IS 0.
        IF resCapacity > 0 {
            SET pct TO ROUND((resAmount / resCapacity) * 100, 1).
        }
        PRINT "- " + res:NAME + ": " + resAmount + " / " + resCapacity + " (" + pct + "%)".
    }
}
PRINT "-------------------------".
PRINT " ".

PRINT "Boot sequence complete.".
WAIT 2.

// Load the main mission script if it exists
IF exists("0:/DASA/minmus_mission.ks") {
    PRINT "Loading 0:/DASA/minmus_mission.ks...".
    WAIT 1.
    RUNPATH("0:/DASA/minmus_mission.ks").
} ELSE {
    PRINT "Waiting for instructions...".
}
