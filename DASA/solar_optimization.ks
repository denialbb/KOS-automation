@LAZYGLOBAL OFF.
RUNONCEPATH("0:/DASA/utils/cache.ks").

GLOBAL targetRoll IS 0.
LOCAL lastRollOptimization IS 0.

GLOBAL FUNCTION initSolarPanels {
    initDeployablesCache().
}

GLOBAL FUNCTION getTotalEnergyFlow {
    LOCAL totalFlow IS 0.
    FOR pMod IN cachedSolarPanels {
        IF pMod:HASFIELD("energy flow") {
            SET totalFlow TO totalFlow + pMod:GETFIELD("energy flow").
        }
    }
    RETURN totalFlow.
}

GLOBAL FUNCTION optimizeRoll {
    // Only optimize if at least 10 minutes have passed since last time
    IF TIME:SECONDS < lastRollOptimization + 600 AND lastRollOptimization > 0 {
        RETURN.
    }
    
    initSolarPanels().
    IF cachedSolarPanels:LENGTH = 0 { RETURN. }
    
    logMsg("Starting solar panel roll optimization...").
    
    LOCAL currentFlow IS getTotalEnergyFlow().
    logMsg("Initial energy flow: " + ROUND(currentFlow, 2) + " kW.").
    LOCAL bestFlow IS currentFlow.
    LOCAL bestRoll IS targetRoll.
    LOCAL stepSize IS 15.
    
    LOCAL testDirs IS LIST(1, -1).
    LOCAL direction IS 0.
    
    // Test positive and negative directions
    FOR dir IN testDirs {
        LOCAL testRoll IS targetRoll + (stepSize * dir).
        logMsg("Testing roll angle: " + ROUND(testRoll) + " degrees...").
        LOCK STEERING TO LOOKDIRUP(SUN:POSITION, SUN:NORTH:VECTOR) * R(0, -90, testRoll).
        WAIT 5. // Wait for ship to rotate and flow to update
        LOCAL flow IS getTotalEnergyFlow().
        logMsg("Energy flow at " + ROUND(testRoll) + " deg: " + ROUND(flow, 2) + " kW.").
        IF flow > bestFlow {
            SET bestFlow TO flow.
            SET bestRoll TO testRoll.
            SET direction TO dir.
        }
    }
    
    // Hill climb in the best direction
    IF direction <> 0 {
        logMsg("Climbing in direction: " + direction + " (best roll so far: " + ROUND(bestRoll) + " deg)").
        LOCAL climbing IS TRUE.
        LOCAL stepCount IS 1.
        UNTIL NOT climbing {
            LOCAL testRoll IS bestRoll + (stepSize * direction).
            logMsg("Hill climb step " + stepCount + ": testing roll " + ROUND(testRoll) + " degrees...").
            LOCK STEERING TO LOOKDIRUP(SUN:POSITION, SUN:NORTH:VECTOR) * R(0, -90, testRoll).
            WAIT 5.
            LOCAL flow IS getTotalEnergyFlow().
            logMsg("Flow at " + ROUND(testRoll) + " deg: " + ROUND(flow, 2) + " kW.").
            IF flow > bestFlow {
                SET bestFlow TO flow.
                SET bestRoll TO testRoll.
                SET stepCount TO stepCount + 1.
            } ELSE {
                logMsg("No flow improvement. Stopping climb.").
                SET climbing TO FALSE.
            }
        }
    } ELSE {
        logMsg("No improvement found in test directions. Maintaining current roll.").
    }
    
    SET targetRoll TO bestRoll.
    SET lastRollOptimization TO TIME:SECONDS.
    logMsg("Solar roll optimization complete. Best roll: " + ROUND(targetRoll) + " deg, Flow: " + ROUND(bestFlow, 2) + " kW.").
    LOCK STEERING TO LOOKDIRUP(SUN:POSITION, SUN:NORTH:VECTOR) * R(0, -90, targetRoll).
}
