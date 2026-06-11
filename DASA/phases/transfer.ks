@LAZYGLOBAL OFF.

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
