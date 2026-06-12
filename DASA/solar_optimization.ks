@LAZYGLOBAL OFF.
RUNONCEPATH("0:/DASA/utils/cache.ks").
RUNONCEPATH("0:/DASA/HUD.ks").

GLOBAL targetPitch IS 0.
GLOBAL targetYaw IS 0.
GLOBAL targetRoll IS 0.
LOCAL lastRollOptimization IS 0.

GLOBAL FUNCTION getTotalEnergyFlow {
    // Rely on kOS built-in sensor for total solar exposure/watts
    RETURN SHIP:SENSORS:LIGHT.
}

LOCAL FUNCTION getSunOrientation {
    PARAMETER pitchAngle, yawAngle, rollAngle.
    RETURN LOOKDIRUP(SUN:POSITION, SUN:NORTH:VECTOR) * R(pitchAngle, yawAngle, rollAngle).
}

LOCAL FUNCTION steerToAndLog {
    PARAMETER pitchAngle, yawAngle, rollAngle.
    PARAMETER bestP, bestY, bestR, bestFlow.
    
    LOCAL targetDir IS getSunOrientation(pitchAngle, yawAngle, rollAngle).
    LOCK STEERING TO targetDir.
    
    LOCAL t0 IS TIME:SECONDS.
    
    UNTIL FALSE {
        LOCAL vFore IS VANG(SHIP:FACING:FOREVECTOR, targetDir:FOREVECTOR).
        LOCAL vTop IS VANG(SHIP:FACING:TOPVECTOR, targetDir:TOPVECTOR).
        
        LOCAL currFlow IS getTotalEnergyFlow().
        HUD_print_solar(pitchAngle, yawAngle, rollAngle, currFlow, bestP, bestY, bestR, bestFlow).
        
        IF (vFore < 10 AND vTop < 20) {
            BREAK.
        }
        
        IF TIME:SECONDS > t0 + 10 {
            BREAK.
        }
        WAIT 0.5.
    }
}

GLOBAL FUNCTION optimizeRoll {
    // Only optimize if at least 10 minutes have passed since last time
    IF TIME:SECONDS < lastRollOptimization + 600 AND lastRollOptimization > 0 {
        RETURN.
    }
    
    SAS OFF.
    
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
    steerToAndLog(targetPitch, targetYaw, targetRoll, targetPitch, targetYaw, targetRoll, 0).
    WAIT 2.
    
    LOCAL bestFlow IS getTotalEnergyFlow().
    LOCAL bestP IS targetPitch.
    LOCAL bestY IS targetYaw.
    LOCAL bestR IS targetRoll.
    
    // 3. Cardinal Sweep if baseline flow is ~0
    IF bestFlow < 0.01 {
        LOCAL cardinalDirs IS LIST(
            LIST(0, 0, 0, "Nose to Sun"),
            LIST(180, 0, 0, "Tail to Sun"),
            LIST(-90, 0, 0, "Top to Sun"),
            LIST(90, 0, 0, "Bottom to Sun"),
            LIST(0, 90, 0, "Right to Sun"),
            LIST(0, -90, 0, "Left to Sun")
        ).
        FOR c IN cardinalDirs {
            steerToAndLog(c[0], c[1], c[2], bestP, bestY, bestR, bestFlow).
            WAIT 2.
            LOCAL flow IS getTotalEnergyFlow().
            IF flow > bestFlow {
                SET bestFlow TO flow.
                SET bestP TO c[0].
                SET bestY TO c[1].
                SET bestR TO c[2].
            }
        }
    }
    
    // 4. Fast 3D Hill Climb
    LOCAL stepSize IS 30.
    LOCAL climbing IS TRUE.
    LOCAL stepCount IS 1.
    
    UNTIL NOT climbing OR stepCount > 3 {
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
            steerToAndLog(t[0], t[1], t[2], bestP, bestY, bestR, bestFlow).
            WAIT 2.
            LOCAL flow IS getTotalEnergyFlow().
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
        } ELSE {
            SET climbing TO FALSE.
        }
    }
    
    SET targetPitch TO bestP.
    SET targetYaw TO bestY.
    SET targetRoll TO bestR.
    SET lastRollOptimization TO TIME:SECONDS.
    
    CLEARSCREEN.
    HUD_print_solar(bestP, bestY, bestR, bestFlow, bestP, bestY, bestR, bestFlow).
    steerToAndLog(targetPitch, targetYaw, targetRoll, bestP, bestY, bestR, bestFlow).
    
    WAIT 3.
    CLEARSCREEN.
}
