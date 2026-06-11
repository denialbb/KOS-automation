@LAZYGLOBAL OFF.

IF NOT HASNODE {
    IF DEFINED debugLog { debugLog("ExeNode: No maneuver node present. Aborting."). } ELSE { PRINT "ExeNode: No maneuver node present. Aborting.". }
    IF DEFINED logMsg { logMsg("ExeNode called with no active maneuver node. Abort."). }
    ABORT.
}

PRINT("==================================================").
PRINT "          EXECUTE NODE SEQUENCE INITIATED          ".
PRINT("==================================================").

LOCAL nd IS NEXTNODE.
LOCAL initial_dv_mag IS nd:DELTAV:MAG.
CLEARSCREEN.
LOCAL running IS TRUE.
RUNONCEPATH("0:/DASA/HUD.ks").
RUNONCEPATH("0:/MJ/MJ.ks").

// UI update loop removed from background trigger.

// Release kOS steering/throttle to prepare for autopilot handoff
UNLOCK STEERING.
UNLOCK THROTTLE.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

// Ensure we have active engines, if not wait.
LOCAL max_acc IS 0.
IF SHIP:MASS > 0 { SET max_acc TO SHIP:AVAILABLETHRUST / SHIP:MASS. }
IF max_acc = 0 {
    IF DEFINED debugLog { debugLog("WARNING: No thrust available. Waiting for active engine or staging..."). } ELSE { PRINT "WARNING: No thrust available. Waiting for active engine or staging...". }
    UNTIL SHIP:AVAILABLETHRUST > 0 {
        HUD_print_header("MANEUVER NODE INFO").
        HUD_print_node(initial_dv_mag, nd:DELTAV:MAG, nd:ETA).
        IF STAGE:READY {
            STAGE.
            WAIT 0.5.
        }
        WAIT 0.1.
        IF STAGE:NUMBER = 0 { BREAK. }
    }
}

LOCAL burn_time IS 0.
LOCAL t_half_dv IS 0.

IF ADDONS:AVAILABLE("KE") AND ADDONS:KE:HASSUFFIX("NODEBURNTIME") {
    logMsg("Kerbal Engineer available.").
    SET burn_time TO ADDONS:KE:NODEBURNTIME.
    SET t_half_dv TO ADDONS:KE:NODEHALFBURNTIME.
} ELSE {
    // Tsiolkovsky Burn Time Calculation
    logMsg("Tsiolkovsky calculating burn time...").
    LOCAL g0 IS 9.80665.
    LOCAL totalThrust IS 0.
    LOCAL totalFlow IS 0.
    LOCAL effIsp IS 0.

    LOCAL engList IS LIST().
    LIST ENGINES IN engList.
    WAIT 1.
    FOR eng IN engList {
        IF NOT eng:SHUTDOWN AND eng:ISP > 0 {
            SET totalThrust TO totalThrust + eng:AVAILABLETHRUST.
            SET totalFlow TO totalFlow + (eng:AVAILABLETHRUST / (eng:ISP * g0)).
        }
    }

    IF totalFlow > 0 {
        SET effIsp TO totalThrust / (totalFlow * g0).
    } ELSE {
        FOR eng IN engList {
            IF eng:ISP > 0 { SET effIsp TO eng:ISP. BREAK. }
        }
        IF effIsp = 0 { SET effIsp TO 300. }
    }

    LOCAL ve IS effIsp * g0.
    LOCAL dv IS nd:DELTAV:MAG.
    LOCAL m0 IS SHIP:MASS.

    LOCAL e_val IS CONSTANT:E.
    LOCAL massRatio IS e_val^(dv / ve).
    LOCAL m1 IS m0 / massRatio.
    LOCAL dm IS m0 - m1.

    IF totalFlow > 0 {
        SET burn_time TO dm / totalFlow.
    } ELSE {
        SET burn_time TO (dv * SHIP:MASS / MAX(1, SHIP:AVAILABLETHRUST)) * (1 - dv / (2 * ve)).
    }

    LOCAL massRatioHalf IS e_val^((dv / 2) / ve).
    LOCAL m1Half IS m0 / massRatioHalf.
    LOCAL dmHalf IS m0 - m1Half.

    IF totalFlow > 0 {
        SET t_half_dv TO dmHalf / totalFlow.
    } ELSE {
        SET t_half_dv TO burn_time / 2.
    }
}

logMsg("Est. burn duration: " + ROUND(burn_time, 2) + "s").

// Orient ship to burn direction
LOCAL burn_dir IS nd:DELTAV.
LOCK STEERING TO burn_dir.

