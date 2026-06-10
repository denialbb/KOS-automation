@lazyGlobal off.

// ------------------------------------------------------------------------
// Probe Mission Script: Orbit, Rendezvous, and Dock
// ------------------------------------------------------------------------

local logFile is "0:/probe_log.txt".

function logMsg {
    parameter msg.
    local line is "[" + round(time:seconds, 1) + "] " + msg.
    log line to logFile.
    print line.
}

logMsg("Probe control initialized. Waiting for staging/deployment.").

// 1. Wait for deployment (staging from plane/rocket)
local initMass is ship:mass.
// We consider it deployed if mass drops significantly or if engines are activated and we are flying
wait until (ship:mass < initMass - 0.5) or (maxthrust > 0 and ship:status <> "PRELAUNCH").
logMsg("Deployment detected. Activating flight systems.").

// 2. Reach Orbit
sas off.
local targetAp is 85000.
if ship:apoapsis < targetAp {
    logMsg("Beginning ascent burn.").
    lock throttle to 1.0.
    // If dropped from plane, we might be horizontal, pitch up to 45
    lock steering to heading(90, 45).
    wait until ship:apoapsis >= targetAp.
    lock throttle to 0.0.
    logMsg("Apoapsis target reached. Coasting.").
}

logMsg("Deploying equipment (solar panels/science/antennas).").
// 1. Deploy any fairings on the vessel first to unshield parts
logMsg("Jettisoning all fairings...").
for p in ship:parts {
    for m in p:modules {
        local mName is m:tostring:tolower.
        if mName:contains("fairing") or mName:contains("jettison") or mName:contains("shroud") {
            local pMod is p:getmodule(m).
            for ev in pMod:alleventnames {
                local evLower is ev:tolower.
                if evLower:contains("deploy") or evLower:contains("jettison") or evLower:contains("open") or evLower:contains("release") {
                    pMod:doevent(ev).
                    logMsg("Jettisoned fairing: " + ev + " on " + p:title).
                }
            }
        }
    }
}
wait 1. // Wait for fairing separation physics

panels on.

// Deploy science
for p in ship:modulesNamed("ModuleScienceExperiment") {
    p:deploy().
}

// Deploy antennas and solar panels robustly
for p in ship:parts {
    local pName is p:name:tolower.
    local pTitle is p:title:tolower.
    local isAntennaOrPanelPart is false.
    if pName:contains("solar") or pName:contains("panel") or pName:contains("antenna")
       or pName:contains("dish") or pName:contains("comm") or pName:contains("trans")
       or pName:contains("ray") or pName:contains("reflector") {
        set isAntennaOrPanelPart to true.
    }
    if pTitle:contains("solar") or pTitle:contains("panel") or pTitle:contains("antenna")
       or pTitle:contains("dish") or pTitle:contains("comm") or pTitle:contains("trans")
       or pTitle:contains("ray") or pTitle:contains("reflector") {
        set isAntennaOrPanelPart to true.
    }

    for m in p:modules {
        local mName is m:tostring:tolower.
        local pMod is p:getmodule(m).
        
        local isDeployableModule is false.
        if mName:contains("solar") or mName:contains("panel") or mName:contains("antenna")
           or mName:contains("transmit") or mName:contains("comm") or mName:contains("animate")
           or mName:contains("deploy") or mName:contains("dish") or mName:contains("boom") {
            set isDeployableModule to true.
        }
        
        if isAntennaOrPanelPart or isDeployableModule {
            for ev in pMod:alleventnames {
                local evLower is ev:tolower.
                if evLower:contains("extend") or evLower:contains("deploy") or evLower:contains("open") 
                   or evLower:contains("activate") or evLower:contains("toggle") or evLower:contains("start") {
                    if not (evLower:contains("retract") or evLower:contains("close") or evLower:contains("stop")
                            or evLower:contains("disable") or evLower:contains("shutdown") or evLower:contains("jettison")) {
                        pMod:doevent(ev).
                        logMsg("Deploying: " + ev + " on " + p:title).
                    }
                }
            }
        }
    }
}

