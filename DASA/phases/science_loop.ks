@LAZYGLOBAL OFF.

RUNONCEPATH("0:/DASA/utils/cache.ks").

GLOBAL FUNCTION runScienceLoop {
    logMsg("Initializing Science Loop...").

    UNTIL FALSE {
        runAllScience().
        logMsg("Waiting 1 hour until next cycle...").
        
        LOCAL waitEnd IS TIME:SECONDS + 3600.
        UNTIL TIME:SECONDS >= waitEnd {
            WAIT 1.
        }
    }
}

runScienceLoop().

