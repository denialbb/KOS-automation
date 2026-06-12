@LAZYGLOBAL OFF.
CLEARSCREEN.

GLOBAL logFileName IS "0:/logs/panel_debug.txt".
IF EXISTS(logFileName) { DELETEPATH(logFileName). }

GLOBAL FUNCTION logMsg {
    PARAMETER msg.
    PRINT msg.
    LOG msg TO logFileName.
}

logMsg("Scanning vessel for Tianjia Solar Arrays...").

FOR p IN SHIP:parts {
    IF p:TITLE:CONTAINS("Tianjia") OR p:TITLE:CONTAINS("Solar") {
        logMsg("====================================").
        logMsg("Found Part: " + p:TITLE).
        FOR mStr IN p:MODULES {
            LOCAL m IS p:GETMODULE(mStr).
            logMsg("  Module: " + m:NAME).
            logMsg("    Fields:").
            FOR f IN m:ALLFIELDNAMES {
                // safely try to print it
                LOCAL fVal IS "ERROR".
                // use a try-like structure by just getting it directly since ALLFIELDNAMES guarantees it exists
                SET fVal TO m:GETFIELD(f).
                logMsg("      - '" + f + "' = " + fVal).
            }
        }
    }
}

logMsg("====================================").
logMsg("Scan complete. Log saved to " + logFileName).
