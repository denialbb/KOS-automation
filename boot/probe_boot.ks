@lazyGlobal off.

// ------------------------------------------------------------------------
// Probe Boot Script
// ------------------------------------------------------------------------

wait until ship:unpacked.

// Open the kOS terminal using the core processor's module
local coreProc is core:part:getmodule("kOSProcessor").
if coreProc:hasevent("Open Terminal") {
    coreProc:doevent("Open Terminal").
}

clearscreen.

print "==========================================".
print "      PROBE BOOT SEQUENCE INITIATED       ".
print "==========================================".
wait 0.5.

// Play a boot sound sequence
local v0 is getvoice(0).
v0:play(note(440, 0.2)).
wait 0.2.
v0:play(note(554, 0.2)).
wait 0.2.
v0:play(note(659, 0.4)).
wait 0.5.

// Print relevant probe information
print " ".
print "Vessel Name:     " + ship:name.
print "Vessel Mass:     " + round(ship:mass, 2) + " t".
print "Status:          " + ship:status.
print "Body:            " + ship:body:name.
print "Altitude:        " + round(ship:altitude) + " m".
print " ".

// List and format resources
print "--- Onboard Resources ---".
local resList is list().
list resources in resList.
if resList:length = 0 {
    print "No resources found.".
} else {
    for res in resList {
        local resAmount is round(res:amount, 2).
        local resCapacity is round(res:capacity, 2).
        local pct is 0.
        if resCapacity > 0 {
            set pct to round((resAmount / resCapacity) * 100, 1).
        }
        print "- " + res:name + ": " + resAmount + " / " + resCapacity + " (" + pct + "%)".
    }
}
print "-------------------------".
print " ".

print "Boot sequence complete.".
wait 2.

// Load the main mission script if it exists
if exists("0:/DASA/minmus_mission.ks") {
    print "Loading 0:/DASA/minmus_mission.ks...".
    wait 1.
    runpath("0:/DASA/minmus_mission.ks").
} else {
    print "Waiting for instructions...".
}