if ship:periapsis < 75000 {
    logMsg("Waiting to circularize at Apoapsis.").
    lock steering to prograde.
    wait until eta:apoapsis < 15.
    logMsg("Circularization burn start.").
    lock throttle to 1.0.
    wait until ship:periapsis >= 75000.
    lock throttle to 0.0.
    logMsg("Orbit achieved.").
}

// 3. Rendezvous
if not hastarget {
    logMsg("Please select a target station to proceed.").
    wait until hastarget.
}
logMsg("Target selected: " + target:name).

// Simplified Rendezvous: match altitude and wait for close approach
function executeRendezvous {
    logMsg("Initiating Hohmann transfer to target.").
    
    // Calculate phase angle for transfer
    local r1 is ship:orbit:semimajoraxis.
    local r2 is target:orbit:semimajoraxis.
    local transferSMA is (r1 + r2) / 2.
    local transferTime is sqrt( 4 * constant:pi^2 * transferSMA^3 / constant:g / body:mass ) / 2.
    local reqPhaseAngle is 180 - ((360 / target:orbit:period) * transferTime).
    
    logMsg("Waiting for phase window...").
    lock shipAngle to obt:lan + obt:argumentofperiapsis + obt:trueanomaly.
    lock tgtAngle to target:obt:lan + target:obt:argumentofperiapsis + target:obt:trueanomaly.
    lock phaseAngle to tgtAngle - shipAngle - 360 * floor((tgtAngle - shipAngle) / 360).
    
    if r1 < r2 {
        lock dAngle to phaseAngle - reqPhaseAngle - 360 * floor((phaseAngle - reqPhaseAngle) / 360).
    } else {
        lock dAngle to reqPhaseAngle - phaseAngle - 360 * floor((reqPhaseAngle - phaseAngle) / 360).
    }
    
    local phaseRate is (360 / target:orbit:period) - (360 / orbit:period).
    lock timeToBurn to abs(dAngle / phaseRate).
    
    wait until timeToBurn < 30.
    set warpmode to "physics".
    set warp to 0.
    wait until timeToBurn < 5.
    
    logMsg("Executing transfer burn.").
    lock steering to prograde.
    wait until timeToBurn < 0.1.
    lock throttle to 1.0.
    wait until ship:apoapsis >= target:apoapsis.
    lock throttle to 0.0.
    
    logMsg("Coasting to closest approach.").
    wait until eta:apoapsis < 60.
    
    // Kill relative velocity at close approach
    logMsg("Matching velocity with target.").
    lock relVel to ship:velocity:orbit - target:velocity:orbit.
    lock steering to -1 * relVel.
    wait until vdot(-relVel, ship:facing:forevector) > 0.95.
    
    // Wait for closest approach point
    local lastDist is target:distance.
    until false {
        if target:distance > lastDist { break. }
        set lastDist to target:distance.
        wait 0.1.
    }
    
    lock throttle to min(relVel:mag / 10, 1.0).
    wait until relVel:mag < 0.5.
    lock throttle to 0.0.
    logMsg("Rendezvous complete. Distance: " + round(target:distance) + "m.").
}

executeRendezvous().

// 4. Docking
function prepareAndDock {
    logMsg("Preparing for docking sequence.").
    
    // If the target is just the station (Vessel), find a docking port to target
    if target:istype("Vessel") {
        local tgtPorts is target:dockingports.
        if tgtPorts:length = 0 {
            logMsg("ERROR: No docking ports found on target station!").
            return.
        }
        // Set the specific port as the target so SpaceCore/Dock.ks can use it
        set target to tgtPorts[0]. 
        logMsg("Targeted docking port: " + target:name).
    }
    
    logMsg("Running general docking script...").
    runpath("0:/SpaceCore/Dock.ks").
    logMsg("Docking complete!").
}

prepareAndDock().
logMsg("Mission script terminated.").
