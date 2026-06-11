@LAZYGLOBAL OFF.

// ------------------------------------------------------------------------
// SpaceCore: General Docking Procedure
// ------------------------------------------------------------------------
// Prerequisite: The correct docking port on the target vessel MUST be 
// set as the active target before running this script.
// If the vessel has multiple ports, you may want to select 'control from here' 
// on your preferred docking port first.
// ------------------------------------------------------------------------

IF NOT hastarget {
    PRINT "ERROR: No target selected. Please select a target docking port.".
    RETURN.
}

IF TARGET:istype("Vessel") {
    PRINT "ERROR: Target is a vessel, not a port. Please select a specific docking port on the target vessel.".
    RETURN.
}

LOCAL tgtPort IS TARGET.

// Identify our docking port
LOCAL myPorts IS SHIP:dockingports.
IF myPorts:length = 0 {
    PRINT "ERROR: No docking ports found on this vessel!".
    RETURN.
}

// Default to the first found port, but use the control part if it's already a docking port
LOCAL myPort IS myPorts[0].
IF SHIP:controlpart:istype("DockingPort") {
    SET myPort TO SHIP:controlpart.
    PRINT "Using currently controlled docking port.".
} ELSE {
    myPort:controlfrom().
    PRINT "Controlled from first available docking port.".
}

PRINT "Initiating docking sequence with " + tgtPort:NAME + "...".
RCS ON.
SAS OFF.

// Lock steering to always face the target port and align roll
LOCK STEERING TO lookdirup(-tgtPort:portfacing:vector, tgtPort:portfacing:upvector).

// Translation loop
UNTIL tgtPort:state:contains("Docked") OR tgtPort:state:contains("PreAttached") OR myPort:state:contains("Docked") {
    LOCAL dist IS tgtPort:nodeposition - myPort:nodeposition.
    LOCAL relVel IS SHIP:VELOCITY:ORBIT - tgtPort:SHIP:VELOCITY:ORBIT.
    
    // Scale approach speed based on distance
    LOCAL desiredSpeed IS MIN(dist:MAG / 10, 2.0).
    IF dist:MAG < 5 { SET desiredSpeed TO 0.5. }
    IF dist:MAG < 1 { SET desiredSpeed TO 0.1. }
    
    // Calculate required translation vectors
    LOCAL approachVec IS dist:normalized * desiredSpeed.
    LOCAL rcsVec IS approachVec - relVel.
    
    // Apply RCS thrust (convert to ship-local coordinates)
    SET SHIP:CONTROL:translation TO SHIP:FACING:inverse * rcsVec.
    
    WAIT 0.1.
}

// Cleanup and reset controls
SET SHIP:CONTROL:translation TO v(0,0,0).
UNLOCK STEERING.
RCS OFF.
SAS ON.
PRINT "Docking sequence complete!".
