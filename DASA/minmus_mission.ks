@LAZYGLOBAL OFF.

// ------------------------------------------------------------------------
// Minmus Automation Mission Script
// Flow: Pre-launch -> Launch -> Circularization -> Minmus Plane Alignment ->
//       Hohmann Transfer -> Coasting (Science/Power) -> Capture -> Polar Orbit
// ------------------------------------------------------------------------

LOCAL telemetryFile IS "0:/telemetry/telemetry.json".
LOCAL missionLogPath IS "0:/logs/log.txt".
GLOBAL hadConnection IS TRUE.
GLOBAL localLogPath IS "1:/local_log.txt".
LOCAL apuState IS FALSE.
LOCAL lastPowerCheck IS TIME:SECONDS + 60.
GLOBAL telemetryStage IS "Booting".
GLOBAL missionMilestones IS LIST().
LOCAL lastTelemetryUpdate IS 0.
GLOBAL maxQVal IS 0.
GLOBAL maxQTime IS 0.
GLOBAL maxQLogged IS FALSE.

IF exists("0:/logs/mission_history.log") {
    deletepath("0:/logs/mission_history.log").
}
IF exists(missionLogPath) {
    deletepath(missionLogPath).
}

RUNONCEPATH("0:/DASA/HUD.ks").
RUNONCEPATH("0:/MJ/MJ.ks").

// ------------------------------------------------------------------------
// Helpers: Logging and Telemetry
// ------------------------------------------------------------------------
GLOBAL FUNCTION formatTime {
    PARAMETER t.
    LOCAL h IS FLOOR(t / 3600).
    LOCAL m IS FLOOR(MOD(t, 3600) / 60).
    LOCAL s IS FLOOR(MOD(t, 60)).
    
    LOCAL hStr IS h:TOSTRING.
    IF h < 10 { SET hStr TO "0" + hStr. }
    
    LOCAL mStr IS m:TOSTRING.
    IF m < 10 { SET mStr TO "0" + mStr. }
    
    LOCAL sStr IS s:TOSTRING.
    IF s < 10 { SET sStr TO "0" + sStr. }
    
    RETURN hStr + ":" + mStr + ":" + sStr.
}

GLOBAL FUNCTION logMsg {
    PARAMETER msg.
    LOCAL tStr IS "T+".
    LOCAL tVal IS MISSIONTIME.
    IF HASNODE {
        SET tVal TO NEXTNODE:ETA.
        IF tVal < 0 {
            SET tStr TO "T-".
            SET tVal TO 0-tVal.
        } ELSE {
            SET tStr TO "T+".
        }
    }
    LOCAL line IS "[" + tStr + formatTime(tVal) + "] " + msg.
    PRINT line.
    missionMilestones:ADD(line).

    IF homeconnection:isconnected {
        // If we have local logs cached from blackout, flush them to archive
        IF exists(localLogPath) {
            LOCAL f IS open(localLogPath).
            FOR l IN f:readall {
                LOG l TO missionLogPath.
            }
            deletepath(localLogPath).
        }
        LOG line TO missionLogPath.
    } ELSE {
        LOG line TO localLogPath.
    }
}