// Warp to the burn start time if eta is long
LOCAL burnStartEta IS nd:ETA - t_half_dv.
IF burnStartEta > 40 {
    SET WARPMODE TO "rails".
    WARPTO(TIME:SECONDS + burnStartEta - 30).
    UNTIL (nd:ETA - t_half_dv) <= 35 {
        HUD_print_header("MANEUVER NODE INFO").
        HUD_print_node(nd:ETA, initial_dv_mag, nd:DELTAV:MAG, SHIP:DELTAV:CURRENT).
        WAIT 0.1.
    }
}

// Execute burn
IF ADDONS:AVAILABLE("MJ") AND ADDONS:MJ:HASSUFFIX("NODE") {  // ----------------------- MJ
    LOCAL nodeExecutor IS ADDONS:MJ:NODE.
    logMsg("MechJeb available.").
    mjReleaseControl().
    mjLog("Node planned. Executing via MechJeb...").
    SET nodeExecutor:ENABLED TO TRUE.
    mjLog("Executing Node - dV: " + ROUND(NEXTNODE:DELTAV:MAG, 2)).

    LOCAL nd IS NEXTNODE.
    UNTIL NOT HASNODE {
        UNTIL HASNODE AND NEXTNODE:DELTAV:MAG < 1  {
            HUD_print_header("MANEUVER NODE INFO").
            HUD_print_node(nd:ETA, initial_dv_mag, nd:DELTAV:MAG, SHIP:DELTAV:CURRENT).
            WAIT 0.1.
        }
        WAIT 0.5.
    }
    SET nodeExecutor:ENABLED TO FALSE.
    mjLog("Burn complete.").
} ELSE { // ----------------------------------------------------------------------------
    debugLog("[ExeNode] Aligning vessel...").
    UNTIL VANG(SHIP:FACING:FOREVECTOR, nd:DELTAV) < 1.0 AND nd:ETA <= t_half_dv {
        HUD_print_header("MANEUVER NODE INFO").
        HUD_print_node(initial_dv_mag, nd:DELTAV:MAG, nd:ETA).
        WAIT 0.1.
    }

    debugLog("[ExeNode] Beginning burn...").
    LOCAL tVal IS 0.
    LOCK THROTTLE TO tVal.
    LOCAL initial_dv IS nd:DELTAV.
    LOCAL done IS FALSE.

    UNTIL done {
        HUD_print_header("MANEUVER NODE INFO").
        HUD_print_node(initial_dv_mag, nd:DELTAV:MAG, nd:ETA).

        // Handle staging during burn
        IF SHIP:AVAILABLETHRUST < 0.1 AND tVal > 0 {
            debugLog("[ExeNode] Flameout detected. Staging...").
            WAIT UNTIL STAGE:READY.
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

        // Overshoot protection
        IF VDOT(initial_dv, nd:DELTAV) < 0 {
            debugLog("[ExeNode] Overshoot detected (dot product negative).").
            SET done TO TRUE.
        } ELSE IF rem_dv < 0.1 {
        // Precision RCS finish
            SET done TO TRUE.
        } ELSE {
            IF cur_acc > 0 {
                // throttle down when burn time < 1s
                SET tVal TO MIN(1, rem_dv / cur_acc).
            } ELSE {
                SET tVal TO 1.
            }
        }
        WAIT 0.
    }

    LOCK THROTTLE TO 0.
    UNLOCK THROTTLE.

    // RCS finish for < 0.1 m/s remaining
    LOCAL rem_dv_after IS nd:DELTAV:MAG.
    IF rem_dv_after > 0.01 AND VDOT(initial_dv, nd:DELTAV) > 0 {
        debugLog("[ExeNode] Fine-tuning with RCS...").
        RCS ON.
        LOCAL rcs_done IS FALSE.
        UNTIL rcs_done {
            HUD_print_header("MANEUVER NODE INFO").
            HUD_print_node(initial_dv_mag, nd:DELTAV:MAG, nd:ETA).

            LOCAL current_rem IS nd:DELTAV:MAG.
            IF current_rem < 0.02 OR VDOT(initial_dv, nd:DELTAV) < 0 {
                SET rcs_done TO TRUE.
            } ELSE {
                // apply forward translation
                SET SHIP:CONTROL:FORE TO 1.
            }
            WAIT 0.
        }
        SET SHIP:CONTROL:FORE TO 0.
        RCS OFF.
    }
}



UNLOCK STEERING.
REMOVE nd.
WAIT 0.1.

SET running TO FALSE.
CLEARSCREEN.