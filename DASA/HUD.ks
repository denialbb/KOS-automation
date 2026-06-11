@LAZYGLOBAL OFF.

GLOBAL FUNCTION HUD_print_header {
    PARAMETER title.
    PRINT "--- " + title + " ---                             " AT(0,30).
}

GLOBAL FUNCTION HUD_print_ascent {
    PARAMETER twr, q, v, alt, apo.
    
    PRINT "TWR: " + ROUND(twr, 2) + "        " AT(0,31).
    PRINT "Q:   " + ROUND(q, 4) + " kPa   " AT(0,32).
    PRINT "Velocity: " + ROUND(v) + " m/s       " AT(0,33).
    PRINT "Altitude: " + ROUND(alt) + " m       " AT(0,34).
    PRINT "Apoapsis: " + ROUND(apo) + " m       " AT(0,35).
}

GLOBAL FUNCTION HUD_print_node {
    PARAMETER initial_dv.
    PARAMETER current_dv.
    PARAMETER eta_secs.
    
    LOCAL tLeft IS MAX(0, eta_secs).
    LOCAL h IS FLOOR(tLeft / 3600).
    LOCAL m IS FLOOR(MOD(tLeft, 3600) / 60).
    LOCAL s IS FLOOR(MOD(tLeft, 60)).
    LOCAL hStr IS "" + h. IF h < 10 { SET hStr TO "0" + h. }
    LOCAL mStr IS "" + m. IF m < 10 { SET mStr TO "0" + m. }
    LOCAL sStr IS "" + s. IF s < 10 { SET sStr TO "0" + s. }
    
    PRINT "Total maneuver delta-V: " + ROUND(initial_dv, 1) + " m/s       " AT (0,31).
    PRINT "Time to maneuver: T-" + hStr + ":" + mStr + ":" + sStr + "       " AT (0,32).
    PRINT "Remaining delta-V: " + ROUND(current_dv, 1) + " m/s       " AT (0,33).
}
