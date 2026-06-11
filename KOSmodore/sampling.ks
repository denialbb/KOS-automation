@LAZYGLOBAL OFF.

// Clear sample LOG
FUNCTION ClearSensLOG {
	SensLOG:CLEAR.
	InitSensLog().
	IF	npage = 70 {
		GoPage(70).
	}
}




// Sensor reading for print (era in main, mai testato fuori)
FUNCTION button02Press {
	LOCAL X IS 0.
	CLEARSCREEN.
	PRINT "Reading time: " + ROUND(TIME:SECONDS,3) AT (0,1).
	PRINT SHIP:BODY AT (0,2).
	
	//local bodynome to SHIP:body.
	//print "|" + bodynome + "|" + SHIP:BODY + "|".
	//print "Temp. model [ K ]: " + BODYATMOSPHERE("Kerbin"):ALTTEMP(10) AT (0,2).
	
	//scanning sensor readings by senselist
	
	// ti da la somma delle esposizioni di tutti i pannelli solari.
	//Se nn ce ne sono ti da 0. Quindi l'unità di misura sono tipo i Watt prodotti
	
	
	    // solar panels
		PRINT "Light exp: " + ROUND(SHIP:sensors:LIGHT,4) AT (0,5).
	
		
	
	FOR S IN SENSELIST {
		IF S:ACTIVE {
		} ELSE {
			S:TOGGLE().
		}
		IF S:TYPE = "TEMP" {
		PRINT "Temp [ K ]: " + ROUND(SHIP:sensors:TEMP,4) AT (0,6+X). // S:DISPLAY 
		}
		
		IF S:TYPE = "PRES" {
		PRINT "Pres [ kPa ]: " + ROUND(SHIP:sensors:PRES,4) AT (0,6+X). // S:DISPLAY
		}
		
		//GRAV and ACC are vectors		
		//if S:TYPE = "GRAV" {
		//print "Grav = " + SHIP:sensors:GRAV + S:DISPLAY AT (0,4+X).
		//}
		
		//if S:TYPE = "ACC" {
		//print "Acc = " + SHIP:sensors:ACC + S:DISPLAY AT (0,4+X).
		//}
		
		//PRINT S:TYPE + ": " + S:DISPLAY AT (0,3+X).
	SET X TO X+1.
	}
	
    
	//print ship:sensors:temp at (0,8).
}

//old view sampling
FUNCTION button03Press {
	CLEARSCREEN.
	LOCAL x TO 0.
	LOCAL y TO 0.
	FOR S IN SensLog {
		FOR SS IN S {
			PRINT ROUND(SS,2) AT (X,Y).
			SET x TO x+9.
		}		
		SET y TO y+1.
		SET x TO 0.
	}
}