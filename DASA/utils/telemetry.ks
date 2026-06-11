@LAZYGLOBAL OFF.

GLOBAL telemetryFile IS "0:/telemetry/telemetry.json".
GLOBAL telemetryStage IS "Booting".
GLOBAL maxQVal IS 0.
GLOBAL maxQTime IS 0.
GLOBAL maxQLogged IS FALSE.
GLOBAL hadConnection IS TRUE.

GLOBAL FUNCTION updateTelemetry {
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

GLOBAL FUNCTION setStage {
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
