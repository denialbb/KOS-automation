@LAZYGLOBAL OFF.

GLOBAL FUNCTION runAllScience {
    logMsg("Triggering all science experiments...").
    FOR p IN SHIP:parts {
        FOR mName IN p:modules {
            LOCAL mNameLower IS mName:tolower.
            IF mNameLower:contains("science") OR mNameLower:contains("experiment") OR mNameLower:contains("sensor") {
                LOCAL pMod IS p:getmodule(mName).
                IF pMod:hasfield("deploy") OR pMod:hasevent("deploy") {
                    pMod:doevent("deploy").
                }
                FOR ev IN pMod:allevents {
                    LOCAL evLower IS ev:tolower.
                    IF evLower:contains("start") OR evLower:contains("deploy") OR evLower:contains("run") OR evLower:contains("collect") {
                        pMod:doevent(ev).
                    }
                }
            }
        }
    }
}
