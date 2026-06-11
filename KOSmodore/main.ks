//-------------------------------------------------|
//                                                 |
//  kOS-Computer - by Sinucep - 2025  |
//                                                 |
//-------------------------------------------------|

@LAZYGLOBAL OFF.

RUN once "/KOSmodore/terminal.ks".
RUN once "/KOSmodore/GPS.ks".
RUN once "/KOSmodore/rover.ks".
RUN once "/KOSmodore/splashes.ks".
RUN once "/KOSmodore/interface.ks".
RUN once "/KOSmodore/graphics.ks".
RUN once "/KOSmodore/math.ks".
RUN once "/KOSmodore/sampling.ks".
RUN once "/KOSmodore/pages.ks".
RUN once "/KOSmodore/datalog.ks".
RUN once "/KOSmodore/settings.ks".
RUN once "/KOSmodore/runKS.ks".
RUN once "/KOSmodore/texted.ks".
//run once "/KOSmodore/basicflow.ks".

GLOBAL fine TO FALSE. // per uscire dal programma e usare il terminale

//Addon KOSProp Monitor
GLOBAL monitors TO ADDONS:kpm:getmonitorcount().
GLOBAL id TO ADDONS:kpm:getguidshort(0).      // OR set id to addons:kpm:getguid(0).
GLOBAL monindex TO ADDONS:kpm:getindexof(id). // If GETINDEXOF Returns -1, GUID Not Found. Works for Whole GUID and Short GUID

LOCAL LogStart IS 0.
LOCAL GPSLogStart IS 0.
LOCAL PosStart IS 0.                      // just for to blink once POS flag
LOCAL CuBlinkStart IS 0.                   // for to blink the cursor

GLOBAL SensLog TO LIST().
GLOBAL LoadedTrack TO LIST().  
GLOBAL endpos TO LatLng(-90,8). 			  //destinazione provvissoria per il rover                   
GLOBAL SENSELIST TO LIST().


LIST SENSORS IN SENSELIST.

InitTerminalMAIN(monitors).

FUNCTION ExitOS {
	FROM {LOCAL x IS 0.} UNTIL x = monitors STEP {SET x TO x+1.} DO {
		ClearTerminal(x).
	}
	CLEARSCREEN.
	PRINT "Exit main loop.".
	SET fine TO TRUE.
}
	
FUNCTION toggleFlag {
	PARAMETER flagNum IS 0.
    IF flagNum = 0 {
		
		SET PosStart TO TIME:SECONDS.
		RecGPSPOS().
	}
	IF flagNum = 1 {
		SET GPSLogStart TO TIME:SECONDS.
	}
	IF flagNum = 2 {
		SET LogStart TO TIME:SECONDS.
	}
	
	FROM {LOCAL x IS 0.} UNTIL x = monitors STEP {SET x TO x+1.} DO { 
		SET myflags:currentmonitor TO x. 
		
		IF flagNum = 0 {
			myflags:setstate(0,TRUE).	
		}
		IF flagNum = 1 {
			myflags:setstate(1,NOT (myflags:getstate(1))).
		}
		IF flagNum = 2 {
			myflags:setstate(2,NOT (myflags:getstate(2))).	
		}
	}
}

FUNCTION MyREBOOT {
	REBOOT.	
}

FUNCTION goroverpos {

	IF GPSPOS:Length = 0 {
		PRINT "No destination set." AT(0 + debugoffset,1).
	} ELSE {	
	
	//clearScreen.
	BRAKES OFF.	
	SET endPos TO LatLng(GPSPOS[0], GPSPOS[1]).
	
	//solo per inizializzare qualcosa:
	SET speedPID:setPoint TO 1.   //speed
	SET turnPID:setPoint TO 0.     	//Direction
		
	GLOBAL wanted_throttle TO 0. // for now.
	LOCK wheelThrottle TO wanted_throttle.
	GLOBAL wanted_angle TO 0.
	LOCK WHEELSTEERING TO wanted_angle.
	
	SET controlrover TO 1.
	SET roverstate TO 1.
	} 	
}

FUNCTION gorovertrack {
	
	IF LoadedTrack:Length = 1 { //perché c'è lo header
		PRINT "No track set." AT(1,1).
	} ELSE {	
		CLEARSCREEN.
		BRAKES OFF.	
		
		SET speedPID:setPoint TO 1.      //Speed
		SET turnPID:setPoint TO 0.      //Direction
			
		GLOBAL wanted_throttle TO 0. // for now.
		LOCK wheelThrottle TO wanted_throttle.
		GLOBAL wanted_angle TO 0.
		LOCK WHEELSTEERING TO wanted_angle.
	
		SET roverstate TO 1.
		SET controlrover TO 2.
	}
}
FUNCTION DataLogAdd {
			SensLog:ADD(LIST()).
			SensLog[SensLog:LENGTH-1]:ADD(TIME:SECONDS).
			FOR ds IN DataSourcesAdded {
				IF ds = 1 {SensLog[SensLog:LENGTH-1]:ADD(SHIP:sensors:LIGHT).}
				IF ds = 2 {SensLog[SensLog:LENGTH-1]:ADD(SHIP:sensors:TEMP).}
				IF ds = 3 {SensLog[SensLog:LENGTH-1]:ADD(SHIP:sensors:PRES).}
				IF ds = 4 {SensLog[SensLog:LENGTH-1]:ADD(SHIP:MASS).}
				IF ds = 10 {SensLog[SensLog:LENGTH-1]:ADD(SHIP:MASS).}
				IF ds = 20 {SensLog[SensLog:LENGTH-1]:ADD(SHIP:airspeed).}
				IF ds = 21 {SensLog[SensLog:LENGTH-1]:ADD(SHIP:verticalspeed).}
				IF ds = 22 {SensLog[SensLog:LENGTH-1]:ADD(SHIP:groundspeed).}
				IF ds = 101 {SensLog[SensLog:LENGTH-1]:ADD(SHIP:GEOPOSITION:LAT).}
				IF ds = 102 {SensLog[SensLog:LENGTH-1]:ADD(SHIP:GEOPOSITION:LNG).}
			}
			
			IF Npage = 70 {
				GoPage(70).
			}
			IF Npage = 72 {
				GoPage(72).
			}
}

