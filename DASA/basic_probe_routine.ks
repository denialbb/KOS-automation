@lazyGlobal off.

// ------------------------------------------------------------------------
// Basic Probe Survival Routine
// Fallback logic for when primary missions fail or nodes cannot be calculated.
// Monitors power, warns on low charge, tracks the sun, and continuously
// runs and transmits science experiments.
// ------------------------------------------------------------------------

print "--- BASIC PROBE SURVIVAL ROUTINE INITIATED ---".

local warningPlayed is false.
local lastScienceTime is 0.
local SCIENCE_POLL_INTERVAL is 60.

sas off.
rcs off.
lock steering to sun:position.

until false {
    // 1. Resource Monitoring
    local ec is ship:electriccharge.
    local ecMax is 1.
    for r in ship:resources {
        if r:name = "ElectricCharge" {
            set ecMax to max(0.1, r:capacity).
        }
    }
    
    local ecPct is ec / ecMax.
    
    if ecPct < 0.2 {
        if not warningPlayed {
            print "WARNING: Low ElectricCharge (" + round(ecPct*100) + "%). Sounding alarm!".
            // Play a 3-beep warning tone
            local v is getvoice(0).
            v:play(note("A4", 0.2, 0.3)).
            wait 0.3.
            v:play(note("A4", 0.2, 0.3)).
            wait 0.3.
            v:play(note("A4", 0.2, 0.3)).
            set warningPlayed to true.
        }
    } else if ecPct > 0.5 {
        set warningPlayed to false.
    }
    
    // 2. Science Experiments & Transmission
    if time:seconds > lastScienceTime + SCIENCE_POLL_INTERVAL {
        set lastScienceTime to time:seconds.
        
        for p in ship:parts {
            for mName in p:modules {
                local mNameLower is mName:tolower.
                if mNameLower:contains("science") or mNameLower:contains("experiment") or mNameLower:contains("sensor") {
                    local pMod is p:getmodule(mName).
                    
                    // Deploy if possible
                    if pMod:hasfield("deploy") or pMod:hasevent("deploy") {
                        pMod:doevent("deploy").
                    }
                    
                    // Run experiments and transmit
                    for ev in pMod:allevents {
                        local evLower is ev:tolower.
                        if evLower:contains("start") or evLower:contains("run") or evLower:contains("log") or evLower:contains("observe") {
                            pMod:doevent(ev).
                        }
                    }
                    
                    // Trigger transmission if antenna is available and science is present
                    for ev in pMod:allevents {
                        if ev:tolower:contains("transmit") {
                            // Only transmit if power is safe (>30%)
                            if ecPct > 0.3 {
                                pMod:doevent(ev).
                            }
                        }
                    }
                }
            }
        }
    }
    
    wait 1.
}
