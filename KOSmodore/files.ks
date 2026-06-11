RUN once "/KOSmodore/GPS.ks".
RUN once "/KOSmodore/keybT9.ks".
RUN once "/KOSmodore/main.ks".
RUN once "/KOSmodore/runKS.ks".
RUN once "/KOSmodore/texted.ks".

FUNCTION saveas {
	IF (Npage = 52) OR (Npage = 53) OR (Npage = 54) {
		WRITEJSON(GPSPOS, "/KOSmodore/positions/" + EmptyProg[0] + ".pos").
		GoPage(50).
	}
	IF (Npage = 33) OR (Npage = 34) OR (Npage = 35) {
		WRITEJSON(LoadedTrack, "/KOSmodore/tracks/" + EmptyProg[0] + ".trk").
		GoPage(30).
	}
	
	// file rename
	IF (Npage = 37) OR (Npage = 38) OR (Npage = 39) {
		SET INPstr1 TO emptyprog[0].
		MovePATH("/KOSmodore/tracks/" + li[lind],
		"/KOSmodore/tracks/" + emptyprog[0] + ".trk").
		gopage(31).
	}
	IF (Npage = 57) OR (Npage = 58) OR (Npage = 59) {
		SET INPstr1 TO emptyprog[0].
		MovePATH("/KOSmodore/positions/" + li[lind],
		"/KOSmodore/positions/" + emptyprog[0] + ".pos").
		gopage(51).
	}
	IF (Npage = 87) OR (Npage = 88) OR (Npage = 89) {
		SET INPstr1 TO emptyprog[0].
		MovePATH("/KOSmodore/sampling/" + li[lind],
		"/KOSmodore/sampling/" + emptyprog[0] + ".dat").
		gopage(71).
	}
	IF (Npage = 187) OR (Npage = 188) OR (Npage = 189) {
		SET INPstr1 TO emptyprog[0].
		MovePATH("/KOSmodore/kerboscript/" + li[lind],
		"/KOSmodore/kerboscript/" + emptyprog[0] + ".ks").
		gopage(201).
	}
	IF (Npage = 197) OR (Npage = 198) OR (Npage = 199) {
		SET INPstr1 TO emptyprog[0].
		MovePATH("/KOSmodore/sks/" + li[lind],
		"/KOSmodore/sks/" + emptyprog[0] + ".sks").
		gopage(205).
	}
	IF (Npage = 227) OR (Npage = 228) OR (Npage = 229) {
		SET INPstr1 TO emptyprog[0].
		MovePATH("/KOSmodore/ksp-basic/" + li[lind],
		"/KOSmodore/ksp-basic/" + emptyprog[0] + ".sbas").
		gopage(221).
	}
	
	
	IF (Npage = 83) OR (Npage = 84) OR (Npage = 85) {
		WRITEJSON(SensLog, "/KOSmodore/sampling/" + EmptyProg[0] + ".dat").
		GoPage(70).
	}
	IF (Npage = 207) OR (Npage = 208) OR (Npage = 209) {
		LOCAL fname TO EmptyProg[0].
		SET EmptyProg TO STextAux:COPY.
		STextAux:CLEAR.
		IF exists("/KOSmodore/kerboscript/" + fname + ".ks") {
		deletepath("/KOSmodore/kerboscript/" + fname + ".ks").
		}
		FOR lin IN emptyprog {
			LOG lin TO "/KOSmodore/kerboscript/" + fname + ".ks".
		}
		GoPage(218).
	}
	IF (Npage = 243) OR (Npage = 244) OR (Npage = 245) {
		LOCAL fname TO EmptyProg[0].
		SET EmptyProg TO STextAux:COPY.
		STextAux:CLEAR.
		WRITEJSON(EmptyProg, "/KOSmodore/ksp-basic/" + fname + ".sbas").
		GoPage(220).
	}
	IF (Npage = 253) OR (Npage = 254) OR (Npage = 255) {
		LOCAL fname TO EmptyProg[0].
		SET EmptyProg TO STextAux:COPY.
		STextAux:CLEAR.
		WRITEJSON(EmptyProg, "/KOSmodore/sks/" + fname + ".sks").
		GoPage(218).
	}
}

