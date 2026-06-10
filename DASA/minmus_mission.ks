@lazyGlobal off.

// ------------------------------------------------------------------------
// Minmus Automation Mission Script
// Flow: Pre-launch -> Launch -> Circularization -> Minmus Plane Alignment ->
//       Hohmann Transfer -> Coasting (Science/Power) -> Capture -> Polar Orbit
// ------------------------------------------------------------------------

local telemetryFile is "0:/telemetry/telemetry.json".
local missionLogPath is "0:/logs/log.txt".
global hadConnection is true.
global localLogPath is "1:/local_log.txt".
local apuState is false.
local lastPowerCheck is 0.
global telemetryStage is "Booting".
global missionMilestones is list().
local lastTelemetryUpdate is 0.

if exists("0:/logs/mission_history.log") {
    deletepath("0:/logs/mission_history.log").
}
if exists(missionLogPath) {
    deletepath(missionLogPath).
}

// ------------------------------------------------------------------------
// Helpers: Logging and Telemetry
// ------------------------------------------------------------------------
function formatTime {
    parameter t.
    local h is floor(t / 3600).
    local m is floor(mod(t, 3600) / 60).
    local s is floor(mod(t, 60)).
    local hStr is "" + h. if h < 10 { set hStr to "0" + h. }
    local mStr is "" + m. if m < 10 { set mStr to "0" + m. }
    local sStr is "" + s. if s < 10 { set sStr to "0" + s. }
    return hStr + ":" + mStr + ":" + sStr.
}

function logMsg {
    parameter msg.
    local tStr is "T+ ".
    local tVal is missiontime.
    if hasnode {
        set tStr to "T- ".
        set tVal to nextnode:eta.
    }
    local line is "[" + tStr + formatTime(tVal) + "] " + msg.
    print line.
    missionMilestones:add(line).
    
    if homeconnection:isconnected {
        // If we have local logs cached from blackout, flush them to archive
        if exists(localLogPath) {
            local f is open(localLogPath).
            for l in f:readall {
                log l to missionLogPath.
            }
            deletepath(localLogPath).
        }
        log line to missionLogPath.
    } else {
        log line to localLogPath.
    }
}

