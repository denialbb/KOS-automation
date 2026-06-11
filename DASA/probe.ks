@LAZYGLOBAL OFF.

// ------------------------------------------------------------------------
// Probe Mission Script: Orbit, Rendezvous, and Dock
// ------------------------------------------------------------------------

LOCAL logFile IS "0:/probe_log.txt".

FUNCTION logMsg {
    PARAMETER msg.
    LOCAL line IS "[" + ROUND(TIME:SECONDS, 1) + "] " + msg.
    LOG line TO logFile.
    PRINT line.
}

logMsg("Probe control initialized. Waiting for staging/deployment.").

// 1. Wait for deployment (staging from plane/rocket)
LOCAL initMass IS SHIP:MASS.
// We consider it deployed if mass drops significantly or if engines are activated and we are flying
WAIT UNTIL (SHIP:MASS < initMass - 0.5) OR (MAXTHRUST > 0 AND SHIP:STATUS <> "PRELAUNCH").
logMsg("Deployment detected. Activating flight systems.").

// 2. Reach Orbit
SAS OFF.
LOCAL targetAp IS 85000.
IF SHIP:APOAPSIS < targetAp {
    logMsg("Beginning ascent burn.").
    LOCK THROTTLE TO 1.0.
    // If dropped from plane, we might be horizontal, pitch up to 45
    LOCK STEERING TO HEADING(90, 45).
    WAIT UNTIL SHIP:APOAPSIS >= targetAp.
    LOCK THROTTLE TO 0.0.
    logMsg("Apoapsis target reached. Coasting.").
}

logMsg("Deploying equipment (solar panels/science/antennas).").
// 1. Deploy any fairings on the vessel first to unshield parts
logMsg("Jettisoning all fairings...").
FOR p IN SHIP:parts {
    FOR m IN p:modules {
        LOCAL mName IS m:tostring:tolower.
        IF mName:contains("fairing") OR mName:contains("jettison") OR mName:contains("shroud") {
            LOCAL pMod IS p:getmodule(m).
            FOR ev IN pMod:alleventnames {
                LOCAL evLower IS ev:tolower.
                IF evLower:contains("deploy") OR evLower:contains("jettison") OR evLower:contains("open") OR evLower:contains("release") {
                    pMod:doevent(ev).
                    logMsg("Jettisoned fairing: " + ev + " on " + p:title).
                }
            }
        }
    }
}
WAIT 1. // Wait for fairing separation physics

PANELS ON.

// Deploy science
FOR p IN SHIP:modulesNamed("ModuleScienceExperiment") {
    p:deploy().
}

// Deploy antennas and solar panels robustly
FOR p IN SHIP:parts {
    LOCAL pName IS p:NAME:tolower.
    LOCAL pTitle IS p:title:tolower.
    LOCAL isAntennaOrPanelPart IS FALSE.
    IF pName:contains("solar") OR pName:contains("panel") OR pName:contains("antenna")
       OR pName:contains("dish") OR pName:contains("comm") OR pName:contains("trans")
       OR pName:contains("ray") OR pName:contains("reflector") {
        SET isAntennaOrPanelPart TO TRUE.
    }
    IF pTitle:contains("solar") OR pTitle:contains("panel") OR pTitle:contains("antenna")
       OR pTitle:contains("dish") OR pTitle:contains("comm") OR pTitle:contains("trans")
       OR pTitle:contains("ray") OR pTitle:contains("reflector") {
        SET isAntennaOrPanelPart TO TRUE.
    }

    FOR m IN p:modules {
        LOCAL mName IS m:tostring:tolower.
        LOCAL pMod IS p:getmodule(m).
        
        LOCAL isDeployableModule IS FALSE.
        IF mName:contains("solar") OR mName:contains("panel") OR mName:contains("antenna")
           OR mName:contains("transmit") OR mName:contains("comm") OR mName:contains("animate")
           OR mName:contains("deploy") OR mName:contains("dish") OR mName:contains("boom") {
            SET isDeployableModule TO TRUE.
        }
        
        IF isAntennaOrPanelPart OR isDeployableModule {
            FOR ev IN pMod:alleventnames {
                LOCAL evLower IS ev:tolower.
                IF evLower:contains("extend") OR evLower:contains("deploy") OR evLower:contains("open") 
                   OR evLower:contains("activate") OR evLower:contains("toggle") OR evLower:contains("start") {
                    IF NOT (evLower:contains("retract") OR evLower:contains("close") OR evLower:contains("stop")
                            OR evLower:contains("disable") OR evLower:contains("shutdown") OR evLower:contains("jettison")) {
                        pMod:doevent(ev).
                        logMsg("Deploying: " + ev + " on " + p:title).
                    }
                }
            }
        }
    }
}

