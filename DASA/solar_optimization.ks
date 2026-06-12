@LAZYGLOBAL OFF.
RUNONCEPATH("0:/DASA/utils/cache.ks").
RUNONCEPATH("0:/DASA/HUD.ks").

GLOBAL targetPitch IS 0.
GLOBAL targetYaw IS 0.
GLOBAL targetRoll IS 0.
LOCAL lastRollOptimization IS 0.
GLOBAL userAbort IS FALSE.

LOCAL debugLogFile IS "0:/logs/solar_radar_debug.txt".

LOCAL FUNCTION debugLog {
    PARAMETER msg.
    LOCAL fullMsg IS "[" + TIME:CLOCK + "] " + msg.
    LOG fullMsg TO debugLogFile.
}

GLOBAL FUNCTION getTotalEnergyFlow {
    // Rely on kOS built-in sensor for total solar exposure/watts
    RETURN SHIP:SENSORS:LIGHT.
}

LOCAL FUNCTION getSunOrientation {
    PARAMETER pitchAngle, yawAngle, rollAngle.
    RETURN LOOKDIRUP(SUN:POSITION, SUN:NORTH:VECTOR) * R(pitchAngle, yawAngle, rollAngle).
}

LOCAL FUNCTION steerAndSweep {
    PARAMETER pitchAngle, yawAngle, rollAngle.
    PARAMETER globalBestP, globalBestY, globalBestR, globalBestFlow.
    PARAMETER startTime.
    
    LOCAL targetDir IS getSunOrientation(pitchAngle, yawAngle, rollAngle).
    LOCK STEERING TO targetDir.
    
    LOCAL t0 IS TIME:SECONDS.
    
    LOCAL peakFlow IS globalBestFlow.
    LOCAL peakP IS globalBestP.
    LOCAL peakY IS globalBestY.
    LOCAL peakR IS globalBestR.
    
    LOCAL sunBasis IS LOOKDIRUP(SUN:POSITION, SUN:NORTH:VECTOR).
    
    UNTIL FALSE {
        LOCAL vFore IS VANG(SHIP:FACING:FOREVECTOR, targetDir:FOREVECTOR).
        LOCAL vTop IS VANG(SHIP:FACING:TOPVECTOR, targetDir:TOPVECTOR).
        
        LOCAL currFlow IS getTotalEnergyFlow().
        
        IF currFlow > peakFlow {
            SET peakFlow TO currFlow.
            // Extract the exact relative pitch/yaw/roll at this millisecond
            LOCAL relRot IS sunBasis:INVERSE * SHIP:FACING.
            SET peakP TO relRot:PITCH.
            SET peakY TO relRot:YAW.
            SET peakR TO relRot:ROLL.
            
            // Fix kOS Euler representation bounds if they flip
            IF peakP > 180 { SET peakP TO peakP - 360. }
            IF peakY > 180 { SET peakY TO peakY - 360. }
            IF peakR > 180 { SET peakR TO peakR - 360. }
            
            debugLog("-> Radar Peak: " + ROUND(peakFlow, 4) + " @ P:" + ROUND(peakP) + " Y:" + ROUND(peakY) + " R:" + ROUND(peakR)).
        }
        
        IF MOD(TIME:SECONDS * 10, 5) < 0.5 { // Log every ~0.5s without filling up too fast
            debugLog("Steering error - Fore: " + ROUND(vFore, 2) + ", Top: " + ROUND(vTop, 2)).
        }
        
        IF TERMINAL:INPUT:HASCHAR {
            LOCAL ch IS TERMINAL:INPUT:GETCHAR().
            IF ch = "q" OR ch = "Q" {
                debugLog("User pressed 'q', aborting radar sweep...").
                SET userAbort TO TRUE.
                BREAK.
            }
        }
        
        HUD_print_solar(pitchAngle, yawAngle, rollAngle, currFlow, peakP, peakY, peakR, peakFlow, TIME:SECONDS - startTime).
        
        IF (vFore < 5 AND vTop < 10) {
            debugLog("Sweep target reached within tolerance.").
            BREAK.
        }
        
        IF TIME:SECONDS > t0 + 15 {
            debugLog("Sweep timeout. Moving on.").
            BREAK.
        }
        WAIT 0.1. // Poll extremely fast to catch the peak!
    }
    
    RETURN LIST(peakP, peakY, peakR, peakFlow).
}