function updateTelemetry {
    parameter stageName.
    local ec is ship:electriccharge.
    local ecMax is 0.
    for r in ship:resources {
        if r:name = "ElectricCharge" {
            set ecMax to r:capacity.
        }
    }
    
    local currentMass is ship:mass.
    local currentThrust is ship:availablethrust.
    local r_dist is body:radius + ship:altitude.
    local grav is body:mu / (r_dist * r_dist).
    local currentTwr is 0.
    if grav > 0 and currentMass > 0 { set currentTwr to currentThrust / (currentMass * grav). }
    local currentQ is ship:dynamicpressure.

    local dq is char(34).
    
    // Construct parts array
    local partsJson is "[".
    local first is true.
    for p in ship:parts {
        if not first {
            set partsJson to partsJson + ", ".
        }
        set first to false.
        local pName is p:name:replace(dq, "").
        local pTitle is p:title:replace(dq, "").
        local pTag is p:tag:replace(dq, "").
        set partsJson to partsJson + "{" + dq + "uid" + dq + ":" + dq + p:uid + dq + "," + dq + "name" + dq + ":" + dq + pName + dq + "," + dq + "title" + dq + ":" + dq + pTitle + dq + "," + dq + "tag" + dq + ":" + dq + pTag + dq + "}".
    }
    set partsJson to partsJson + "]".
    
    // Construct all resources array/object
    local resJson is "{".
    local firstRes is true.
    for r in ship:resources {
        if not firstRes {
            set resJson to resJson + ", ".
        }
        set firstRes to false.
        set resJson to resJson + dq + r:name + dq + ": {" + dq + "amount" + dq + ":" + round(r:amount, 1) + "," + dq + "capacity" + dq + ":" + round(r:capacity, 1) + "}".
    }
    set resJson to resJson + "}".

    // Construct closest POI (Waypoint)
    local closestPoiName is "None".
    local closestPoiDist is 0.
    local minPoiDist is 999999999999.
    for wp in allwaypoints() {
        if wp:body:name = ship:body:name {
            local dist is wp:position:mag.
            if dist < minPoiDist {
                set minPoiDist to dist.
                set closestPoiName to wp:name.
                set closestPoiDist to dist.
            }
        }
    }

    // Construct Target Info
    local hasTgt is false.
    local hasTgtStr is "false".
    local tgtName is "None".
    local tgtDist is 0.
    local tgtRelV is 0.
    if hastarget {
        set hasTgt to true.
        set hasTgtStr to "true".
        set tgtName to target:name.
        set tgtDist to target:position:mag.
        set tgtRelV to (target:velocity:orbit - ship:velocity:orbit):mag.
    }
    
    // Construct JSON string
    local jsonStr is "{".
    set jsonStr to jsonStr + dq + "time" + dq + ": " + round(missiontime, 1) + ", ".
    set jsonStr to jsonStr + dq + "vessel" + dq + ": " + dq + ship:name + dq + ", ".
    set jsonStr to jsonStr + dq + "stage" + dq + ": " + dq + stageName + dq + ", ".
    set jsonStr to jsonStr + dq + "altitude" + dq + ": " + round(ship:altitude) + ", ".
    set jsonStr to jsonStr + dq + "periapsis" + dq + ": " + round(ship:periapsis) + ", ".
    set jsonStr to jsonStr + dq + "apoapsis" + dq + ": " + round(ship:apoapsis) + ", ".
    set jsonStr to jsonStr + dq + "inclination" + dq + ": " + round(ship:orbit:inclination, 2) + ", ".
    set jsonStr to jsonStr + dq + "velocity" + dq + ": " + round(ship:velocity:orbit:mag) + ", ".
    set jsonStr to jsonStr + dq + "electricCharge" + dq + ": " + round(ec) + ", ".
    set jsonStr to jsonStr + dq + "electricChargeMax" + dq + ": " + round(ecMax) + ", ".
    set jsonStr to jsonStr + dq + "twr" + dq + ": " + round(currentTwr, 2) + ", ".
    set jsonStr to jsonStr + dq + "q" + dq + ": " + round(currentQ, 4) + ", ".
    set jsonStr to jsonStr + dq + "body" + dq + ": " + dq + ship:body:name + dq + ", ".
    set jsonStr to jsonStr + dq + "resources" + dq + ": " + resJson + ", ".
    set jsonStr to jsonStr + dq + "closestPoi" + dq + ": {" + dq + "name" + dq + ":" + dq + closestPoiName + dq + "," + dq + "distance" + dq + ":" + round(closestPoiDist) + "}, ".
    set jsonStr to jsonStr + dq + "target" + dq + ": {" + dq + "hasTarget" + dq + ":" + hasTgtStr + "," + dq + "name" + dq + ":" + dq + tgtName + dq + "," + dq + "distance" + dq + ":" + round(tgtDist) + "," + dq + "relVelocity" + dq + ":" + round(tgtRelV, 2) + "}, ".
    
    // Construct Attitude Info
    local upVec is ship:up:vector.
    local northVec is ship:north:vector.
    local eastVec is vcrs(upVec, northVec):normalized.
    local foreVec is ship:facing:forevector.
    local topVec is ship:facing:topvector.
    
    local fx is round(vdot(foreVec, eastVec), 4).
    local fy is round(vdot(foreVec, northVec), 4).
    local fz is round(vdot(foreVec, upVec), 4).
    local tx is round(vdot(topVec, eastVec), 4).
    local ty is round(vdot(topVec, northVec), 4).
    local tz is round(vdot(topVec, upVec), 4).
    
    set jsonStr to jsonStr + dq + "attitude" + dq + ": {" + dq + "fore" + dq + ": [" + fx + "," + fy + "," + fz + "]," + dq + "top" + dq + ": [" + tx + "," + ty + "," + tz + "]}, ".
    
    local bHasNode is hasnode.
    if bHasNode {
        set jsonStr to jsonStr + dq + "maneuver" + dq + ": { " + dq + "hasNode" + dq + ": true, " + dq + "eta" + dq + ": " + round(nextnode:eta, 1) + ", " + dq + "dv" + dq + ": " + round(nextnode:deltav:mag, 1) + " }, ".
    } else {
        set jsonStr to jsonStr + dq + "maneuver" + dq + ": { " + dq + "hasNode" + dq + ": false, " + dq + "eta" + dq + ": 0, " + dq + "dv" + dq + ": 0 }, ".
    }

    set jsonStr to jsonStr + dq + "parts" + dq + ": " + partsJson + ", ".
    
    local milestonesJson is "[".
    local firstMilestone is true.
    for ms in missionMilestones {
        if not firstMilestone { set milestonesJson to milestonesJson + ", ". }
        set firstMilestone to false.
        set milestonesJson to milestonesJson + dq + ms:replace(dq, "") + dq.
    }
    set milestonesJson to milestonesJson + "]".
    
    set jsonStr to jsonStr + dq + "milestones" + dq + ": " + milestonesJson.
    set jsonStr to jsonStr + "}".
    
    // Only write telemetry to archive if KSC connection is active to prevent kOS crash
    if homeconnection:isconnected {
        if exists(telemetryFile) {
            deletepath(telemetryFile).
        }
        log jsonStr to telemetryFile.
    }
}

