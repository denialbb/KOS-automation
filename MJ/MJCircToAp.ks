@LAZYGLOBAL OFF.

RUNONCEPATH("0:/MJ/MJ.ks").

IF NOT mjAvailable() OR NOT ADDONS:MJ:HASSUFFIX("PLANNER") OR NOT ADDONS:MJ:HASSUFFIX("NODE") {
    PRINT "[MJ] MechJeb Planner or Node Executor not supported by this addon version! Falling back to SpaceCore/CircToAp.ks".
    RUNPATH("0:/SpaceCore/CircToAp.ks").
} ELSE {
    LOCAL PLANNER IS ADDONS:MJ:PLANNER.
    LOCAL nodeExecutor IS ADDONS:MJ:NODE.
    LOCAL success IS FALSE.

    mjLog("Planning Circularization at Apoapsis").

    IF PLANNER:HASSUFFIX("CIRCULARIZE") {
        SET success TO PLANNER:CIRCULARIZE("APOAPSIS").
    } ELSE IF PLANNER:HASSUFFIX("CIRCULARIZEAPOAPSIS") {
        PLANNER:CIRCULARIZEAPOAPSIS().
        SET success TO TRUE.
    }

    IF success {
        WAIT UNTIL HASNODE.
        mjLog("Node planned. Executing via MechJeb...").

        mjReleaseControl().
        SET nodeExecutor:ENABLED TO TRUE.
        mjLog("Executing Node - dV: " + ROUND(NEXTNODE:DELTAV:MAG, 2)).

        LOCAL nd IS NEXTNODE.

        UNTIL NOT HASNODE {
            IF NEXTNODE:ETA < 10 {
                LOCAL tLeft IS MAX(0, nd:ETA).
                LOCAL h IS FLOOR(tLeft / 3600).
                LOCAL m IS FLOOR(MOD(tLeft, 3600) / 60).
                LOCAL s IS FLOOR(MOD(tLeft, 60)).
                LOCAL hStr IS "" + h. IF h < 10 { SET hStr TO "0" + h. }
                LOCAL mStr IS "" + m. IF m < 10 { SET mStr TO "0" + m. }
                LOCAL sStr IS "" + s. IF s < 10 { SET sStr TO "0" + s. }
                PRINT "--- Maneuver ----------" AT(0,30).
                PRINT "dV: " + ROUND(NEXTNODE:DELTAV:MAG, 2)) AT (0,31).
                PRINT "twr: " + ROUND(twr, 2) + "        " AT(0,32).
                PRINT "stage fuel: " + ROUND(SHIP:fuel) + "        " AT(0,33).
                PRINT "Time to maneuver: T-" + hStr + ":" + mStr + ":" + sStr + "       " AT (0,34).
            }
            WAIT 0.5.
        }

        SET nodeExecutor:ENABLED TO FALSE.
        mjLog("Circularization complete.").
    } ELSE {
        mjLog("Could not plan circularization via MechJeb! Falling back to SpaceCore/CircToAp.ks").
        RUNPATH("0:/SpaceCore/CircToAp.ks").
    }
}
