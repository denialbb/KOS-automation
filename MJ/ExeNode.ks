@LAZYGLOBAL OFF.

IF NOT HASNODE {
    PRINT "ExeNode: No maneuver node present. Aborting.".
    IF DEFINED logMsg { logMsg("ExeNode called with no active maneuver node. Skipping."). }
    ABORT.
}

LOCAL nd IS NEXTNODE.
CLEARSCREEN.
LOCAL running IS TRUE.

WHEN TRUE THEN {
    IF NOT running {
        // cleanup
    } ELSE {
        PRINT "--- MANEUVER NODE INFO ---" AT (0,2).
        PRINT "Total maneuver delta-V: "+ ROUND(nd:DELTAV:MAG,1)+" m/s       " AT (0,3).
        LOCAL tLeft IS MAX(0, nd:ETA).
        LOCAL h IS FLOOR(tLeft / 3600).
        LOCAL m IS FLOOR(MOD(tLeft, 3600) / 60).
        LOCAL s IS FLOOR(MOD(tLeft, 60)).
        LOCAL hStr IS "" + h. IF h < 10 { SET hStr TO "0" + h. }
        LOCAL mStr IS "" + m. IF m < 10 { SET mStr TO "0" + m. }
        LOCAL sStr IS "" + s. IF s < 10 { SET sStr TO "0" + s. }
        PRINT "Time to maneuver: T- " + hStr + ":" + mStr + ":" + sStr + "       " AT (0,4).
        PRINT "Remaining delta-V: "+ROUND(nd:DELTAV:MAG,1)+" m/s       " AT (0,5).
        PRESERVE.
    }
}

// Release kOS steering/throttle to prepare for autopilot handoff
UNLOCK STEERING.
UNLOCK THROTTLE.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

LOCAL mjNode IS ADDONS:MJ:NODE.

IF hasMjNode {
    PRINT "[MJ] Engaging MechJeb Node Executor...".
    SET mjNode:ENABLED TO TRUE.
    SET mjNode:AUTOWARP TO TRUE.

    //WAIT UNTIL NOT HASNODE.

    //PRINT "[MJ] Node execution complete.".
    SET mjNode:ENABLED TO FALSE.
} ELSE {
    PRINT "[ExeNode] Falling back to native kOS maneuver node execution.".

    LOCAL max_acc IS 0.
    IF SHIP:MASS > 0 { SET max_acc TO SHIP:AVAILABLETHRUST / SHIP:MASS. }
    IF max_acc = 0 {
        PRINT "WARNING: No thrust available. Waiting for active engine...".
        WAIT UNTIL SHIP:AVAILABLETHRUST > 0.
        SET max_acc TO SHIP:AVAILABLETHRUST / SHIP:MASS.
    }

    // Estimate Isp for exhaust velocity (ve) to get precise burn time
    LOCAL effIsp IS 0.
    LOCAL totalThrust IS 0.
    LOCAL totalFlow IS 0.

    LOCAL engList IS LIST().
    LIST ENGINES IN engList.
    FOR eng IN engList {
        IF eng:IGNITED AND eng:ISP > 0 {
            SET totalThrust TO totalThrust + eng:AVAILABLETHRUST.
            SET totalFlow TO totalFlow + (eng:AVAILABLETHRUST / (eng:ISP * 9.80665)).
        }
    }
    IF totalFlow > 0 {
        SET effIsp TO totalThrust / (totalFlow * 9.80665).
    } ELSE {
        FOR eng IN engList {
            IF eng:ISP > 0 {
                SET effIsp TO eng:ISP.
                BREAK.
            }
        }
        IF effIsp = 0 {
            SET effIsp TO 300. // fallback
        }
    }

    LOCAL g0 IS 9.80665.
    LOCAL ve IS effIsp * g0.
    LOCAL dv IS nd:DELTAV:MAG.
    LOCAL burn_time IS (dv * SHIP:MASS / MAX(1, SHIP:AVAILABLETHRUST)) * (1 - dv / (2 * ve)).
    PRINT "[ExeNode] Estimated burn duration: " + ROUND(burn_time, 2) + "s".

    // Orient ship to burn direction
    LOCAL burn_dir IS nd:DELTAV.
    LOCK STEERING TO burn_dir.

    // Warp to the burn start time if eta is long
    LOCAL burnStartEta IS nd:ETA - burn_time / 2.
    IF burnStartEta > 40 {
        PRINT "[ExeNode] Warping to burn window...".
        SET WARPMODE TO "rails".
        WARPTO(TIME:SECONDS + burnStartEta - 30).
        WAIT UNTIL nd:ETA - burn_time / 2 <= 35.
    }

    PRINT "[ExeNode] Aligning vessel...".
    WAIT UNTIL VANG(SHIP:FACING:FOREVECTOR, nd:DELTAV) < 1.5 AND nd:ETA <= burn_time / 2.

    PRINT "[ExeNode] Beginning burn...".
    LOCAL tVal IS 0.
    LOCK THROTTLE TO tVal.
    LOCAL initial_dv IS nd:DELTAV.
    LOCAL done IS FALSE.

    UNTIL done {
        // Handle staging during burn
        IF SHIP:AVAILABLETHRUST < 0.1 {
            STAGE.
            WAIT 0.5.
        }

        LOCAL rem_dv IS nd:DELTAV:MAG.
        LOCAL cur_acc IS 0.
        IF SHIP:MASS > 0 { SET cur_acc TO SHIP:AVAILABLETHRUST / SHIP:MASS. }

        // Freeze steering vector when delta-V is very low to prevent spin
        IF rem_dv > 1.0 {
            SET burn_dir TO nd:DELTAV.
        }

        // Precision throttle control
        IF rem_dv < 0.15 OR VDOT(initial_dv, nd:DELTAV) < 0 {
            SET done TO TRUE.
        } ELSE {
            IF cur_acc > 0 {
                SET tVal TO MIN(1, rem_dv / cur_acc).
            } ELSE {
                SET tVal TO 1.
            }
        }
        WAIT 0.
    }

    LOCK THROTTLE TO 0.
    UNLOCK THROTTLE.
    UNLOCK STEERING.
    PRINT "[ExeNode] Burn complete. Removing node.".
    REMOVE nd.
    WAIT 0.1.
}

SET running TO FALSE.
SAS ON.
CLEARSCREEN.