function setStage {
    parameter newStage.
    set telemetryStage to newStage.
    updateTelemetry(telemetryStage).
    
    if homeconnection:isconnected {
        local histFile is "0:/logs/mission_history.log".
        if not exists(histFile) {
            log "Time,Stage,Body,Alt,Pe,Ap,Inc,EC_pct,Vel" to histFile.
        }
        
        local ec is 0.
        local ecMax is 1.
        for r in ship:resources {
            if r:name = "ElectricCharge" {
                set ec to r:amount.
                set ecMax to max(0.1, r:capacity).
            }
        }
        local ecPct is round((ec/ecMax)*100, 1).
        local logLine is round(missiontime) + "," + newStage + "," + ship:body:name + "," + round(ship:altitude) + "," + round(ship:periapsis) + "," + round(ship:apoapsis) + "," + round(ship:orbit:inclination, 1) + "," + ecPct + "," + round(ship:velocity:orbit:mag).
        log logLine to histFile.
    }
}

when abort then {
    setStage("Aborted").
    logMsg("MISSION ABORTED!").
    preserve.
}

// ------------------------------------------------------------------------
// Helpers: Subsystems (Power & Science)
// ------------------------------------------------------------------------
function setAPUState {
    parameter state.
    local stateStr is "OFF".
    if state { set stateStr to "ON". }
    logMsg("Setting Fuel Cells/APUs to " + stateStr).
    
    for p in ship:parts {
        for mName in p:modules {
            local pMod is p:getmodule(mName).
            for ev in pMod:allevents {
                local evLower is ev:tolower.
                if state {
                    if (evLower:contains("start") or evLower:contains("activate") or evLower:contains("enable")) and (evLower:contains("cell") or evLower:contains("gen") or evLower:contains("apu") or evLower:contains("power")) {
                        pMod:doevent(ev).
                        logMsg("APU ON: " + ev + " on " + p:title).
                    }
                } else {
                    if (evLower:contains("stop") or evLower:contains("deactivate") or evLower:contains("disable")) and (evLower:contains("cell") or evLower:contains("gen") or evLower:contains("apu") or evLower:contains("power")) {
                        pMod:doevent(ev).
                        logMsg("APU OFF: " + ev + " on " + p:title).
                    }
                }
            }
        }
    }
}

function checkPower {
    local ec is ship:electriccharge.
    local ecMax is 0.
    for r in ship:resources {
        if r:name = "ElectricCharge" { set ecMax to r:capacity. }
    }
    if ecMax > 0 {
        local pct is ec / ecMax.
        if pct < 0.20 {
            if not apuState {
                logMsg("CRITICAL POWER: Starting APUs.").
                setAPUState(true).
                set apuState to true.
            }
            if lights {
                lights off.
                logMsg("CRITICAL POWER: Turning off lights to conserve energy.").
            }
        } else if pct > 0.95 {
            if apuState {
                logMsg("Power restored. Stopping APUs.").
                setAPUState(false).
                set apuState to false.
            }
        }
        
        // Turn lights on if in orbit and power is stable (>20%)
        if pct >= 0.20 and (ship:status = "ORBITING" or ship:status = "ESCAPING") {
            if not lights {
                lights on.
                logMsg("Vessel in orbit with stable power. Turning lights on.").
            }
        }
    }
}

function runAllScience {
    logMsg("Triggering all science experiments...").
    for p in ship:parts {
        for mName in p:modules {
            local mNameLower is mName:tolower.
            if mNameLower:contains("science") or mNameLower:contains("experiment") or mNameLower:contains("sensor") {
                local pMod is p:getmodule(mName).
                if pMod:hasfield("deploy") or pMod:hasevent("deploy") {
                    pMod:doevent("deploy").
                }
                for ev in pMod:allevents {
                    local evLower is ev:tolower.
                    if evLower:contains("start") or evLower:contains("deploy") or evLower:contains("run") or evLower:contains("collect") {
                        pMod:doevent(ev).
                    }
                }
            }
        }
    }
}

