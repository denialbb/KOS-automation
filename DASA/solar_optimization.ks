@LAZYGLOBAL OFF.

GLOBAL solarPanelsList IS LIST().
GLOBAL targetRoll IS 0.
LOCAL lastRollOptimization IS 0.

GLOBAL FUNCTION initSolarPanels {
    IF solarPanelsList:LENGTH > 0 { RETURN. }
    FOR p IN SHIP:PARTS {
        LOCAL isPanel IS FALSE.
        LOCAL pName IS p:NAME:TOLOWER.
        IF pName:CONTAINS("solar") OR pName:CONTAINS("panel") {
            SET isPanel TO TRUE.
        }
        IF isPanel {
            FOR m IN p:MODULES {
                LOCAL mName IS m:TOSTRING:TOLOWER.
                IF mName:CONTAINS("deployablesolarpanel") OR mName:CONTAINS("solar") {
                    LOCAL pMod IS p:GETMODULE(m).
                    IF pMod:HASFIELD("energy flow") {
                        solarPanelsList:ADD(pMod).
                    }
                }
            }
        }
    }
}

GLOBAL FUNCTION getTotalEnergyFlow {
    LOCAL totalFlow IS 0.
    FOR pMod IN solarPanelsList {
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
    IF solarPanelsList:LENGTH = 0 { RETURN. }
    
    logMsg("Starting solar panel roll optimization...").
    
    LOCAL currentFlow IS getTotalEnergyFlow().
    LOCAL bestFlow IS currentFlow.
    LOCAL bestRoll IS targetRoll.
    LOCAL stepSize IS 15.
    
    LOCAL testDirs IS LIST(1, -1).
    LOCAL direction IS 0.
    
    // Test positive and negative directions
    FOR dir IN testDirs {
        LOCAL testRoll IS targetRoll + (stepSize * dir).
        LOCK STEERING TO LOOKDIRUP(SUN:POSITION, SUN:NORTH:VECTOR) * R(0, -90, testRoll).
        WAIT 5. // Wait for ship to rotate and flow to update
        LOCAL flow IS getTotalEnergyFlow().
        IF flow > bestFlow {
            SET bestFlow TO flow.
            SET bestRoll TO testRoll.
            SET direction TO dir.
        }
    }
    
    // Hill climb in the best direction
    IF direction <> 0 {
        LOCAL climbing IS TRUE.
        UNTIL NOT climbing {
            LOCAL testRoll IS bestRoll + (stepSize * direction).
            LOCK STEERING TO LOOKDIRUP(SUN:POSITION, SUN:NORTH:VECTOR) * R(0, -90, testRoll).
            WAIT 5.
            LOCAL flow IS getTotalEnergyFlow().
            IF flow > bestFlow {
                SET bestFlow TO flow.
                SET bestRoll TO testRoll.
            } ELSE {
                SET climbing TO FALSE.
            }
        }
    }
    
    SET targetRoll TO bestRoll.
    SET lastRollOptimization TO TIME:SECONDS.
    logMsg("Solar roll optimization complete. Best roll: " + ROUND(targetRoll) + ", Flow: " + ROUND(bestFlow, 2)).
    LOCK STEERING TO LOOKDIRUP(SUN:POSITION, SUN:NORTH:VECTOR) * R(0, -90, targetRoll).
}