//---------------------Initialize-----------------------

riempiSettings().
DataSourcesAdded:ADD(4). // default source: Vessel mass
InitSensLog().
InitGPSLog().
switch TO 0. //con questa riga i file vengono salvati fisicamente (in archivio)
BRAKES ON.   //for rovers..
SPage(0).

riempisourcelist().
initstextvar().
mainsplash().

SET LBook TO READJSON("/KOSmodore/logbook/logbook.json").
PRINT "Logbook loaded from logbook.json".
SET CurrentNote TO LBook:LENGTH-1.

//flags
 myflags:setstate(0,FALSE).
  myflags:setstate(1,FALSE).
  myflags:setstate(2,FALSE).
  
//----------------------Starting page-------------------


//GoPage(8).
//GoPage(237).   //new basic
//GoPage(221).   //open basic
//set debugbas to true.

//----------------------Main Loop-----------------------

UNTIL fine {
// Pos flag label blink
IF myflags:getstate(0) {
		IF TIME:SECONDS > PosStart + 1{
			 MSetFlag(0,FALSE,monitors).
		}
	}

//LOGging
	IF myflags:getstate(1) {
		IF TIME:SECONDS > GPSLogStart {
			LoadedTrack:ADD(LIST()).
			LoadedTrack[LoadedTrack:LENGTH-1]:ADD(TIME:SECONDS).			
			LoadedTrack[LoadedTrack:LENGTH-1]:ADD(SHIP:GEOPOSITION:LAT).
			LoadedTrack[LoadedTrack:LENGTH-1]:ADD(SHIP:GEOPOSITION:LNG).
			
			IF Npage = 30 {
				Gopage(30).
			}
			IF Npage = 32 {
				GoPage(32).
			}
			
			SET GPSLogStart TO GPSLogStart + SettingsL[2]. //  track sampling time interval
		}
	}
	
	IF myflags:getstate(2) {
		IF TIME:SECONDS > LogStart {		
			DataLogAdd().
			
			SET LogStart TO LogStart + SettingsL[1]. // data sampling time interval
		}
	}

//rover
	IF controlrover = 1 {
		conroverPos(endPos).
	}
	IF controlrover = 2 {
		ConRovertrack(LoadedTrack).
	}
	
//blinking cursor
    IF NPage = 237 OR NPage = 238 OR NPage = 239 OR NPage = 240 OR
	   NPage = 277 OR NPage = 278 OR NPage = 279 OR NPage = 280 OR
	   NPage = 243 OR NPage = 244 OR NPage = 245 OR
	   NPage = 253 OR NPage = 254 OR NPage = 255 OR	   
	   NPage = 52 OR NPage = 53 OR NPage = 54 OR
	   NPage = 55 OR NPage = 56 OR
	   // file rename
	   NPage = 37 OR NPage = 38 OR NPage = 39 OR
	   NPage = 57 OR NPage = 58 OR NPage = 59 OR
	   NPage = 87 OR NPage = 88 OR NPage = 89 OR
	   NPage = 187 OR NPage = 188 OR NPage = 189 OR
	   NPage = 197 OR NPage = 198 OR NPage = 199 OR
	   NPage = 227 OR NPage = 228 OR NPage = 229 OR
	   
	   NPage = 33 OR NPage = 34 OR NPage = 35 OR
	   NPage = 83 OR NPage = 84 OR NPage = 85 OR
	   NPage = 101 OR NPage = 102 OR NPage = 103 OR
	   NPage = 207 OR NPage = 208 OR NPage = 209{
		IF TIME:SECONDS > CuBlinkStart + .45{
			SET CuBlinkStart TO TIME:SECONDS.
			SET cuVisible TO NOT cuvisible.
			IF cuVisible {
				Cur().
			} ELSE {
				Cudel().
			}
		}
	}


// BASIC

IF (BASICrun) {RunBASICline().} 

// return to basic program (v1.1.1)

IF backtobascase = 2 {
	IF TIME:SECONDS > basWStart + basWtime {
		//set exodos to false.
		SET backtobascase TO 0.
		SET BASICrun TO TRUE.
	}
}
		
	

	IF backtobascase = 1 {		
		IF controlrover = 0 {
			SET backtobascase TO 0.
			SET BASICrun TO TRUE.
		}
	}

//debug window
	IF debugbas AND (Npage = 220 OR Npage = 230 OR NPage = 231) {
		IF TIME:SECONDS > debugbasstart + .5{
			SET debugbasstart TO TIME:SECONDS.
			debugwin().
		}
	}
}