FUNCTION updateTelemetry {
    PARAMETER stageName.
    LOCAL ec IS SHIP:ELECTRICCHARGE.
    LOCAL ecMax IS 0.
    FOR r IN SHIP:RESOURCES {
        IF r:NAME = "ElectricCharge" {
            SET ecMax TO r:CAPACITY.
        }
    }

    LOCAL currentMass IS SHIP:MASS.
    LOCAL currentThrust IS SHIP:AVAILABLETHRUST.
    LOCAL r_dist IS BODY:RADIUS + SHIP:ALTITUDE.
    LOCAL grav IS BODY:MU / (r_dist * r_dist).
    LOCAL currentTwr IS 0.
    IF grav > 0 AND currentMass > 0 { SET currentTwr TO currentThrust / (currentMass * grav). }
    LOCAL currentQ IS SHIP:DYNAMICPRESSURE.

    LOCAL dq IS char(34).

    // Construct parts array
    LOCAL partsJson IS "[".
    LOCAL first IS TRUE.
    FOR p IN SHIP:parts {
        IF NOT first {
            SET partsJson TO partsJson + ", ".
        }
        SET first TO FALSE.
        LOCAL pName IS p:NAME:replace(dq, "").
        LOCAL pTitle IS p:title:replace(dq, "").
        LOCAL pTag IS p:tag:replace(dq, "").
        SET partsJson TO partsJson + "{" + dq + "uid" + dq + ":" + dq + p:uid + dq + "," + dq + "name" + dq + ":" + dq + pName + dq + "," + dq + "title" + dq + ":" + dq + pTitle + dq + "," + dq + "tag" + dq + ":" + dq + pTag + dq + "}".
    }
    SET partsJson TO partsJson + "]".

    // Construct all resources array/object
    LOCAL resJson IS "{".
    LOCAL firstRes IS TRUE.
    FOR r IN SHIP:RESOURCES {
        IF NOT firstRes {
            SET resJson TO resJson + ", ".
        }
        SET firstRes TO FALSE.
        SET resJson TO resJson + dq + r:NAME + dq + ": {" + dq + "amount" + dq + ":" + ROUND(r:AMOUNT, 1) + "," + dq + "capacity" + dq + ":" + ROUND(r:CAPACITY, 1) + "}".
    }
    SET resJson TO resJson + "}".

    // Construct closest POI (Waypoint)
    LOCAL closestPoiName IS "None".
    LOCAL closestPoiDist IS 0.
    LOCAL minPoiDist IS 999999999999.
    FOR wp IN allwaypoints() {
        IF wp:BODY:NAME = SHIP:BODY:NAME {
            LOCAL dist IS wp:position:MAG.
            IF dist < minPoiDist {
                SET minPoiDist TO dist.
                SET closestPoiName TO wp:NAME.
                SET closestPoiDist TO dist.
            }
        }
    }

    // Construct Target Info
    LOCAL hasTgt IS FALSE.
    LOCAL hasTgtStr IS "false".
    LOCAL tgtName IS "None".
    LOCAL tgtDist IS 0.
    LOCAL tgtRelV IS 0.
    IF hastarget {
        SET hasTgt TO TRUE.
        SET hasTgtStr TO "true".
        SET tgtName TO TARGET:NAME.
        SET tgtDist TO TARGET:position:MAG.
        SET tgtRelV TO (TARGET:VELOCITY:ORBIT - SHIP:VELOCITY:ORBIT):MAG.
    }

    // Construct JSON string
    LOCAL jsonStr IS "{".
    SET jsonStr TO jsonStr + dq + "time" + dq + ": " + ROUND(MISSIONTIME, 1) + ", ".
    SET jsonStr TO jsonStr + dq + "vessel" + dq + ": " + dq + SHIP:NAME + dq + ", ".
    SET jsonStr TO jsonStr + dq + "stage" + dq + ": " + dq + stageName + dq + ", ".
    SET jsonStr TO jsonStr + dq + "altitude" + dq + ": " + ROUND(SHIP:ALTITUDE) + ", ".
    SET jsonStr TO jsonStr + dq + "periapsis" + dq + ": " + ROUND(SHIP:PERIAPSIS) + ", ".
    SET jsonStr TO jsonStr + dq + "apoapsis" + dq + ": " + ROUND(SHIP:APOAPSIS) + ", ".
    SET jsonStr TO jsonStr + dq + "inclination" + dq + ": " + ROUND(SHIP:ORBIT:inclination, 2) + ", ".
    SET jsonStr TO jsonStr + dq + "velocity" + dq + ": " + ROUND(SHIP:VELOCITY:ORBIT:MAG) + ", ".
    SET jsonStr TO jsonStr + dq + "electricCharge" + dq + ": " + ROUND(ec) + ", ".
    SET jsonStr TO jsonStr + dq + "electricChargeMax" + dq + ": " + ROUND(ecMax) + ", ".
    SET jsonStr TO jsonStr + dq + "twr" + dq + ": " + ROUND(currentTwr, 2) + ", ".
    SET jsonStr TO jsonStr + dq + "q" + dq + ": " + ROUND(currentQ, 4) + ", ".
    SET jsonStr TO jsonStr + dq + "body" + dq + ": " + dq + SHIP:BODY:NAME + dq + ", ".
    SET jsonStr TO jsonStr + dq + "resources" + dq + ": " + resJson + ", ".
    SET jsonStr TO jsonStr + dq + "closestPoi" + dq + ": {" + dq + "name" + dq + ":" + dq + closestPoiName + dq + "," + dq + "distance" + dq + ":" + ROUND(closestPoiDist) + "}, ".
    SET jsonStr TO jsonStr + dq + "target" + dq + ": {" + dq + "hasTarget" + dq + ":" + hasTgtStr + "," + dq + "name" + dq + ":" + dq + tgtName + dq + "," + dq + "distance" + dq + ":" + ROUND(tgtDist) + "," + dq + "relVelocity" + dq + ":" + ROUND(tgtRelV, 2) + "}, ".

    // Construct Attitude Info
    LOCAL upVec IS SHIP:UP:vector.
    LOCAL northVec IS SHIP:NORTH:vector.
    LOCAL eastVec IS VCRS(upVec, northVec):normalized.
    LOCAL foreVec IS SHIP:FACING:FOREVECTOR.
    LOCAL topVec IS SHIP:FACING:topvector.

    LOCAL fx IS ROUND(VDOT(foreVec, eastVec), 4).
    LOCAL fy IS ROUND(VDOT(foreVec, northVec), 4).
    LOCAL fz IS ROUND(VDOT(foreVec, upVec), 4).
    LOCAL tx IS ROUND(VDOT(topVec, eastVec), 4).
    LOCAL ty IS ROUND(VDOT(topVec, northVec), 4).
    LOCAL tz IS ROUND(VDOT(topVec, upVec), 4).

    SET jsonStr TO jsonStr + dq + "attitude" + dq + ": {" + dq + "fore" + dq + ": [" + fx + "," + fy + "," + fz + "]," + dq + "top" + dq + ": [" + tx + "," + ty + "," + tz + "]}, ".

    LOCAL bHasNode IS HASNODE.
    IF bHasNode {
        SET jsonStr TO jsonStr + dq + "maneuver" + dq + ": { " + dq + "hasNode" + dq + ": true, " + dq + "eta" + dq + ": " + ROUND(NEXTNODE:ETA, 1) + ", " + dq + "dv" + dq + ": " + ROUND(NEXTNODE:DELTAV:MAG, 1) + " }, ".
    } ELSE {
        SET jsonStr TO jsonStr + dq + "maneuver" + dq + ": { " + dq + "hasNode" + dq + ": false, " + dq + "eta" + dq + ": 0, " + dq + "dv" + dq + ": 0 }, ".
    }

    SET jsonStr TO jsonStr + dq + "parts" + dq + ": " + partsJson + ", ".

    LOCAL milestonesJson IS "[".
    LOCAL firstMilestone IS TRUE.
    FOR ms IN missionMilestones {
        IF NOT firstMilestone { SET milestonesJson TO milestonesJson + ", ". }
        SET firstMilestone TO FALSE.
        SET milestonesJson TO milestonesJson + dq + ms:replace(dq, "") + dq.
    }
    SET milestonesJson TO milestonesJson + "]".

    SET jsonStr TO jsonStr + dq + "milestones" + dq + ": " + milestonesJson.
    SET jsonStr TO jsonStr + "}".

    // Only write telemetry to archive if KSC connection is active to prevent kOS crash
    IF homeconnection:isconnected {
        IF exists(telemetryFile) {
            deletepath(telemetryFile).
        }
        LOG jsonStr TO telemetryFile.
    }
}

