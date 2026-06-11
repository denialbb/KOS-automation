@LAZYGLOBAL ON.

PRINT "Scanning Vessel Structure...".

LOCAL structFile IS "0:/telemetry/vessel_structure.json".
IF exists(structFile) {
    deletepath(structFile).
}

LOCAL jsonOut IS "{ ""parts"": [".
LOCAL first IS TRUE.

FOR p IN SHIP:parts {
    LOCAL vRel IS p:position - SHIP:position.
    LOCAL posX IS VDOT(SHIP:FACING:starvector, vRel).
    LOCAL posY IS VDOT(SHIP:FACING:topvector, vRel).
    LOCAL posZ IS VDOT(SHIP:FACING:FOREVECTOR, vRel).
    
    LOCAL b IS p:bounds.
    LOCAL diag IS b:absmax - b:absmin.
    LOCAL sizeX IS abs(VDOT(SHIP:FACING:starvector, diag)).
    LOCAL sizeY IS abs(VDOT(SHIP:FACING:topvector, diag)).
    LOCAL sizeZ IS abs(VDOT(SHIP:FACING:FOREVECTOR, diag)).
    
    LOCAL parentUid IS "".
    IF p:hasparent {
        SET parentUid TO p:parent:uid.
    }
    
    IF NOT first {
        SET jsonOut TO jsonOut + ",".
    }
    SET first TO FALSE.
    
    SET jsonOut TO jsonOut + "{".
    SET jsonOut TO jsonOut + """uid"": """ + p:uid + """,".
    SET jsonOut TO jsonOut + """name"": """ + p:NAME + """,".
    SET jsonOut TO jsonOut + """parent"": """ + parentUid + """,".
    SET jsonOut TO jsonOut + """pos"": [" + ROUND(posX, 2) + ", " + ROUND(posY, 2) + ", " + ROUND(posZ, 2) + "],".
    SET jsonOut TO jsonOut + """size"": [" + ROUND(sizeX, 2) + ", " + ROUND(sizeY, 2) + ", " + ROUND(sizeZ, 2) + "]".
    SET jsonOut TO jsonOut + "}".
}

SET jsonOut TO jsonOut + "] }".

LOG jsonOut TO structFile.
PRINT "Vessel scan complete. Exported " + SHIP:parts:length + " parts.".
