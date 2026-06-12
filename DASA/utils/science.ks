@LAZYGLOBAL OFF.

GLOBAL FUNCTION runAllScience {
    logMsg("Triggering all science experiments...").
    LOCAL ranCount IS 0.
    FOR p IN SHIP:parts {
        LOCAL seenModules IS LEXICON().
        FOR mName IN p:modules {
            LOCAL mNameLower IS mName:tolower.
            IF NOT seenModules:HASKEY(mNameLower) {
                IF mNameLower:contains("science") OR mNameLower:contains("experiment") OR mNameLower:contains("sensor") {
                    seenModules:ADD(mNameLower, TRUE).
                    LOCAL pMod IS p:getmodule(mName).
                    logMsg("Found experiment: " + pMod:name + " on " + p:title).
                    IF pMod:hasevent("deploy") {
                        pMod:doevent("deploy").
                    }
                    FOR ev IN pMod:alleventnames {
                        LOCAL evLower IS ev:tolower.
                        IF evLower:contains("start") OR evLower:contains("deploy") OR evLower:contains("run") OR evLower:contains("collect") OR evLower:contains("log") OR evLower:contains("observe") {
                            pMod:doevent(ev).
                            logMsg("Triggered action: " + ev + " on " + p:title).
                            SET ranCount TO ranCount + 1.
                        }
                    }
                }
            }
        }
    }
    logMsg("Science run complete. Triggered " + ranCount + " experiment events.").
}