FUNCTION setStage {
    PARAMETER newStage.
    CLEARSCREEN.
    PRINT("==================================================").
    logMsg("       Stage: " + newStage).
    PRINT("==================================================").
    PRINT(" ").
    SET telemetryStage TO newStage.
    updateTelemetry(telemetryStage).

    IF homeconnection:isconnected {
        LOCAL histFile IS "0:/logs/mission_history.log".
        IF NOT exists(histFile) {
            LOG "Time,Stage,Body,Alt,Pe,Ap,Inc,EC_pct,Vel" TO histFile.
        }

        LOCAL ec IS 0.
        LOCAL ecMax IS 1.
        FOR r IN SHIP:RESOURCES {
            IF r:NAME = "ElectricCharge" {
                SET ec TO r:AMOUNT.
                SET ecMax TO MAX(0.1, r:CAPACITY).
            }
        }
        LOCAL ecPct IS ROUND((ec/ecMax)*100, 1).
        LOCAL logLine IS ROUND(MISSIONTIME) + "," + newStage + "," + SHIP:BODY:NAME + "," + ROUND(SHIP:ALTITUDE) + "," + ROUND(SHIP:PERIAPSIS) + "," + ROUND(SHIP:APOAPSIS) + "," + ROUND(SHIP:ORBIT:inclination, 1) + "," + ecPct + "," + ROUND(SHIP:VELOCITY:ORBIT:MAG).
        LOG logLine TO histFile.
    }
}

