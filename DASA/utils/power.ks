@LAZYGLOBAL OFF.

GLOBAL apuState IS FALSE.

GLOBAL FUNCTION setAPUState {
    PARAMETER state.
    LOCAL stateStr IS "OFF".
    IF state { SET stateStr TO "ON". }
    logMsg("Setting Fuel Cells/APUs to " + stateStr).

    FOR p IN SHIP:parts {
        FOR mName IN p:modules {
            LOCAL pMod IS p:getmodule(mName).
            FOR ev IN pMod:allevents {
                LOCAL evLower IS ev:tolower.
                IF state {
                    IF (evLower:contains("start") OR evLower:contains("activate") OR evLower:contains("enable")) AND (evLower:contains("cell") OR evLower:contains("gen") OR evLower:contains("apu") OR evLower:contains("power")) {
                        pMod:doevent(ev).
                        logMsg("APU ON: " + ev + " on " + p:title).
                    }
                } ELSE {
                    IF (evLower:contains("stop") OR evLower:contains("deactivate") OR evLower:contains("disable")) AND (evLower:contains("cell") OR evLower:contains("gen") OR evLower:contains("apu") OR evLower:contains("power")) {
                        pMod:doevent(ev).
                        logMsg("APU OFF: " + ev + " on " + p:title).
                    }
                }
            }
        }
    }
}

GLOBAL FUNCTION checkPower {
    LOCAL ec IS SHIP:ELECTRICCHARGE.
    LOCAL ecMax IS 0.
    FOR r IN SHIP:RESOURCES {
        IF r:NAME = "ElectricCharge" { SET ecMax TO r:CAPACITY. }
    }
    IF ecMax > 0 {
        LOCAL pct IS ec / ecMax.
        IF pct < 0.20 {
            logMsg("LOW POWER.").
            IF NOT apuState {
                logMsg("CRITICAL POWER: Starting APUs.").
                setAPUState(TRUE).
                SET apuState TO TRUE.
            }
            IF LIGHTS {
                LIGHTS OFF.
                logMsg("CRITICAL POWER: Turning off lights to conserve energy.").
            }
        } ELSE IF pct > 0.95 {
            IF apuState {
                logMsg("Power restored. Stopping APUs.").
                setAPUState(FALSE).
                SET apuState TO FALSE.
            }
        }

        // Turn lights on if in orbit and power is stable (>20%)
        IF pct >= 0.20 AND (SHIP:STATUS = "ORBITING" OR SHIP:STATUS = "ESCAPING") {
            spinload(10).
            spinload_clear().
            IF NOT LIGHTS {
                LIGHTS ON.
                logMsg("Vessel in orbit with stable power. Turning lights on.").
            }
        }
    }
}
