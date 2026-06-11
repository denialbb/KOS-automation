@LAZYGLOBAL OFF.

RUN once "/KOSmodore/interface.ks".
RUN once "/KOSmodore/main.ks".


// 0   time
// 1   Light exposition of the solar panels 
// 2   temperature outside the command module
// 3   pressure outside the command module
// 4   mass
// 10  dynamic pressure (Q)
// 20  Air speed (How fast the ship is moving relative to the air)
// 21  Vertical Speed
// 22  Ground Speed (horizontal speed)

// 101 latitude
// 102 longitude
GLOBAL DataSources TO LIST().
GLOBAL DataSourcesAdded TO LIST().
//set mylexicon to lexicon().
//set mylexicon["key1"] TO "value1".
//set mylexicon["key2"] TO "value2".

FUNCTION InitSensLog {	
		SensLog:ADD(LIST()).
	    SensLog[SensLog:LENGTH-1]:ADD(0). //Time
		
		FOR s IN DataSourcesAdded {
			SensLog[SensLog:LENGTH-1]:ADD(s).
		}
		//SensLog[SensLog:LENGTH-1]:add(1). //Light exposition of the solar panels 
		//FOR S IN SENSELIST {
			//if S:TYPE = "TEMP" {
			//	SensLog[SensLog:LENGTH-1]:add(2).
//			}	
//			if S:TYPE = "PRES" {
//				SensLog[SensLog:LENGTH-1]:add(3).
//			}		
//		}
}


FUNCTION riempisourcelist {
	//DataSources:add(0).
	DataSources:ADD(1). // Light exposition of the solar panels 
	DataSources:ADD(4). // Vessel mass
	DataSources:ADD(10). // dynamic pressure (Q)
	DataSources:ADD(20). // Air speed
	DataSources:ADD(21). // vertical speed
	DataSources:ADD(22). // ground speed
	DataSources:ADD(101).
	DataSources:ADD(102).
	
	FOR S IN SENSELIST {
		
			IF S:TYPE = "TEMP" {
				DataSources:ADD(2).
			}
	
			IF S:TYPE = "PRES" {
				DataSources:ADD(3).
			}		
		}
}

// converte un codice nel nome del data source
FUNCTION DSname {
	PARAMETER nu.
	LOCAL str TO "".
	IF nu = -1 { SET str TO "(no datasources)".}
	IF nu = 0 { SET str TO "Time".}
	IF nu = 1 { SET str TO "Light exposition".}	
	IF nu = 2 { SET str TO "Temperature".}	
	IF nu = 3 { SET str TO "Pressure".}
	IF nu = 4 { SET str TO "Vessel mass".}	
	IF nu = 10 { SET str TO "Dynamic pressure (Q)".}
	IF nu = 20 { SET str TO "Air speed".}		
	IF nu = 21 { SET str TO "Vertical speed".}	
	IF nu = 22 { SET str TO "Ground Speed".}	
	IF nu = 101 { SET str TO "Latitude".}	
	IF nu = 102 { SET str TO "Longitude".}	
	RETURN str.
}

// converte una lista di codici in una lista di nomi dei data source
FUNCTION DSnames {	     
	PARAMETER li.        // list input
	LOCAL lo TO LIST().  // list output
	FOR ds IN li {
		lo:ADD(DSname(ds)).
	}
	RETURN lo.
}

FUNCTION ShowAddedDSources {   
	PARAMETER co.
	//local co to 0.
	IF DataSourcesAdded:length = 0 {
		PRINT "No sources selected." AT(0,co).
	} ELSE {
		FOR ds IN DataSourcesAdded {
			//print DSname(ds) + " (" + ds + ")" AT(0,co).
			PRINT "-" + DSname(ds) AT(0,co).
			SET co TO co + 1.
		}
	}
}

//Aggiunge ad una lista di interi un elemento solo se non presente
FUNCTION AddIfNoItem {
	PARAMETER li, item.
	//local lo.
	IF li:find(item) = -1 {
		li:ADD(item).
	}
	RETURN li.
}

//toglie da una lista di interi un elemento
FUNCTION SubItem {
	PARAMETER li, item.
	//local lo.
	//if not (li:find(item) = -1) {
		li:REMOVE(li:find(item)).
	//}
	RETURN li.
}

FUNCTION ViewDataLogSource {
	PARAMETER Source.
	LOCAL x TO 0.
	LOCAL y TO 0.
	
	IF Source = -1 {
		SPageTile(72,"Time         " + DSname(-1)).
	} ELSE {
		SPageTile(72,"Time         " + DSname(SensLog[0][Source])).
	}
	
	FOR S IN SensLog {
		IF y>0 {
			FOR SS IN S {
				IF x = 0 {
					PRINT ROUND(SS,1) AT (0,Y).
				} 
				IF x = Source {
					PRINT ROUND(SS,6) AT (13,Y).
				}
				SET x TO x+1.
			}		
		}
		SET y TO y+1.
		SET x TO 0.
	}
}

FUNCTION PrevColumnSource {
	PrevColumn().
	ViewDataLogSource(selcolumn).
}
	
FUNCTION NextColumnSource {
	NextColumn().
	ViewDataLogSource(selcolumn).
}
	

