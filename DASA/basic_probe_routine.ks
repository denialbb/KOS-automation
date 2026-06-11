@LAZYGLOBAL OFF.

// ------------------------------------------------------------------------
// Basic Probe Survival Routine
// Fallback logic for when primary missions fail or nodes cannot be calculated.
// Monitors power, warns on low charge, tracks the sun, and continuously
// runs and transmits science experiments.
// ------------------------------------------------------------------------

PRINT "--- BASIC PROBE SURVIVAL ROUTINE INITIATED ---".

LOCAL warningPlayed IS FALSE.
LOCAL lastScienceTime IS 0.
LOCAL SCIENCE_POLL_INTERVAL IS 60.

SAS OFF.
RCS OFF.
LOCK STEERING TO sun:position.

UNTIL FALSE {
    // 1. Resource Monitoring
    LOCAL ec IS SHIP:ELECTRICCHARGE.
    LOCAL ecMax IS 1.
    FOR r IN SHIP:RESOURCES {
        IF r:NAME = "ElectricCharge" {
            SET ecMax TO MAX(0.1, r:CAPACITY).
        }
    }
    
    LOCAL ecPct IS ec / ecMax.
    
    IF ecPct < 0.2 {
        IF NOT warningPlayed {
            PRINT "WARNING: Low ElectricCharge (" + ROUND(ecPct*100) + "%). Sounding alarm!".
            // Play a 3-beep warning tone
            LOCAL v IS getvoice(0).
            v:play(note("A4", 0.2, 0.3)).
            WAIT 0.3.
            v:play(note("A4", 0.2, 0.3)).
            WAIT 0.3.
            v:play(note("A4", 0.2, 0.3)).
            SET warningPlayed TO TRUE.
        }
    } ELSE IF ecPct > 0.5 {
        SET warningPlayed TO FALSE.
    }
    
    // 2. Science Experiments & Transmission
    IF TIME:SECONDS > lastScienceTime + SCIENCE_POLL_INTERVAL {
        SET lastScienceTime TO TIME:SECONDS.
        
        FOR p IN SHIP:parts {
            FOR mName IN p:modules {
                LOCAL mNameLower IS mName:tolower.
                IF mNameLower:contains("science") OR mNameLower:contains("experiment") OR mNameLower:contains("sensor") {
                    LOCAL pMod IS p:getmodule(mName).
                    
                    // Deploy if possible
                    IF pMod:hasfield("deploy") OR pMod:hasevent("deploy") {
                        pMod:doevent("deploy").
                    }
                    
                    // Run experiments and transmit
                    FOR ev IN pMod:allevents {
                        LOCAL evLower IS ev:tolower.
                        IF evLower:contains("start") OR evLower:contains("run") OR evLower:contains("log") OR evLower:contains("observe") {
                            pMod:doevent(ev).
                        }
                    }
                    
                    // Trigger transmission if antenna is available and science is present
                    FOR ev IN pMod:allevents {
                        IF ev:tolower:contains("transmit") {
                            // Only transmit if power is safe (>30%)
                            IF ecPct > 0.3 {
                                pMod:doevent(ev).
                            }
                        }
                    }
                }
            }
        }
    }
    
    WAIT 1.
}