FUNCTION delfilelist {
	IF Npage = 51 {
		deletepath ("/KOSmodore/positions/" + li[lind]).
		gopage(51).
	}
	IF Npage = 31 {
		deletepath ("/KOSmodore/tracks/"+ li[lind]).
		gopage(31).
	}
	IF Npage = 71 {
		deletepath ("/KOSmodore/sampling/" + li[lind]).
		gopage(71).
	}
	IF Npage = 201 {
		deletepath ("/KOSmodore/kerboscript/" + li[lind]).
		gopage(201).
	}
	IF Npage = 205 {
		deletepath ("/KOSmodore/sks/" + li[lind]).
		gopage(205).
	}
	IF Npage = 221 {
		deletepath ("/KOSmodore/ksp-basic/" + li[lind]).
		gopage(221).
	}
}

FUNCTION Mkcopyfilelist {
	IF Npage = 51 {
		COPYPATH("/KOSmodore/positions/" + li[lind],
		"/KOSmodore/positions/c-" + li[lind]).
		gopage(51).
	}
	IF Npage = 31 {
		COPYPATH("/KOSmodore/tracks/" + li[lind],
		"/KOSmodore/tracks/c-" + li[lind]).
		gopage(31).
	}
	IF Npage = 71 {
		COPYPATH("/KOSmodore/sampling/" + li[lind],
		"/KOSmodore/sampling/c-" + li[lind]).
		gopage(71).
	}
	IF Npage = 201 {
		COPYPATH("/KOSmodore/kerboscript/" + li[lind],
		"/KOSmodore/kerboscript/c-" + li[lind]).
		gopage(201).
	}
	IF Npage = 205 {
		COPYPATH("/KOSmodore/sks/" + li[lind],
		"/KOSmodore/sks/c-" + li[lind]).
		gopage(205).
	}
	IF Npage = 221 {
		COPYPATH("/KOSmodore/ksp-basic/" + li[lind],
		"/KOSmodore/ksp-basic/c-" + li[lind]).
		gopage(221).
	}
}

FUNCTION Renfilelist {
	IF Npage = 31 {
		//set emptyprog[0] to "".
		TypeString(37,"New file name: ",0, TRUE).
	}
	IF Npage = 51 {
		//set emptyprog[0] to "".
		TypeString(57,"New file name: ",0, TRUE).
	}
	IF Npage = 71 {
		//set emptyprog[0] to "".
		TypeString(87,"New file name: ",0, TRUE).
	}
	IF Npage = 201 {
		//set emptyprog[0] to "".
		TypeString(187,"New file name: ",0, TRUE).
	}
	IF Npage = 205 {
		//set emptyprog[0] to "".
		TypeString(197,"New file name: ",0, TRUE).
	}
	IF Npage = 221 {
		//set emptyprog[0] to "".
		TypeString(227,"New file name: ",0, TRUE).
	}
	
}

FUNCTION Savefilelist {
	PARAMETER mult.
	IF Npage = 50 {
		IF GPSPOS:length = 0 {
			PRINT "No destination set. Can't save." AT(0,0).
		}
		ELSE {
			TypeString(52,"File name: ",0, TRUE).
		}
	}
	IF Npage = 30 {
		IF LoadedTrack:LENGTH < 2 {
			PRINT "No track set. Can't save." AT(0,0).
		}
		ELSE {
			TypeString(33,"File name: ",0, TRUE).
		}
	}
	IF Npage = 70 {
		IF SensLog:LENGTH < 2 {
			 PRINT "No data log set. Can't save." AT(0,0).
		}
		ELSE {
			TypeString(83,"File name: ",0, TRUE).
		}
	}
	IF Npage = 218 AND mult = 0 {TypeString(253,"File name: ",0, TRUE).}
	IF Npage = 218 AND mult = 1 {TypeString(207,"File name: ",0, TRUE).}
	IF Npage = 220 {TypeString(243,"File name: ",0, TRUE).}
}
// SAVE SENSORS LOG
//function button08Press {
//clearscreen.
//WRITEJSON(SensLog, "/KOSmodore/senslog.json").
//
//DELETEPATH("/KOSmodore/senslog.txt").
//FOR S IN SensLog {
//		FOR SS IN S {
//			LOG SS to "/KOSmodore/senslog.txt".
//		}		
//		LOG "" TO "/KOSmodore/senslog.txt".
//	}
//
//print "Saved to " + PATH() + "/KOSmodore/senslog.json".
//print "Saved to " + PATH() + "/KOSmodore/senslog.txt".
//
//}