@lazyGlobal off.

// ------------------------------------------------------------------------
// SpaceCore: General Docking Procedure
// ------------------------------------------------------------------------
// Prerequisite: The correct docking port on the target vessel MUST be 
// set as the active target before running this script.
// If the vessel has multiple ports, you may want to select 'control from here' 
// on your preferred docking port first.
// ------------------------------------------------------------------------

if not hastarget {
    print "ERROR: No target selected. Please select a target docking port.".
    return.
}

if target:istype("Vessel") {
    print "ERROR: Target is a vessel, not a port. Please select a specific docking port on the target vessel.".
    return.
}

local tgtPort is target.

// Identify our docking port
local myPorts is ship:dockingports.
if myPorts:length = 0 {
    print "ERROR: No docking ports found on this vessel!".
    return.
}

// Default to the first found port, but use the control part if it's already a docking port
local myPort is myPorts[0].
if ship:controlpart:istype("DockingPort") {
    set myPort to ship:controlpart.
    print "Using currently controlled docking port.".
} else {
    myPort:controlfrom().
    print "Controlled from first available docking port.".
}

print "Initiating docking sequence with " + tgtPort:name + "...".
rcs on.
sas off.

// Lock steering to always face the target port and align roll
lock steering to lookdirup(-tgtPort:portfacing:vector, tgtPort:portfacing:upvector).

// Translation loop
until tgtPort:state:contains("Docked") or tgtPort:state:contains("PreAttached") or myPort:state:contains("Docked") {
    local dist is tgtPort:nodeposition - myPort:nodeposition.
    local relVel is ship:velocity:orbit - tgtPort:ship:velocity:orbit.
    
    // Scale approach speed based on distance
    local desiredSpeed is min(dist:mag / 10, 2.0).
    if dist:mag < 5 { set desiredSpeed to 0.5. }
    if dist:mag < 1 { set desiredSpeed to 0.1. }
    
    // Calculate required translation vectors
    local approachVec is dist:normalized * desiredSpeed.
    local rcsVec is approachVec - relVel.
    
    // Apply RCS thrust (convert to ship-local coordinates)
    set ship:control:translation to ship:facing:inverse * rcsVec.
    
    wait 0.1.
}

// Cleanup and reset controls
set ship:control:translation to v(0,0,0).
unlock steering.
rcs off.
sas on.
print "Docking sequence complete!".
