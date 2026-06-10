@lazyGlobal on.

print "Scanning Vessel Structure...".

local structFile is "0:/telemetry/vessel_structure.json".
if exists(structFile) {
    deletepath(structFile).
}

local jsonOut is "{ ""parts"": [".
local first is true.

for p in ship:parts {
    local vRel is p:position - ship:position.
    local posX is vdot(ship:facing:starvector, vRel).
    local posY is vdot(ship:facing:topvector, vRel).
    local posZ is vdot(ship:facing:forevector, vRel).
    
    local b is p:bounds.
    local diag is b:absmax - b:absmin.
    local sizeX is abs(vdot(ship:facing:starvector, diag)).
    local sizeY is abs(vdot(ship:facing:topvector, diag)).
    local sizeZ is abs(vdot(ship:facing:forevector, diag)).
    
    local parentUid is "".
    if p:hasparent {
        set parentUid to p:parent:uid.
    }
    
    if not first {
        set jsonOut to jsonOut + ",".
    }
    set first to false.
    
    set jsonOut to jsonOut + "{".
    set jsonOut to jsonOut + """uid"": """ + p:uid + """,".
    set jsonOut to jsonOut + """name"": """ + p:name + """,".
    set jsonOut to jsonOut + """parent"": """ + parentUid + """,".
    set jsonOut to jsonOut + """pos"": [" + round(posX, 2) + ", " + round(posY, 2) + ", " + round(posZ, 2) + "],".
    set jsonOut to jsonOut + """size"": [" + round(sizeX, 2) + ", " + round(sizeY, 2) + ", " + round(sizeZ, 2) + "]".
    set jsonOut to jsonOut + "}".
}

set jsonOut to jsonOut + "] }".

log jsonOut to structFile.
print "Vessel scan complete. Exported " + ship:parts:length + " parts.".