IF SHIP:PERIAPSIS < 75000 {
    logMsg("Waiting to circularize at Apoapsis.").
    LOCK STEERING TO PROGRADE.
    WAIT UNTIL ETA:APOAPSIS < 15.
    logMsg("Circularization burn start.").
    LOCK THROTTLE TO 1.0.
    WAIT UNTIL SHIP:PERIAPSIS >= 75000.
    LOCK THROTTLE TO 0.0.
    logMsg("Orbit achieved.").
}

// 3. Rendezvous
IF NOT hastarget {
    logMsg("Please select a target station to proceed.").
    WAIT UNTIL hastarget.
}
logMsg("Target selected: " + TARGET:NAME).

// Simplified Rendezvous: match altitude and wait for close approach
FUNCTION executeRendezvous {
    logMsg("Initiating Hohmann transfer to target.").
    
    // Calculate phase angle for transfer
    LOCAL r1 IS SHIP:ORBIT:semimajoraxis.
    LOCAL r2 IS TARGET:ORBIT:semimajoraxis.
    LOCAL transferSMA IS (r1 + r2) / 2.
    LOCAL transferTime IS sqrt( 4 * CONSTANT:pi^2 * transferSMA^3 / CONSTANT:g / BODY:MASS ) / 2.
    LOCAL reqPhaseAngle IS 180 - ((360 / TARGET:ORBIT:period) * transferTime).
    
    logMsg("Waiting for phase window...").
    LOCK shipAngle TO obt:lan + obt:argumentofperiapsis + obt:trueanomaly.
    LOCK tgtAngle TO TARGET:obt:lan + TARGET:obt:argumentofperiapsis + TARGET:obt:trueanomaly.
    LOCK phaseAngle TO tgtAngle - shipAngle - 360 * FLOOR((tgtAngle - shipAngle) / 360).
    
    IF r1 < r2 {
        LOCK dAngle TO phaseAngle - reqPhaseAngle - 360 * FLOOR((phaseAngle - reqPhaseAngle) / 360).
    } ELSE {
        LOCK dAngle TO reqPhaseAngle - phaseAngle - 360 * FLOOR((reqPhaseAngle - phaseAngle) / 360).
    }
    
    LOCAL phaseRate IS (360 / TARGET:ORBIT:period) - (360 / ORBIT:period).
    LOCK timeToBurn TO abs(dAngle / phaseRate).
    
    WAIT UNTIL timeToBurn < 30.
    SET WARPMODE TO "physics".
    SET warp TO 0.
    WAIT UNTIL timeToBurn < 5.
    
    logMsg("Executing transfer burn.").
    LOCK STEERING TO PROGRADE.
    WAIT UNTIL timeToBurn < 0.1.
    LOCK THROTTLE TO 1.0.
    WAIT UNTIL SHIP:APOAPSIS >= TARGET:APOAPSIS.
    LOCK THROTTLE TO 0.0.
    
    logMsg("Coasting to closest approach.").
    WAIT UNTIL ETA:APOAPSIS < 60.
    
    // Kill relative velocity at close approach
    logMsg("Matching velocity with target.").
    LOCK relVel TO SHIP:VELOCITY:ORBIT - TARGET:VELOCITY:ORBIT.
    LOCK STEERING TO -1 * relVel.
    WAIT UNTIL VDOT(-relVel, SHIP:FACING:FOREVECTOR) > 0.95.
    
    // Wait for closest approach point
    LOCAL lastDist IS TARGET:distance.
    UNTIL FALSE {
        IF TARGET:distance > lastDist { BREAK. }
        SET lastDist TO TARGET:distance.
        WAIT 0.1.
    }
    
    LOCK THROTTLE TO MIN(relVel:MAG / 10, 1.0).
    WAIT UNTIL relVel:MAG < 0.5.
    LOCK THROTTLE TO 0.0.
    logMsg("Rendezvous complete. Distance: " + ROUND(TARGET:distance) + "m.").
}

executeRendezvous().

// 4. Docking
FUNCTION prepareAndDock {
    logMsg("Preparing for docking sequence.").
    
    // If the target is just the station (Vessel), find a docking port to target
    IF TARGET:istype("Vessel") {
        LOCAL tgtPorts IS TARGET:dockingports.
        IF tgtPorts:length = 0 {
            logMsg("ERROR: No docking ports found on target station!").
            RETURN.
        }
        // Set the specific port as the target so SpaceCore/Dock.ks can use it
        SET TARGET TO tgtPorts[0]. 
        logMsg("Targeted docking port: " + TARGET:NAME).
    }
    
    logMsg("Running general docking script...").
    RUNPATH("0:/SpaceCore/Dock.ks").
    logMsg("Docking complete!").
}

prepareAndDock().
logMsg("Mission script terminated.").