GLOBAL FUNCTION optimizeSunExposure {
    IF TIME:SECONDS < lastRollOptimization + 600 AND lastRollOptimization > 0 {
        RETURN.
    }
    
    SAS OFF.
    SET userAbort TO FALSE.
    
    IF EXISTS(debugLogFile) {
        DELETEPATH(debugLogFile).
    }
    
    debugLog("=========================================").
    debugLog("   RADAR SOLAR OPTIMIZATION INITIATED    ").
    debugLog("=========================================").
    
    LOCAL angToBody IS VANG(SUN:POSITION, BODY:POSITION).
    LOCAL bodyAngularRadius IS ARCSIN(BODY:RADIUS / BODY:DISTANCE).
    IF angToBody < bodyAngularRadius {
        debugLog("Vessel is in planetary shadow! Aborting solar optimization.").
        RETURN.
    }
    
    LOCAL ec IS 0.
    LOCAL ecCapacity IS 0.
    FOR res IN SHIP:RESOURCES {
        IF res:NAME = "ELECTRICCHARGE" {
            SET ec TO res:AMOUNT.
            SET ecCapacity TO res:CAPACITY.
        }
    }
    IF ecCapacity > 0 AND (ec / ecCapacity) < 0.02 {
        debugLog("CRITICAL: ElectricCharge is below 2%. Aborting.").
        RETURN.
    }
    
    LOCAL startTime IS TIME:SECONDS.
    debugLog("Aligning to initial baseline orientation...").
    
    LOCAL bestP IS targetPitch.
    LOCAL bestY IS targetYaw.
    LOCAL bestR IS targetRoll.
    LOCAL bestFlow IS 0.
    
    LOCAL initRes IS steerAndSweep(bestP, bestY, bestR, bestP, bestY, bestR, 0, startTime).
    WAIT 2.
    IF userAbort { RETURN. }
    SET bestP TO initRes[0]. SET bestY TO initRes[1]. SET bestR TO initRes[2]. SET bestFlow TO initRes[3].
    
    debugLog("Initial baseline radar flow: " + bestFlow).
    
    // 3. Cardinal Sweep if baseline flow is ~0
    IF bestFlow < 0.01 {
        debugLog("Baseline flow negligible. Performing Radar Cardinal Sweep.").
        LOCAL cardinalDirs IS LIST(
            LIST(0, 0, 0, "Nose to Sun"),
            LIST(180, 0, 0, "Tail to Sun"),
            LIST(-90, 0, 0, "Top to Sun"),
            LIST(90, 0, 0, "Bottom to Sun"),
            LIST(0, 90, 0, "Right to Sun"),
            LIST(0, -90, 0, "Left to Sun")
        ).
        FOR c IN cardinalDirs {
            debugLog("Sweeping Cardinal: " + c[3] + " (P:" + c[0] + " Y:" + c[1] + " R:" + c[2] + ")").
            LOCAL res IS steerAndSweep(c[0], c[1], c[2], bestP, bestY, bestR, bestFlow, startTime).
            IF userAbort { BREAK. }
            WAIT 1.
            IF res[3] > bestFlow {
                debugLog("-> New Cardinal Radar Best: " + res[3]).
                SET bestP TO res[0].
                SET bestY TO res[1].
                SET bestR TO res[2].
                SET bestFlow TO res[3].
                BREAK. // Greedy short-circuit
            }
        }
        
        IF userAbort { RETURN. }
        
        // Snap back to best cardinal peak
        steerAndSweep(bestP, bestY, bestR, bestP, bestY, bestR, bestFlow, startTime).
    }
    
    // 4. Radar-Assisted Hill Climb
    LOCAL stepSize IS 45. // Massive step size for radar sweeping
    LOCAL climbing IS TRUE.
    
    UNTIL NOT climbing OR stepSize <= 2 OR bestFlow >= 2.22 {
        LOCAL improved IS FALSE.
        debugLog("--- Radar Sweep Step ---").
        debugLog("Current Best: Flow=" + bestFlow + " (P:" + ROUND(bestP) + " Y:" + ROUND(bestY) + " R:" + ROUND(bestR) + ")").
        debugLog("Sweep Radius: " + stepSize).
        
        // Test massive arcs across all 6 directions
        LOCAL testDirs IS LIST(
            LIST(bestP + stepSize, bestY, bestR, "Pitch +"),
            LIST(bestP - stepSize, bestY, bestR, "Pitch -"),
            LIST(bestP, bestY + stepSize, bestR, "Yaw +"),
            LIST(bestP, bestY - stepSize, bestR, "Yaw -"),
            LIST(bestP, bestY, bestR + stepSize, "Roll +"),
            LIST(bestP, bestY, bestR - stepSize, "Roll -")
        ).
        
        FOR t IN testDirs {
            debugLog("Radar Sweeping " + t[3] + " (P:" + ROUND(t[0]) + " Y:" + ROUND(t[1]) + " R:" + ROUND(t[2]) + ")").
            LOCAL res IS steerAndSweep(t[0], t[1], t[2], bestP, bestY, bestR, bestFlow, startTime).
            IF userAbort { BREAK. }
            
            IF res[3] > bestFlow {
                debugLog("-> Radar Peak locked: " + res[3] + " ! Short circuiting local sweep.").
                SET bestP TO res[0].
                SET bestY TO res[1].
                SET bestR TO res[2].
                SET bestFlow TO res[3].
                SET improved TO TRUE.
                BREAK. // Greedy short-circuit
            }
        }
        
        IF userAbort { BREAK. }
        
        IF NOT improved {
            debugLog("No peak found in radar sweeps.").
            IF bestFlow > 2.1 AND stepSize <= 15 {
                debugLog("Flow is excellent (> 2.1) and sweep arc is small. Stopping early to save time.").
                BREAK.
            }
            SET stepSize TO stepSize * 0.5. // Shrink radar arc and try again
            debugLog("Shrinking radar arc to " + stepSize).
            
            // Return to center before starting smaller sweeps
            steerAndSweep(bestP, bestY, bestR, bestP, bestY, bestR, bestFlow, startTime).
        } ELSE {
            // We found a peak mid-sweep. We must steer BACK to it before starting the next iteration!
            debugLog("Returning ship to exactly align with detected peak...").
            steerAndSweep(bestP, bestY, bestR, bestP, bestY, bestR, bestFlow, startTime).
        }
    }
    
    debugLog("--- OPTIMIZATION COMPLETE ---").
    debugLog("Final Best: Flow=" + bestFlow + " (P:" + ROUND(bestP) + " Y:" + ROUND(bestY) + " R:" + ROUND(bestR) + ")").
    
    SET targetPitch TO bestP.
    SET targetYaw TO bestY.
    SET targetRoll TO bestR.
    SET lastRollOptimization TO TIME:SECONDS.
    
    CLEARSCREEN.
    HUD_print_solar(bestP, bestY, bestR, bestFlow, bestP, bestY, bestR, bestFlow, TIME:SECONDS - startTime).
    
    // Final lock
    LOCAL finalDir IS getSunOrientation(bestP, bestY, bestR).
    LOCK STEERING TO finalDir.
    WAIT 3.
    CLEARSCREEN.
    
    LOCAL totalSecs IS ROUND(TIME:SECONDS - startTime).
    PRINT "--- RADAR OPTIMIZATION COMPLETE ---".
    PRINT "Final Flow: " + ROUND(bestFlow, 4).
    PRINT "Best Angle: P:" + ROUND(bestP) + " Y:" + ROUND(bestY) + " R:" + ROUND(bestR).
    PRINT "Time Taken: " + totalSecs + " seconds.".
}
