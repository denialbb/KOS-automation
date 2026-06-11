FUNCTION SRCOOold { //ship-raw to body coordinates
	PARAMETER vec.
	LOCAL SOIvec TO vec + SHIP:BODY:POSITION.
	LOCAL spot TO LATLNG(10, 20). 
	RETURN spot.
}

FUNCTION SRCOO {    // geo coordinates to ship-raw
	PARAMETER coo,  // coordinate
	          h.    // altezza dal suolo
	
	RETURN geopos:ALTITUDEPOSITION(geopos:TERRAINHEIGHT+h).
    //return geopos:POSITION - geopos:ALTITUDEPOSITION(geopos:TERRAINHEIGHT+3),
            

PRINT ALT:RADAR.
}