LOCAL aborted IS FALSE.

WHEN ABORT THEN {
    SET aborted TO TRUE.
    setStage("Aborted").
    logMsg("--- MISSION ABORTED ---").
}

// ------------------------------------------------------------------------
// Helpers: Subsystems (Power & Science)
// ------------------------------------------------------------------------
FUNCTION setAPUState {
    PARAMETER state.
    LOCAL stateStr IS "OFF".
    IF state { SET stateStr TO "ON". }
    logMsg("Setting Fuel Cells/APUs to " + stateStr).

    FOR p IN SHIP:parts {
        FOR mName IN p:modules {
            LOCAL pMod IS p:getmodule(mName).
            FOR ev IN pMod:allevents {
                LOCAL evLower IS ev:tolower.
                IF state {
                    IF (evLower:contains("start") OR evLower:contains("activate") OR evLower:contains("enable")) AND (evLower:contains("cell") OR evLower:contains("gen") OR evLower:contains("apu") OR evLower:contains("power")) {
                        pMod:doevent(ev).
                        logMsg("APU ON: " + ev + " on " + p:title).
                    }
                } ELSE {
                    IF (evLower:contains("stop") OR evLower:contains("deactivate") OR evLower:contains("disable")) AND (evLower:contains("cell") OR evLower:contains("gen") OR evLower:contains("apu") OR evLower:contains("power")) {
                        pMod:doevent(ev).
                        logMsg("APU OFF: " + ev + " on " + p:title).
                    }
                }
            }
        }
    }
}

FUNCTION checkPower {
    LOCAL ec IS SHIP:ELECTRICCHARGE.
    LOCAL ecMax IS 0.
    FOR r IN SHIP:RESOURCES {
        IF r:NAME = "ElectricCharge" { SET ecMax TO r:CAPACITY. }
    }
    IF ecMax > 0 {
        LOCAL pct IS ec / ecMax.
        IF pct < 0.20 {
            logMsg("LOW POWER.").
            IF NOT apuState {
                logMsg("CRITICAL POWER: Starting APUs.").
                setAPUState(TRUE).
                SET apuState TO TRUE.
            }
            IF LIGHTS {
                LIGHTS OFF.
                logMsg("CRITICAL POWER: Turning off lights to conserve energy.").
            }
        } ELSE IF pct > 0.95 {
            IF apuState {
                logMsg("Power restored. Stopping APUs.").
                setAPUState(FALSE).
                SET apuState TO FALSE.
            }
        }

        // Turn lights on if in orbit and power is stable (>20%)
        IF pct >= 0.20 AND (SHIP:STATUS = "ORBITING" OR SHIP:STATUS = "ESCAPING") {
            spinload(10).
            spinload_clear().
            IF NOT LIGHTS {
                LIGHTS ON.
                logMsg("Vessel in orbit with stable power. Turning lights on.").
            }
        }
    }
}

