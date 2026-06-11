RUN once "/KOSmodore/logbook.ks".
RUN once "/KOSmodore/keybT9.ks".
RUN once "/KOSmodore/interface.ks".
RUN once "/KOSmodore/datalog.ks".
RUN once "/KOSmodore/texted.ks".
RUN once "/KOSmodore/basicflow.ks".

FUNCTION GoPage {
	PARAMETER p.
	
	SET NPage TO p.
	
	// Main
	IF p = 1 {                     
		SPage(1).
		InitTerminalMAIN(monitors).
	}
	
	// Test
	IF p = 8 {                     
		SPage(8).
		InitTermTEST(monitors).
		CLEARSCREEN.
	}
	
	// Rover
	IF p = 20 {
		SPage(20).
		InitTerminalROVER(monitors).
	}
	
	// Tracks
	IF p = 30 {
		SPage(30).
		InitTerminalGPS(monitors).
		IF LoadedTrack:length = 1{
			PRINT "No track set." AT(0,0).
		} ELSE {
			PRINT "Track of " + (LoadedTrack:length-1) + " spots set." AT(0,0).
		}
	}
	
	// Select track file
	IF p = 31 {
		SPage(31).	
		SET lind TO 0.
		InitTermFileLoad(monitors).
		cd("KOSmodore").
		cd("tracks").
		LIST FILES IN li.
		cd("..").
		cd("..").
		listafile(li).
	}
	
	// View track
	IF p = 32 {
		SPageTile(32,"Time          Latitude      Longitude").
		LOCAL x TO 0.
		LOCAL y TO 0.
		InitTerminalViewTrack(monitors).
		FOR S IN LoadedTrack {
			IF y>0 {
				FOR SS IN S {
					IF x = 0 {
						PRINT ROUND(SS,1) AT (0,Y).
					} ELSE {
						PRINT ROUND(SS,7) AT (X*14,Y).
					}
					SET x TO x+1.
				}		
			}
			SET y TO y+1.
			SET x TO 0.
		}	
	}
		
	// T9 save track pages
	IF p = 33 {InitTermFileSave(monitors).}
	IF p = 34 {InitTermFileSave1(monitors).}
	IF p = 35 {InitTermFileSave2(monitors).}
	
// rename track
	IF p = 37 {
		SPageNoClear(37).	
		InitTermFileSave(monitors).
	}
	IF p = 38 {
		SPageNoClear(38).	
		InitTermFileSave1(monitors).
	}
	IF p = 39 {
		SPageNoClear(39).	
		InitTermFileSave2(monitors).
	}
	
	// Logbook
	//if p = 40 {
//		SPage(40).
		//InitTermLogBook(monitors).	
		//local cou to 0.
		//for lin in LBook[CurrentNote] {
//			print lin at(0,cou).
			//set cou to cou + 1.
		//}
	//}
	
	// Logbook write pages
	//if p = 41 {
		//local cou to 0.
		//resetcicleset().
		//SPage(41).
		//InitTermLogBook1(monitors).	
		//for lin in LBook[CurrentNote] {
//			print lin at(0,cou).
			//set cou to cou + 1.
		//}
		//setxy(0,LBook[CurrentNote]:LENGTH).
		//print "_" AT(0,LBook[CurrentNote]:LENGTH).
		////2 righe magiche che editano l'ultima riga del diario:
		////print "_"AT(LBook[LBook:LENGTH-1]:LENGTH+1,LBook:LENGTH).
		////set linea to LBook[LBook:LENGTH-1][LBook[LBook:LENGTH-1]:LENGTH-1].
		//print linea + "_" AT(0,cou).
	//}
	
	//if p = 42 {
//		local cou to 0.
		//SPage(42).
		//InitTermLogBook2(monitors).
		//for lin in LBook[CurrentNote] {
//			print lin at(0,cou).
			//set cou to cou + 1.
		//}
		//setxy(0,LBook[CurrentNote]:LENGTH).
		//print "_"AT(0,LBook[CurrentNote]:LENGTH).
		//print linea + "_" AT(0,cou).
	//}
	
//	if p = 43 {
		//local cou to 0.
		//SPage(43).
		//InitTermLogBook3(monitors).
		//for lin in LBook[CurrentNote] {
//			print lin at(0,cou).
			//set cou to cou + 1.
		//}
		//setxy(0,LBook[CurrentNote]:LENGTH).
		//print "_"AT(0,LBook[CurrentNote]:LENGTH).
		//print linea + "_" AT(0,cou).
	//}
	
	//Destinations
	IF p = 50 {
		SPage(50).
		InitTerminalDestination(monitors).
		IF GPSPOS:length = 0{
			PRINT "No destination set." AT(0,0).
		} ELSE {
			PRINT "Destination set:" AT(0,0).
			PRINT ROUND(GPSPOS[0],4) + ", " + ROUND(GPSPOS[1],4) AT(0,1).
		}
	}

	IF p = 51 {
		SPage(51).	
		SET lind TO 0.
		InitTermFileLoad(monitors).
		cd("KOSmodore").
		cd("positions").
		LIST FILES IN li.
		cd("..").
		cd("..").
		listafile(li).
	}		

	// save destination
	IF p = 52 {InitTermFileSave(monitors).}
	IF p = 53 {InitTermFileSave1(monitors).}
	IF p = 54 {InitTermFileSave2(monitors).}
	
	// rename destination
	IF p = 57 {InitTermFileSave(monitors).}
	IF p = 58 {InitTermFileSave1(monitors).}
	IF p = 59 {InitTermFileSave2(monitors).}
	
	// Datalog
	IF p = 70 {
		SPage(70).
		InitTerminalSampler(monitors).	
		IF SensLog:Length = 1 { //perché c'è lo header
			PRINT "No data log set." AT(0,0).
		} ELSE {	
			PRINT "LOG of " + (SensLog:length-1) + " samples set." AT(0,0).
		}
		PRINT "SOURCES:" AT(0,1).
		ShowAddedDSources(2).
	}
	
    // Select datalog file
	IF p = 71 {
		SPage(71).	
		SET lind TO 0.
		InitTermFileLoad(monitors).
		cd("KOSmodore").
		cd("sampling").
		LIST FILES IN li.
		cd("..").
		cd("..").
		listafile(li).
	}
	
	// Datalog view
	IF p = 72 {
		// per capire quali sorgenti ci sono
		IF SensLog[0]:LENGTH > 1 {
			SET selcolumn TO 1.
			SET maxcolumn TO SensLog[0]:LENGTH - 1.
		}
		ViewDataLogSource(selcolumn).
		InitTerminalViewDataLog(monitors).
	}
	
	// ask before changing source list and clean datalog
	IF p = 74 {
		SPage(74).
		PRINT "Changing sources will result in the" AT(0,0).
		PRINT "loss of the current data log." AT(0,1).
		PRINT "If you need it, save it first." AT(0,2).
		PRINT "Do you want to proceed clearing" AT(0,3).
		PRINT "the current log?" AT(0,4).
		InitTermProceedToSource(monitors).
	}
	
	// Select data source
	IF p = 75 {
		SPage(75).
		ClearSensLOG(). //clean the data log.
		InitTermShowDataSources(monitors).
		ShowAddedDSources(0).
	}
	
	// Add data source from list
	IF p = 76	{
		SPage(76).	
		SET lind TO 0.
		InitTermSelectDataSourcesAdd(monitors).
		ListaStr(DSnames(DataSources)).
	}
	
	// Delete data source from list
	IF p = 77 {
		SPage(77).	
		SET lind TO 0.
		InitTermSelectDataSourcesSub(monitors).
		ListaStr(DSnames(DataSourcesAdded)).
	}
	
	// save data log
	IF p = 83 {InitTermFileSave(monitors).}
	IF p = 84 {InitTermFileSave1(monitors).}
	IF p = 85 {InitTermFileSave2(monitors).}
	
	// rename datalog
	IF p = 87 {InitTermFileSave(monitors).}
	IF p = 88 {InitTermFileSave1(monitors).}
	IF p = 89 {InitTermFileSave2(monitors).}
	
	// Settings
	IF p = 100 {
		SPage(100).	
		InitTermSettings(monitors).
		PRINT "Marker thickness: " + SettingsL[0] AT(0,0).
		PRINT "Data log sampling interval (s): " + SettingsL[1] AT(0,1).
		PRINT "Track sampling interval (s): " + SettingsL[2] AT(0,2).
	}
	
	// rename ks
	IF p = 187 {
		SPageNoClear(187).	
		InitTermFileSave(monitors).
	}
	IF p = 188 {
		SPageNoClear(188).	
		InitTermFileSave1(monitors).
	}
	IF p = 189 {
		SPageNoClear(189).	
		InitTermFileSave2(monitors).
	}
	// rename sks
	IF p = 197 {
		SPageNoClear(197).	
		InitTermFileSave(monitors).
	}
	IF p = 198 {
		SPageNoClear(198).	
		InitTermFileSave1(monitors).
	}
	IF p = 199 {
		SPageNoClear(199).	
		InitTermFileSave2(monitors).
	}
	
	// Programs
	IF p = 200 {
		SPage(200).	
		InitTermPrograms(monitors).
	}
	
	// select and load kerboscript from file
	IF p = 201 {
		SPage(201).	
		SET lind TO 0.
		InitTermFileLoad(monitors).
		cd("KOSmodore").
		cd("kerboscript").
		LIST FILES IN li.
		cd("..").
		cd("..").
		listafile(li).
	}
	
	// select and load serializedkerboscript from file
	IF p = 205 {
		SPage(205).	
		SET lind TO 0.
		InitTermFileLoad(monitors).
		cd("KOSmodore").
		cd("sks").
		LIST FILES IN li.
		cd("..").
		cd("..").
		listafile(li).
	}
	
	// export sks to ks file
	IF p = 207 {InitTermFileSave(monitors).}
	IF p = 208 {InitTermFileSave1(monitors).}
	IF p = 209 {InitTermFileSave2(monitors).}
	
	// Running kerboscript program page
	IF p = 210 {
		SPageNoCLear(210).	
		ClearTerminal(monitors).
	}
	
	// Ended program page
	IF p = 211 {
		SPageNoCLear(211).	
		InitTermEndedProgram(monitors).
	}
	
	// View sks prog
	IF p = 218 {
		SPage(218).
		InitTermViewSKS(monitors).	
		CuReset().
		LOCAL cou TO 0.
		FOR lin IN emptyprog {
			PRINT lin AT(0,cou).
			SET cou TO cou + 1.
		}
	}
	
	// View basic prog
	IF p = 220 {
		SPage(220).
		InitTermViewBas(monitors).	
		CuReset().
		LOCAL cou TO 0.
		
		IF debugbas {debugwinframe().}
		
		FOR lin IN emptyprog {
			PRINT lin AT(0 + debugoffset, cou).
			SET cou TO cou + 1.
		}
	}
	
	// Select basic program file
	IF p = 221 {
		SPage(221).
		SET lind TO 0.
		InitTermFileLoad(monitors).
		cd("KOSmodore").
		cd("ksp-basic").
		LIST FILES IN li.
		cd("..").
		cd("..").
		listafile(li).
		SET lind TO 0.
	}
	
	// rename sbas
	IF p = 227 {InitTermFileSave(monitors).}
	IF p = 228 {InitTermFileSave1(monitors).}
	IF p = 229 {InitTermFileSave2(monitors).}
	
// Running basic program page
//	if p = 230 {
//		SPage(230).	
//		InitTermExeBas(monitors).
//		//ClsNoCur().
//		//reclinumbers(emptyprog).
//		runbasic(emptyprog).
//		//reclinumbers(emptyprog).
//		//removelinumber("10 cane").		
//	}
	
// Running basic program 
	IF p = 230 {
		SET BASICrun TO TRUE.
		SET stepmode TO FALSE.
		IF co = -1 {SPage(230).}
		IF debugbas {debugwinframe().}
		//if not stepmode {SPage(230).}
		
		InitTermExeBas(monitors).		
		//print time:seconds at(40,15).
	}
	
// Step running basic program
	IF p = 231 {
		SET BASICrun TO TRUE.
		//print "time:second" AT(10,8).
		//SPagenoclear(231).
		//if not stepmode {SPage(230).}
		
		InitTermstepExeBas(monitors).		
		//print time:seconds at(40,15).
	}

// Edit basic prog 0 con cursore
	IF p = 237 {
		SPage(237).
		InitTermEditBas0cu(monitors).	
		
		LOCAL cou TO 0.
		FOR lin IN emptyprog {
			PRINT lin AT(0,cou).
			SET cou TO cou + 1.
		}
		SET li TO emptyprog.
	}
	
	// Edit basic prog 1 con cursore
	IF p = 238 {
		SPage(238).
		InitTermEditBas1cu(monitors).	
		LOCAL cou TO 0.
		FOR lin IN emptyprog {
			PRINT lin AT(0,cou).
			SET cou TO cou + 1.
		}
		SET li TO emptyprog.
	}
	
	// Edit basic prog 2 con cursore
	IF p = 239 {
		SPage(239).
		InitTermEditBas2cu(monitors).	
		LOCAL cou TO 0.
		FOR lin IN emptyprog {
			PRINT lin AT(0,cou).
			SET cou TO cou + 1.
		}
		SET li TO emptyprog.		
	}
	
	// Edit basic prog 3 con cursore
	IF p = 240 {
		SPage(240).
		(monitors).
		InitTermEditBas3cu(monitors).	
		LOCAL cou TO 0.
		FOR lin IN emptyprog {
			PRINT lin AT(0,cou).
			SET cou TO cou + 1.
		}
		SET li TO emptyprog.
	}
	
	// T9 save BAS pages
	IF p = 243 {InitTermFileSave(monitors).}
	IF p = 244 {InitTermFileSave1(monitors).}
	IF p = 245 {InitTermFileSave2(monitors).}
	
	// T9 save ks pages
	IF p = 253 {InitTermFileSave(monitors).}
	IF p = 254 {InitTermFileSave1(monitors).}
	IF p = 255 {InitTermFileSave2(monitors).}
	
	// Edit sks prog 0 con cursore
	IF p = 277 {
		SPage(277).
		InitTermEditBas0cu(monitors).	
		LOCAL cou TO 0.
		FOR lin IN emptyprog {
			PRINT lin AT(0,cou).
			SET cou TO cou + 1.
		}
		SET li TO emptyprog.
		//Cur().
	}
	
	// Edit sks prog 1 con cursore
	IF p = 278 {
		SPage(278).
		InitTermEditBas1cu(monitors).	
		LOCAL cou TO 0.
		FOR lin IN emptyprog {
			PRINT lin AT(0,cou).
			SET cou TO cou + 1.
		}
		SET li TO emptyprog.
		//Cur().
	}
	
	// Edit sks prog 2 con cursore
	IF p = 279 {
		SPage(279).
		InitTermEditBas2cu(monitors).	
		LOCAL cou TO 0.
		FOR lin IN emptyprog {
			PRINT lin AT(0,cou).
			SET cou TO cou + 1.
		}
		SET li TO emptyprog.
		//Cur().
	}
	
	// Edit sks prog 3 con cursore
	IF p = 280 {
		SPage(280).
		InitTermEditKS3cu(monitors).	
		LOCAL cou TO 0.
		FOR lin IN emptyprog {
			PRINT lin AT(0,cou).
			SET cou TO cou + 1.
		}
		SET li TO emptyprog.
		//Cur().
	}
	
}

