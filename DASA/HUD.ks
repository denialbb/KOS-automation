@LAZYGLOBAL OFF.
GLOBAL loading_tick IS 0.
LOCAL lx IS 48.
LOCAL ly IS 35.
LOCAL padding IS "                      ".

GLOBAL FUNCTION HUD_print_header {
    PARAMETER sec_title.
    PRINT "--- " + sec_title + " ---" AT(0,30).
}

GLOBAL FUNCTION HUD_print_ascent {
    PARAMETER twr, dynPress, vel, cur_alt, apo.

    PRINT "TWR:     " + padding + ROUND(twr, 2) AT(0,31).
    PRINT "Q:       " + padding + ROUND(dynPress, 4) + " kPa" AT(0,32).
    PRINT "Velocity:" + padding + ROUND(vel) + " m/s" AT(0,33).
    PRINT "Altitude:" + padding + ROUND(cur_alt) + " m" AT(0,34).
    PRINT "Apoapsis:" + padding + ROUND(apo) + " m" AT(0,35).
}

GLOBAL FUNCTION HUD_print_node {
    PARAMETER eta_secs.
    PARAMETER initial_dv.
    PARAMETER current_dv.
    PARAMETER vessel_dv.

    LOCAL tLeft IS MAX(0, eta_secs).
    LOCAL h IS FLOOR(tLeft / 3600).
    LOCAL m IS FLOOR(MOD(tLeft, 3600) / 60).
    LOCAL s IS FLOOR(MOD(tLeft, 60)).
    LOCAL hStr IS "" + h. IF h < 10 { SET hStr TO "0" + h. }
    LOCAL mStr IS "" + m. IF m < 10 { SET mStr TO "0" + m. }
    LOCAL sStr IS "" + s. IF s < 10 { SET sStr TO "0" + s. }

    PRINT "Time to Node:     " + padding + "T-" + hStr + ":" + mStr + ":" + sStr AT (0,32).
    PRINT "Maneuver delta-V: " + padding + ROUND(initial_dv, 1) + " m/s" AT (0,31).
    PRINT "Remaining delta-V:" + padding + ROUND(current_dv, 1) + " m/s" AT (0,33).
    PRINT "Vessel delta-V:   " + padding + ROUND(vessel_dv, 1) + " m/s" AT (0,34).
}

GLOBAL last_hud_time IS 0.

GLOBAL FUNCTION HUD_print_solar {
    PARAMETER currP, currY, currR, currFlow.
    PARAMETER bestP, bestY, bestR, bestFlow.
    PARAMETER elapsedSecs.

    // Throttle updates to ~5 FPS to prevent screen jitter
    IF TIME:SECONDS < last_hud_time + 0.2 { RETURN. }
    SET last_hud_time TO TIME:SECONDS.

    // Use fixed-width substring padding to completely overwrite old text and prevent ghosting
    LOCAL cP IS (ROUND(currP) + padding):SUBSTRING(0, 15).
    LOCAL bP IS (ROUND(bestP) + padding):SUBSTRING(0, 15).
    LOCAL cY IS (ROUND(currY) + padding):SUBSTRING(0, 15).
    LOCAL bY IS (ROUND(bestY) + padding):SUBSTRING(0, 15).
    LOCAL cR IS (ROUND(currR) + padding):SUBSTRING(0, 15).
    LOCAL bR IS (ROUND(bestR) + padding):SUBSTRING(0, 15).
    LOCAL cF IS (ROUND(currFlow, 4) + padding):SUBSTRING(0, 15).
    LOCAL bF IS (ROUND(bestFlow, 4) + padding):SUBSTRING(0, 15).

    LOCAL head IS ("Solar Optimization [T+" + ROUND(elapsedSecs, 1) + "s]" + padding):SUBSTRING(0, 40).
    PRINT "--- " + head + " ---" AT(0,30).
    
    PRINT "               CURRENT        BEST           " AT(0, 31).
    PRINT "Pitch:         " + cP + bP AT(0, 32).
    PRINT "Yaw:           " + cY + bY AT(0, 33).
    PRINT "Roll:          " + cR + bR AT(0, 34).
    PRINT "Flow:          " + cF + bF AT(0, 35).
}


GLOBAL FUNCTION HUD_loading {
    IF loading_tick = 0 {
        PRINT "/" AT (lx,ly).
    } ELSE IF loading_tick = 1 {
        PRINT "-" AT (lx,ly).
    } ELSE IF loading_tick = 2 {
        PRINT "\" AT (lx,ly).
    } ELSE IF loading_tick = 3 {
        PRINT "|" AT (lx,ly).
    }

    SET loading_tick TO MOD((loading_tick + 1), 4).
    wait 0.
}

GLOBAL FUNCTION spinload {
    PARAMETER n.
    LOCAL i IS n.
    UNTIL i = 0 {
        HUD_loading().
        wait 0.1.
        SET i TO i-1.
    }
}

GLOBAL FUNCTION spinload_clear {
    PRINT " " AT (lx,ly).
}