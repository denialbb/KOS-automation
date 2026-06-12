@LAZYGLOBAL OFF.

GLOBAL missionLogPath IS "0:/logs/log.txt".
GLOBAL localLogPath IS "1:/local_log.txt".
GLOBAL missionMilestones IS LIST().

GLOBAL FUNCTION formatTime {
    PARAMETER t.
    LOCAL h IS FLOOR(t / 3600).
    LOCAL m IS FLOOR(MOD(t, 3600) / 60).
    LOCAL s IS FLOOR(MOD(t, 60)).

    LOCAL hStr IS h:TOSTRING.
    IF h < 10 { SET hStr TO "0" + hStr. }

    LOCAL mStr IS m:TOSTRING.
    IF m < 10 { SET mStr TO "0" + mStr. }

    LOCAL sStr IS s:TOSTRING.
    IF s < 10 { SET sStr TO "0" + sStr. }

    RETURN hStr + ":" + mStr + ":" + sStr.
}

GLOBAL FUNCTION logMsg {
    PARAMETER msg.
    LOCAL tStr IS "T+".
    LOCAL tVal IS MISSIONTIME.
    IF HASNODE {
        SET tVal TO NEXTNODE:ETA.
        SET tStr TO "T-".
    }
    LOCAL line IS "[" + tStr + formatTime(tVal) + "] " + msg.
    PRINT line.
    missionMilestones:ADD(line).

    IF homeconnection:isconnected {
        // If we have local logs cached from blackout, flush them to archive
        IF EXISTS(localLogPath) {
            LOCAL f IS OPEN(localLogPath).
            FOR l IN f:READALL {
                LOG l TO missionLogPath.
            }
            DELETEPATH(localLogPath).
        }
        LOG line TO missionLogPath.
    } ELSE {
        LOG line TO localLogPath.
    }
}

GLOBAL FUNCTION logDebug {
    PARAMETER msg.
    LOCAL tStr IS "T+".
    LOCAL tVal IS MISSIONTIME.
    IF HASNODE {
        SET tVal TO NEXTNODE:ETA.
        SET tStr TO "T-".
    }
    LOCAL line IS "[" + tStr + formatTime(tVal) + "] DEBUG: " + msg.

    IF homeconnection:isconnected {
        IF EXISTS(localLogPath) {
            LOCAL f IS OPEN(localLogPath).
            FOR l IN f:READALL {
                LOG l TO missionLogPath.
            }
            DELETEPATH(localLogPath).
        }
        LOG line TO missionLogPath.
    } ELSE {
        LOG line TO localLogPath.
    }
}