// INF. HERE
FUNCTION InfHerePAGE {
	SPage(999).
	PRINT "Latitude: " + ROUND(SHIP:GEOPOSITION:LAT,3) + ", Longitude: "
		+ ROUND(SHIP:GEOPOSITION:LNG,3) AT (0,3). 
	PRINT "Ground distance: " + ROUND(SHIP:GEOPOSITION:distance,3) AT (0,4).
}

FUNCTION TypeRealNum {                       //type latitude
		//Types: 1=real, 2=string
		PARAMETER page, label, y, cls. 
		IF cls {
			SPage(page).
		} ELSE {
			SPageNoClear(page).
		}
		resetcicleset().
		InitTermTypeRealNum(monitors).
		SET emptyprog[0] TO "". 
		SET cuy TO 0.
		SET cux TO 0.
		PRINT label AT(0,y).	
		SET offsy TO y+1.
		setxy(0,y+1).
}

 //you can incorporate thi funtion to the first page like save
FUNCTION TypeString {
	
		PARAMETER page, label, y, cls. 
		IF cls {
			SPage(page).
		} ELSE {
			SPageNoClear(page).
		}
		resetcicleset().
		InitTermFileSave(monitors).
		SET emptyprog[0] TO "". 
		SET cuy TO 0.
		SET cux TO 0.
		PRINT label AT(0,y).	
		SET offsy TO y+1.
		setxy(0,y+1).
}