// ------------------------------------------------------------------------
// Safe Coasting Routine
// ------------------------------------------------------------------------
function safeCoast {
    parameter targetTime.
    setStage("Coasting").
    
    until time:seconds >= targetTime - 60 {
        lock steering to sun:position.
        checkPower().
        runAllScience().
        
        local timeLeft is targetTime - time:seconds.
        if timeLeft > 3600 {
            local nextStop is min(time:seconds + 3600, targetTime - 60).
            set warpmode to "rails".
            warpto(nextStop).
            wait until time:seconds >= nextStop - 5.
        } else if timeLeft > 300 {
            local nextStop is targetTime - 60.
            set warpmode to "rails".
            warpto(nextStop).
            wait until time:seconds >= nextStop - 5.
        } else {
            wait 10.
        }
    }
    unlock steering.
}

// ------------------------------------------------------------------------
// Math & Orbital Node Calculation
// ------------------------------------------------------------------------
function clamp {
    parameter val, mn, mx.
    if val < mn return mn.
    if val > mx return mx.
    return val.
}

function createNodeFromVector {
    parameter burnTime, dVVector.
    local r_at is positionat(ship, burnTime) - positionat(ship:body, burnTime).
    local v_at is velocityat(ship, burnTime):orbit.
    
    local pro_dir is v_at:normalized.
    local norm_dir is vcrs(v_at, r_at):normalized.
    local rad_dir is vcrs(pro_dir, norm_dir):normalized.
    
    local dV_pro is vdot(dVVector, pro_dir).
    local dV_norm is vdot(dVVector, norm_dir).
    local dV_rad is vdot(dVVector, rad_dir).
    
    local nd is node(burnTime, dV_rad, dV_norm, dV_pro).
    add nd.
    return nd.
}



// ------------------------------------------------------------------------
// Main Mission Sequence
// ------------------------------------------------------------------------
// Start background power and subsystem monitor trigger (runs every 5 seconds)
when time:seconds > lastPowerCheck + 5 then {
    set lastPowerCheck to time:seconds.
    checkPower().
    preserve.
}

when time:seconds > lastTelemetryUpdate + 0.2 then {
    local hasConn is homeconnection:isconnected.
    if hasConn <> hadConnection {
        if hasConn {
            logMsg("Signal restored. Reconnected to KSC.").
        } else {
            logMsg("SIGNAL LOST: Connection to KSC lost.").
        }
        set hadConnection to hasConn.
    }
    
    updateTelemetry(telemetryStage).
    set lastTelemetryUpdate to time:seconds.
    preserve.
}

setStage("Booting").
logMsg("Minmus Automation Mission Initialized.").
runpath("0:/DASA/VesselScan.ks").

// 1. Wait for deployment / Pre-launch
if ship:status = "PRELAUNCH" or ship:status = "LANDED" or (ship:status = "FLYING" and ship:altitude < 70000) {
    setStage("Pre-Launch").
    logMsg("Vessel is pre-launch/flying. Waiting for staging to initiate launch.").
    wait until maxthrust > 0.
    
    logMsg("Launch detected! Ascending to 80km orbit.").
    setStage("Ascent").
    runpath("0:/SpaceCore/Ascent", false, 80, 0, 60). // 80km, 0 inc, fairing at 60km
    
    if ship:periapsis < 75000 {
        logMsg("Circularizing at Apoapsis.").
        setStage("Circularization").
        runpath("0:/SpaceCore/CircToAp").
    }
} else {
    logMsg("Vessel already in orbit. Proceeding with mission.").
}

// ADDITION: Deploy all bays, solar panels, and antennas once in orbit
logMsg("Deploying solar panels, bays, and antennas.").
panels on.
bays on.
for p in ship:parts {
    for m in p:modules {
        local mName is m:tostring:tolower.
        if mName:contains("antenna") or mName:contains("data") or mName:contains("comm") {
            local pMod is p:getmodule(m).
            if pMod:hasevent("extend antenna") {
                pMod:doevent("extend antenna").
            }
        }
    }
}

// 2. Align Plane with Minmus
set target to body("Minmus").
setStage("Plane Alignment").
logMsg("Calculating plane alignment with Minmus.").
local shipNormal is vcrs(ship:velocity:orbit, ship:position - ship:body:position):normalized.
local targetNormal is vcrs(target:velocity:orbit, target:position - ship:body:position):normalized.
local relInc is arccos(clamp(vdot(shipNormal, targetNormal), -1, 1)).