FUNCTION runAllScience {
    logMsg("Triggering all science experiments...").
    FOR p IN SHIP:parts {
        FOR mName IN p:modules {
            LOCAL mNameLower IS mName:tolower.
            IF mNameLower:contains("science") OR mNameLower:contains("experiment") OR mNameLower:contains("sensor") {
                LOCAL pMod IS p:getmodule(mName).
                IF pMod:hasfield("deploy") OR pMod:hasevent("deploy") {
                    pMod:doevent("deploy").
                }
                FOR ev IN pMod:allevents {
                    LOCAL evLower IS ev:tolower.
                    IF evLower:contains("start") OR evLower:contains("deploy") OR evLower:contains("run") OR evLower:contains("collect") {
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
FUNCTION safeCoast { // STOPS ONE MINUTE BEFORE TARGET T
    PARAMETER targetTime.
    setStage("Coasting").

    // Point the right/starboard side at the sun by facing 90 degrees away in yaw
    UNTIL TIME:SECONDS >= targetTime - 60 {
        LOCK STEERING TO LOOKDIRUP(SUN:POSITION, SHIP:FACING:UPVECTOR) * R(0, -90, 0).
        checkPower().
        runAllScience().

        LOCAL timeLeft IS targetTime - TIME:SECONDS.
        IF timeLeft > 3600 {
            LOCAL nextStop IS MIN(TIME:SECONDS + 3600, targetTime - 60).
            SET WARPMODE TO "rails".
            logMsg("Warping to next stop.").
            WARPTO(nextStop).
            WAIT UNTIL TIME:SECONDS >= nextStop - 5.
        } ELSE IF timeLeft > 300 {
            LOCAL nextStop IS targetTime - 60.
            SET WARPMODE TO "rails".
            logMsg("Warping to next stop.").
            WARPTO(nextStop).
            WAIT UNTIL TIME:SECONDS >= nextStop - 5.
        } ELSE {
            WAIT 1.
        }
    }
    logMsg("Ending Coasting Phase.").
    UNLOCK STEERING.
}

// ------------------------------------------------------------------------
// Math & Orbital Node Calculation
// ------------------------------------------------------------------------
FUNCTION clamp {
    PARAMETER val, mn, mx.
    IF val < mn RETURN mn.
    IF val > mx RETURN mx.
    RETURN val.
}

FUNCTION createNodeFromVector {
    PARAMETER burnTime, dVVector.
    LOCAL r_at IS positionat(SHIP, burnTime) - positionat(SHIP:BODY, burnTime).
    LOCAL v_at IS velocityat(SHIP, burnTime):ORBIT.

    LOCAL pro_dir IS v_at:normalized.
    LOCAL norm_dir IS VCRS(v_at, r_at):normalized.
    LOCAL rad_dir IS VCRS(pro_dir, norm_dir):normalized.

    LOCAL dV_pro IS VDOT(dVVector, pro_dir).
    LOCAL dV_norm IS VDOT(dVVector, norm_dir).
    LOCAL dV_rad IS VDOT(dVVector, rad_dir).

    LOCAL nd IS NODE(burnTime, dV_rad, dV_norm, dV_pro).
    ADD nd.
    RETURN nd.
}



// ------------------------------------------------------------------------
// Main Mission Sequence
// ------------------------------------------------------------------------
// Start background power and subsystem monitor trigger (runs every 5 seconds)

WHEN TIME:SECONDS > lastPowerCheck + 5 THEN {
    SET lastPowerCheck TO TIME:SECONDS.
    checkPower().
    PRESERVE.
}

WHEN TIME:SECONDS > lastTelemetryUpdate + 0.2 THEN {
    LOCAL hasConn IS homeconnection:isconnected.
    IF hasConn <> hadConnection {
        IF hasConn {
            logMsg("--- SIGNAL RESTORED: Reconnected to KSC. ---").
        } ELSE {
            logMsg("--- SIGNAL LOST: Connection to KSC lost. ---").
        }
        SET hadConnection TO hasConn.
    }

    IF telemetryStage = "Ascent" AND NOT maxQLogged {
        LOCAL currentQ IS SHIP:DYNAMICPRESSURE.
        IF currentQ > maxQVal {
            SET maxQVal TO currentQ.
            SET maxQTime TO MISSIONTIME.
        } ELSE IF currentQ < maxQVal - 0.01 AND maxQVal > 0.05 AND MISSIONTIME > maxQTime + 2 {
            SET maxQLogged TO TRUE.
            logMsg("Max Q reached: " + ROUND(maxQVal * 101.325, 2) + " kPa").
        }
    }

    updateTelemetry(telemetryStage).
    SET lastTelemetryUpdate TO TIME:SECONDS.
    PRESERVE.
}

setStage("Booting").
logMsg("Minmus Mission Initialized.").


IF NOT exists("0:/telemetry/vessel_structure.json") {
    logMsg("No existing vessel structure found. Forcing scan...").
    WAIT 1.
    RUNPATH("0:/DASA/VesselScan.ks").
}

PRINT "Scan vessel structure? (y/n)".
LOCAL scanChoice IS "".
UNTIL scanChoice = "y" OR scanChoice = "n" {
    SET scanChoice TO terminal:input:getchar().
}
IF scanChoice = "y" {
    RUNPATH("0:/DASA/VesselScan.ks").
} ELSE {
    logMsg("Skipping vessel scan. Dashboard will use existing vessel structure.").
    WAIT 0.2.
}

LOCAL skipDeployment IS FALSE.
// 1. Wait for deployment / Pre-launch
IF SHIP:STATUS = "PRELAUNCH" OR SHIP:STATUS = "LANDED" OR (SHIP:STATUS = "FLYING" AND SHIP:ALTITUDE < 70000) {
    setStage("Pre-Launch").
    SAS ON.
    logMsg("Vessel is pre-launch/flying. Waiting for staging to initiate launch.").
    WAIT UNTIL MAXTHRUST > 0.

    logMsg("Launch detected! Ascending to 80km orbit.").
    setStage("Ascent").
    RUNPATH("0:/MJ/MJAscent.ks", FALSE, 80, 0, 60).

    IF SHIP:PERIAPSIS < 70000 {
        logMsg("Circularizing at Apoapsis.").
        setStage("Circularization").
        RUNPATH("0:/MJ/MJCircToAp.ks").
    }
} ELSE {
    IF PANELS {
        SET skipDeployment TO TRUE.
    }
    FOR p IN SHIP:parts {
        HUD_loading().
        FOR m IN p:modules {
            LOCAL mName IS m:tostring:tolower.
            IF mName:contains("solar") OR mName:contains("panel") {
                LOCAL pMod IS p:getmodule(m).
                IF pMod:hasfield("state") {
                    LOCAL st IS pMod:getfield("state"):tolower.
                    IF st:contains("extend") {
                        SET skipDeployment TO TRUE.
                    }
                }
            }
        }
    }
    IF skipDeployment {
        logMsg("Vessel already in orbit with panels active. Skipping jettison & deployment.").
    } ELSE {
        logMsg("Vessel already in orbit. Proceeding with mission.").
        spinload(10).
        spinload_clear().
        CLEARSCREEN.
    }
}

// ADDITION: Deploy all bays, solar panels, and antennas once in orbit
IF NOT skipDeployment {
    LOCAL fairingModules IS LIST().
    LOCAL deployableModules IS LIST().

    // Walk the parts tree once to categorize all modules
    FOR p IN SHIP:parts {
        HUD_loading().
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

            // Fairings
            IF mName:contains("fairing") OR mName:contains("jettison") OR mName:contains("shroud") {
                fairingModules:ADD(pMod).
            }

            // Deployables
            LOCAL isDeployableModule IS FALSE.
            IF mName:contains("solar") OR mName:contains("panel") OR mName:contains("antenna")
               OR mName:contains("transmit") OR mName:contains("comm") OR mName:contains("animate")
               OR mName:contains("deploy") OR mName:contains("dish") OR mName:contains("boom") {
                SET isDeployableModule TO TRUE.
            }
            IF isAntennaOrPanelPart OR isDeployableModule {
                deployableModules:ADD(pMod).
            }
        }
    }

    logMsg("Jettisoning all fairings...").
    FOR pMod IN fairingModules {
        FOR ev IN pMod:alleventnames {
            LOCAL evLower IS ev:tolower.
            IF evLower:contains("deploy") OR evLower:contains("jettison") OR evLower:contains("open") OR evLower:contains("release") {
                pMod:doevent(ev).
                logMsg("Jettisoned fairing: " + ev + " on " + pMod:part:title).
                HUD_loading().
            }
        }
    }

    spinload(10). // Wait for fairing separation physics

    logMsg("Deploying solar panels, bays, and antennas.").
    PANELS ON.
    bays ON.

    FOR pMod IN deployableModules {
        FOR ev IN pMod:alleventnames {
            LOCAL evLower IS ev:tolower.
            IF evLower:contains("extend") OR evLower:contains("deploy") OR evLower:contains("open")
               OR evLower:contains("activate") OR evLower:contains("toggle") OR evLower:contains("start") {
                IF NOT (evLower:contains("retract") OR evLower:contains("close") OR evLower:contains("stop")
                        OR evLower:contains("disable") OR evLower:contains("shutdown") OR evLower:contains("jettison")) {
                    pMod:doevent(ev).
                    logMsg(pMod:part:title + ": " + ev).
                    HUD_loading().
                }
            }
        }
    }
}
spinload_clear().

// 2. Interrogate Astrogator
SET TARGET TO BODY("Minmus").
setStage("Hohmann Transfer").
logMsg("Interrogating Astrogator for transfer window and node information...").
spinload(5).
spinload_clear().

// Clear any existing nodes BEFORE calling Astrogator
UNTIL NOT HASNODE {
    REMOVE NEXTNODE.
    WAIT 0.05.
}

LOCAL bms IS ADDONS:astrogator:calculateBurns(TARGET).

IF bms:length = 0 {
    logMsg("CRITICAL ERROR: Astrogator failed to calculate transfer burns!").
    logMsg("Switching to basic probe survival routine.").
    RUNPATH("0:/DASA/basic_probe_routine.ks").
} ELSE {
    logMsg("Astrogator provided " + bms:length + " maneuver(s).").

    // Log details of all burns
    FROM {LOCAL i IS 0.} UNTIL i >= bms:length STEP {SET i TO i+1.} DO {
        LOCAL bm IS bms[i].
        LOCAL tToBurn IS bm:atTime - TIME:SECONDS.
        logMsg(" - Node " + i + ": T-" + ROUND(tToBurn) + "s | dV: " + ROUND(bm:totalDV, 1) + " m/s").
    }

    LOCAL bm IS bms[0].
    LOCAL timeToWindow IS bm:atTime - TIME:SECONDS.
    LOCAL incDiff IS abs(TARGET:ORBIT:inclination - SHIP:ORBIT:inclination).
    LOCAL dvNeeded IS bm:totalDV.
    LOCAL dvAvail IS 0.
    IF ADDONS:AVAILABLE("KER") {
        SET dvAvail TO ADDONS:ker:DELTAV.
    } ELSE {
        SET dvAvail TO SHIP:DELTAV:current.
    }

    logMsg("Primary Transfer Node Details:").
    logMsg(" - Relative Inclination: " + ROUND(incDiff, 2) + " deg").
    logMsg(" - Delta-V Available: " + ROUND(dvAvail, 1) + " m/s").
    wait 1.

    IF dvAvail < dvNeeded {
        logMsg("WARNING: Insufficient Delta-V for maneuver!").
    }

    // Execute each burn model sequentially: add node manually, wait for it, execute, then clear.
    FROM {LOCAL i IS 0.} UNTIL i >= bms:length STEP {SET i TO i+1.} DO {
        LOCAL bm IS bms[i].
        logMsg("Adding node " + i + " to flight plan").

        // Clear any leftover nodes first
        IF HASNODE {
            REMOVE NEXTNODE.
        }

        // Manually add this burn model as a maneuver node
        PRINT "[DEBUG] Instantiating node " + i + " from Astrogator.".
        LOCAL myNode IS bm:toNode.
        spinload(10). // NEEDED for the NODE
        spinload_clear().
        IF NOT HASNODE {
            PRINT "[DEBUG] Node not automatically added by toNode. Adding it manually...".
            ADD myNode.
        }

        // Wait up to 5 seconds for the node to appear on the flight plan
        LOCAL waitStart IS TIME:SECONDS.
        UNTIL HASNODE OR (TIME:SECONDS - waitStart > 5) {
            spinload(1).
        }

        IF NOT HASNODE {
            logMsg("WARNING: Node " + i + " did not appear on flight plan after 5s. Skipping.").
            PRINT "[DEBUG] hasnode timeout for node " + i + ".".
        } ELSE {
            // Coast safely to node
            IF myNode:ETA > 120 {
                safeCoast(TIME:SECONDS + myNode:ETA).
            }

            logMsg("Executing node " + i + "...").
            spinload(10).
            spinload_clear().
            RUNPATH("0:/MJ/ExeNode.ks").
            PRINT "[DEBUG] Execution of node " + i + " returned.".
        }
    }
}

// 4. Coast to Minmus
setStage("Coasting").
spinload(10).
spinload_clear().
logMsg("Transfer burn complete. Coasting to Minmus SOI.").
WAIT UNTIL ORBIT:hasnextpatch AND ORBIT:nextpatch:BODY:NAME = "Minmus".
LOCAL timeToSOI IS ETA:TRANSITION.
safeCoast(TIME:SECONDS + timeToSOI).

WAIT UNTIL SHIP:BODY:NAME = "Minmus".
logMsg("Entered Minmus SOI!").

// 5. Capture Burn
setStage("Capture").
logMsg("Waiting for Minmus periapsis to capture.").
safeCoast(TIME:SECONDS + ETA:PERIAPSIS - 60).

logMsg("Calculating capture burn for 20km orbit.").
LOCAL r_peri IS SHIP:PERIAPSIS + BODY:RADIUS.
LOCAL targetPe IS 20000.
LOCAL r_apo_tgt IS targetPe + BODY:RADIUS. // 20km
LOCAL a_tgt IS (r_peri + r_apo_tgt) / 2.
LOCAL v_tgt IS sqrt(BODY:MU * (2/r_peri - 1/a_tgt)).
LOCAL v_peri_pred IS sqrt(BODY:MU * (2/r_peri - 1/ORBIT:semimajoraxis)).
LOCAL dV_cap IS v_peri_pred - v_tgt.

LOCAL nd_cap IS NODE(TIME:SECONDS + ETA:PERIAPSIS, 0, 0, -dV_cap).
ADD nd_cap.
RUNPATH("0:/MJ/ExeNode.ks").

// 6. Polar Inclination Change
setStage("Inclination Change").
logMsg("Adjusting to polar orbit (90 deg inclination).").
RUNPATH("0:/MJ/MJChangeInc.ks", 90).

// 6. Circularize
setStage("Circularize").
logMsg("Circularizing at Minmus Apoapsis.").
RUNPATH("0:/MJ/MJCircToAp.ks").
RUNPATH("0:/MJ/MJChangeAp.ks", 20).
RUNPATH("0:/MJ/MJChangePe.ks", 20).

setStage("Mission Complete").
logMsg("Minmus automation mission completed successfully! Orbit is polar 20km.").
