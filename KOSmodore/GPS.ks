GLOBAL GPSPOS TO LIST().//////////////////
GLOBAL Destin TO LATLNG(0, 0).////////////

GLOBAL GEOPOS TO LATLNG(10, 20). 

FUNCTION DRAWTRK {
	GTrack(LoadedTrack).
}

FUNCTION AddHereToTrack{
	LoadedTrack:ADD(LIST()).
	LoadedTrack[LoadedTrack:LENGTH-1]:ADD(TIME:SECONDS).			
	LoadedTrack[LoadedTrack:LENGTH-1]:ADD(SHIP:GEOPOSITION:LAT).
	LoadedTrack[LoadedTrack:LENGTH-1]:ADD(SHIP:GEOPOSITION:LNG).
	Gopage(30).
}

FUNCTION RemoveLastFromTrack{
	IF LoadedTrack:LENGTH > 1{
		LoadedTrack:REMOVE(LoadedTrack:LENGTH-1).	
	}
	Gopage(30).
}

FUNCTION RemoveFirstFromTrack{
	IF LoadedTrack:LENGTH > 1{
		LoadedTrack:REMOVE(1).
	}
	Gopage(30).
}

FUNCTION InitGPSLog {	
		LoadedTrack:ADD(LIST()).
	    LoadedTrack[LoadedTrack:LENGTH-1]:ADD(0).   //Time
		LoadedTrack[LoadedTrack:LENGTH-1]:ADD(101). //latitude
		LoadedTrack[LoadedTrack:LENGTH-1]:ADD(102). //longitude 
}


// SAVE GPS POS
FUNCTION SaveGPSPOS {
	CLEARSCREEN.
	WRITEJSON(GPSPOS, "/KOSmodore/GPSpos.json").
	PRINT "Saved to " + PATH() + "/KOSmodore/GPSpos.json".
}

// save POS to random file
FUNCTION SaveDestRND {
GoPage(50).
	
	//if EXISTS("/KOSmodore/positions/+fname")
		
	IF GPSPOS:length = 0 {
		 PRINT "No destination set. Can't save." AT(0,0).
	} ELSE {
		LOCAL fname TO "".
		FROM {LOCAL x IS 8.} UNTIL x = 0 STEP {SET x TO x-1.} DO {
			SET fname TO fname + (FLOOR(10*RANDOM())).
		}
		SET fname TO fname + ".pos".

		UNTIL NOT EXISTS("/KOSmodore/positions/" + fname) {
			SET fname TO "".
			FROM {LOCAL x IS 8.} UNTIL x = 0 STEP {SET x TO x-1.} DO {
				SET fname TO fname + (FLOOR(10*RANDOM())).
			}
			SET fname TO fname + ".pos".
		}
	

		WRITEJSON(GPSPOS, "/KOSmodore/positions/" + fname).

		PRINT "----------------------------------------" AT(0,14). //LUNGO GIUSTO
		PRINT "Saved to:" AT(1,15).
		//print PATH() + "/KOSmodore/positions/" + 
		PRINT fname AT (1,16).
	}
}


FUNCTION ClrGPSPOS {
	GPSPOS:CLEAR.
	IF NPage = 50 {GoPage(50).}
}

FUNCTION RecGPSPOS {
	GPSPOS:CLEAR.
	GPSPOS:ADD(SHIP:GEOPOSITION:LAT).
	GPSPOS:ADD(SHIP:GEOPOSITION:LNG).
	SET GeoPos TO SHIP:GEOPOSITION.
	IF NPage = 50 {GoPage(50).}
}

// Clear GPS LOG
FUNCTION ClearGPSLOG {
	LoadedTrack:CLEAR.
	InitGPSLog().
	Gopage(30).
}