if relInc > 0.05 {
    local r_ship is ship:position - ship:body:position.
    local r_AN is vcrs(targetNormal, shipNormal):normalized.
    local angleToAN is vang(r_ship, r_AN).
    if vdot(vcrs(r_ship, r_AN), shipNormal) < 0 {
        set angleToAN to 360 - angleToAN.
    }
    local timeToAN is (angleToAN / 360) * ship:orbit:period.
    
    local r_DN is -r_AN.
    local angleToDN is vang(r_ship, r_DN).
    if vdot(vcrs(r_ship, r_DN), shipNormal) < 0 {
        set angleToDN to 360 - angleToDN.
    }
    local timeToDN is (angleToDN / 360) * ship:orbit:period.
    
    local burnTime is time:seconds + timeToAN.
    if timeToDN < timeToAN { set burnTime to time:seconds + timeToDN. }
    
    local v_at is velocityat(ship, burnTime):orbit.
    local r_at is positionat(ship, burnTime) - positionat(ship:body, burnTime).
    local u_target is vcrs(targetNormal, r_at):normalized.
    local v_target is v_at:mag * u_target.
    local dVVec is v_target - v_at.
    
    createNodeFromVector(burnTime, dVVec).
    logMsg("Executing Plane Change Burn.").
    runpath("0:/SpaceCore/ExeNode.ks").
} else {
    logMsg("Plane already aligned.").
}

// 3. Hohmann Transfer
setStage("Hohmann Transfer").
logMsg("Calculating transfer to Minmus using Astrogator.").
local bms is addons:astrogator:calculateBurns(target).

if bms:length = 0 {
    logMsg("CRITICAL ERROR: Astrogator failed to calculate transfer burns!").
} else {
    local bm is bms[0].
    
    local timeToWindow is bm:atTime - time:seconds.
    local incDiff is abs(target:orbit:inclination - ship:orbit:inclination).
    local dvNeeded is bm:totalDV.
    local dvAvail is ship:stagedeltav(ship:stagenum):current. // Current stage dv. Or ship:deltav:current.
    
    // Fallback if stagedeltav doesn't work, use ship:deltav:current
    if dvAvail = 0 { set dvAvail to ship:deltav:current. }

    logMsg("Astrogator Transfer Data:").
    logMsg(" - Transfer Window: T-" + round(timeToWindow) + "s").
    logMsg(" - Relative Inclination: " + round(incDiff, 2) + " deg").
    logMsg(" - Delta-V Needed: " + round(dvNeeded, 1) + " m/s").
    logMsg(" - Delta-V Available: " + round(dvAvail, 1) + " m/s").
    
    if dvAvail < dvNeeded {
        logMsg("WARNING: Insufficient Delta-V for maneuver!").
    }
    
    add bm:toNode.
    wait 0.1.
    logMsg("Transfer node created via Astrogator.").
}
runpath("0:/SpaceCore/ExeNode.ks").

// 4. Coast to Minmus
setStage("Coasting").
logMsg("Transfer burn complete. Coasting to Minmus SOI.").
wait until orbit:hasnextpatch and orbit:nextpatch:body:name = "Minmus".
local timeToSOI is orbit:nextpatch:eta.
safeCoast(time:seconds + timeToSOI + 10).

wait until ship:body:name = "Minmus".
logMsg("Entered Minmus SOI!").

// 5. Capture Burn
setStage("Capture").
logMsg("Waiting for Minmus periapsis to capture.").
safeCoast(time:seconds + eta:periapsis - 60).

logMsg("Calculating capture burn for 20km orbit.").
local r_peri is ship:periapsis + body:radius.
local r_apo_tgt is targetPe + body:radius. // 20km
local a_tgt is (r_peri + r_apo_tgt) / 2.
local v_tgt is sqrt(body:mu * (2/r_peri - 1/a_tgt)).
local v_peri_pred is sqrt(body:mu * (2/r_peri - 1/orbit:semimajoraxis)).
local dV_cap is v_peri_pred - v_tgt.

local nd_cap is node(time:seconds + eta:periapsis, 0, 0, -dV_cap).
add nd_cap.
runpath("0:/SpaceCore/ExeNode.ks").

// 6. Polar Inclination Change
setStage("Inclination Change").
logMsg("Adjusting to polar orbit (90 deg inclination).").
runpath("0:/SpaceCore/ChangeInc.ks", 90).

// 7. Final Circularization
setStage("Circularization").
logMsg("Finalizing low 20km orbit.").
runpath("0:/SpaceCore/CircToAp").
runpath("0:/SpaceCore/ChangeAp.ks", 20).
runpath("0:/SpaceCore/ChangePe.ks", 20).

setStage("Mission Complete").
logMsg("Minmus automation mission completed successfully! Orbit is polar 20km.").
