@LAZYGLOBAL OFF.
RUNONCEPATH("0:/DASA/utils/cache.ks").

GLOBAL targetPitch IS 0.
GLOBAL targetYaw IS 0.
GLOBAL targetRoll IS 0.
LOCAL lastRollOptimization IS 0.

GLOBAL FUNCTION getTotalEnergyFlow {
    // Rely on kOS built-in sensor for total solar exposure/watts
    RETURN SHIP:SENSORS:LIGHT.
}

LOCAL FUNCTION steerToAndLog {
    PARAMETER targetDir, label.
    logMsg("Steering to " + label + "...").
    LOCK STEERING TO targetDir.
    
    LOCAL t0 IS TIME:SECONDS.
    LOCAL lastLog IS t0.
    
    UNTIL FALSE {
        LOCAL vFore IS VANG(SHIP:FACING:FOREVECTOR, targetDir:FOREVECTOR).
        LOCAL vTop IS VANG(SHIP:FACING:TOPVECTOR, targetDir:TOPVECTOR).
        
        IF TIME:SECONDS > lastLog + 5 {
            logMsg(" - Steering Error -> Fore: " + ROUND(vFore, 1) + " deg | Top: " + ROUND(vTop, 1) + " deg").
            SET lastLog TO TIME:SECONDS.
        }
        
        IF (vFore < 2 AND vTop < 2) {
            logMsg(" - Alignment reached.").
            BREAK.
        }
        
        IF TIME:SECONDS > t0 + 60 {
            logMsg(" - Alignment timeout after 60s.").
            BREAK.
        }
        WAIT 0.5.
    }
}

LOCAL FUNCTION getSunOrientation {
    PARAMETER pitchAngle, yawAngle, rollAngle.
    RETURN LOOKDIRUP(SUN:POSITION, SUN:NORTH:VECTOR) * R(pitchAngle, yawAngle, rollAngle).
}

GLOBAL FUNCTION optimizeRoll {
    // Only optimize if at least 10 minutes have passed since last time
    IF TIME:SECONDS < lastRollOptimization + 600 AND lastRollOptimization > 0 {
        RETURN.
    }
    
    // 1. Check for Planetary Shadow
    LOCAL angToBody IS VANG(SUN:POSITION, BODY:POSITION).
    LOCAL bodyAngularRadius IS ARCSIN(BODY:RADIUS / BODY:DISTANCE).
    IF angToBody < bodyAngularRadius {
        logMsg("Vessel is in planetary shadow! Aborting solar optimization.").
        RETURN.
    }
    
    // 2. Check for EC Failure
    LOCAL ec IS 0.
    LOCAL ecCapacity IS 0.
    FOR res IN SHIP:RESOURCES {
        IF res:NAME = "ELECTRICCHARGE" {
            SET ec TO res:AMOUNT.
            SET ecCapacity TO res:CAPACITY.
        }
    }
    IF ecCapacity > 0 AND (ec / ecCapacity) < 0.02 {
        logMsg("CRITICAL: ElectricCharge is below 2%. Optimization sweep may drain remaining power. Aborting.").
        RETURN.
    }
    
    logMsg("Starting 3D solar optimization...").
    
    // Ensure we are initially aligned to the target orientation before recording the baseline flow
    steerToAndLog(getSunOrientation(targetPitch, targetYaw, targetRoll), "initial baseline orientation").
    WAIT 2.
    
    LOCAL bestFlow IS getTotalEnergyFlow().
    LOCAL bestP IS targetPitch.
    LOCAL bestY IS targetYaw.
    LOCAL bestR IS targetRoll.
    logMsg("Initial baseline energy flow: " + ROUND(bestFlow, 4)).
    
    // 3. Cardinal Sweep if baseline flow is ~0
    IF bestFlow < 0.01 {
        logMsg("Baseline flow is negligible. Performing Cardinal Sweep to find the sun...").
        LOCAL cardinalDirs IS LIST(
            LIST(0, 0, 0, "Nose to Sun"),
            LIST(180, 0, 0, "Tail to Sun"),
            LIST(-90, 0, 0, "Top to Sun"),
            LIST(90, 0, 0, "Bottom to Sun"),
            LIST(0, 90, 0, "Right to Sun"),
            LIST(0, -90, 0, "Left to Sun")
        ).
        FOR c IN cardinalDirs {
            steerToAndLog(getSunOrientation(c[0], c[1], c[2]), c[3]).
            WAIT 2.
            LOCAL flow IS getTotalEnergyFlow().
            logMsg("Flow at " + c[3] + ": " + ROUND(flow, 4)).
            IF flow > bestFlow {
                SET bestFlow TO flow.
                SET bestP TO c[0].
                SET bestY TO c[1].
                SET bestR TO c[2].
            }
        }
    }
    
    // 4. 3D Hill Climb
    LOCAL stepSize IS 15.
    LOCAL climbing IS TRUE.
    LOCAL stepCount IS 1.
    
    UNTIL NOT climbing {
        logMsg("--- Hill Climb Iteration " + stepCount + " ---").
        LOCAL improved IS FALSE.
        
        // Test all 6 orthogonal directions locally
        LOCAL testDirs IS LIST(
            LIST(bestP + stepSize, bestY, bestR, "Pitch +"),
            LIST(bestP - stepSize, bestY, bestR, "Pitch -"),
            LIST(bestP, bestY + stepSize, bestR, "Yaw +"),
            LIST(bestP, bestY - stepSize, bestR, "Yaw -"),
            LIST(bestP, bestY, bestR + stepSize, "Roll +"),
            LIST(bestP, bestY, bestR - stepSize, "Roll -")
        ).
        
        LOCAL localBestFlow IS bestFlow.
        LOCAL localBestP IS bestP.
        LOCAL localBestY IS bestY.
        LOCAL localBestR IS bestR.
        
        FOR t IN testDirs {
            steerToAndLog(getSunOrientation(t[0], t[1], t[2]), t[3]).
            WAIT 2.
            LOCAL flow IS getTotalEnergyFlow().
            logMsg("Flow at " + t[3] + ": " + ROUND(flow, 4)).
            IF flow > localBestFlow {
                SET localBestFlow TO flow.
                SET localBestP TO t[0].
                SET localBestY TO t[1].
                SET localBestR TO t[2].
                SET improved TO TRUE.
            }
        }
        
        IF improved {
            SET bestFlow TO localBestFlow.
            SET bestP TO localBestP.
            SET bestY TO localBestY.
            SET bestR TO localBestR.
            SET stepCount TO stepCount + 1.
            logMsg("Climbed to new best flow: " + ROUND(bestFlow, 4)).
        } ELSE {
            logMsg("No further flow improvement found in local neighborhood. Stopping climb.").
            SET climbing TO FALSE.
        }
    }
    
    SET targetPitch TO bestP.
    SET targetYaw TO bestY.
    SET targetRoll TO bestR.
    SET lastRollOptimization TO TIME:SECONDS.
    logMsg("Solar optimization complete. Best orientation -> P: " + ROUND(targetPitch) + " Y: " + ROUND(targetYaw) + " R: " + ROUND(targetRoll) + ", Flow: " + ROUND(bestFlow, 4)).
    
    steerToAndLog(getSunOrientation(targetPitch, targetYaw, targetRoll), "final optimal orientation").
}
