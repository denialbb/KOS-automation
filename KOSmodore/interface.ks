@LAZYGLOBAL OFF.

RUN once "/KOSmodore/globals.ks".
RUN once "/KOSmodore/texted.ks".

 
GLOBAL lind TO 0.           // selezione della lista di cose
GLOBAL Npage TO 0.
GLOBAL li TO LIST().        // lista per il menu scorrevole
GLOBAL selcolumn TO -1.     // datasource selezionata
                            // -1: non ci sono sorgenti
							// 1: prima sorgente impostata
							// 2: seconda sorgente...
GLOBAL maxcolumn TO 0.      // numero di colonne disponibili

//associates a back page to any page 
GLOBAL PageBacks TO LIST(
	LIST(  0,   -1),
	LIST(  1,   -1), 
	LIST( 20,    1),
	LIST( 30,    1),
	LIST( 31,   30),
	LIST( 32,   30),   
	LIST( 33,   30),
	LIST( 34,   30),
	LIST( 35,   30),
	LIST( 40,    1),
	LIST( 41,   40),
	LIST( 42,   40),
	LIST( 43,   40),
	LIST( 50,    1),
	LIST( 51,   50),
	LIST( 52,   50),
	LIST( 53,   50),
	LIST( 54,   50),
	LIST( 55,   50),
	LIST( 56,   50),
	LIST( 70,    1),
	LIST( 71,   70),
	LIST( 72,   70),
	LIST( 75,   70),
	LIST( 76,   75),
	LIST( 77,   75),
	LIST( 83,   70),
	LIST( 84,   70),
	LIST( 85,   70),
	LIST(100,    1),
	LIST(101,  100),
	LIST(102,  100),
	LIST(103,  100),
	LIST(200,    1),
	LIST(201,  200), 
	LIST(205,  200), 
	LIST(210,  200),
	LIST(220,  200),
	LIST(221,  200),
	LIST(237,  220),
	LIST(238,  220),
	LIST(239,  220),
	LIST(240,  220),
	LIST(277,  218),
	LIST(278,  218),
	LIST(279,  218),
	LIST(280,  218)
).


// returns the back page
FUNCTION PageBack {
	
	FOR s IN PageBacks {
		IF s[0] = NPage {
			RETURN s[1].
		}
	}
}

//global li to list().                           // lista per il menu scorrevole

//dice al sistema qual è la pagina corrente e prepara lo schermo spingendo il cursore lontano

// PAGES 
//  0         splash (dalla release 1 durerà un secondo e i tasti permetteranno easter egg e funzioni nascoste - per esempio visualizzare in numero di pagina. dopo quel secondo si passerà alla pagina 1)

//  1         main page

//  8         Test page

//  20        Rover page

//  30        Track page
//  31        selezione e carica track da file
//  32        track view
//  33        save track 0
//  34        save track 1
//  35        save track 2
  //  37        reaname track 0
  //  38        reaname track 1
  //  39        reaname track 2

//  -40        Logbook 
//  -41        Logbook write 1
//  -42        Logbook write 2
//  -43        Logbook write 3

//  50        Destination
//  51        selezione e carica destinazione da file
//  52        save destination 0
//  53        save destination 1
//  54        save destination 2
//  55        type d. latitude
//  56        type d. longitude
  //  57        reaname dest 0
  //  58        reaname dest 1
  //  59        reaname dest 2

//  70        datalog page
//  71        select e carica datalog da file
//  72        data log view
//  74        ask confirmation before changing the source list
//  75        seleziona data sources
//  76        add data source da lista
//  77        del data source da lista
//  83        save datalog 0
//  84        save datalog 1
//  85        save datalog 2
  //  87        reaname datalog 0
  //  88        reaname datalog 1
  //  89        reaname datalog 2

//  100       Settings
//  101       type marker thickness
//  102       type Data sampling time interval
//  103       type Track sampling time interval
  //  187        reaname ks prog 0
  //  188        reaname ks prog 1
  //  189        reaname ks prog 2
  //  197        reaname sks prog 0
  //  198        reaname sks prog 1
  //  199        reaname sks prog 2
//  200       programs
//  201       select and run kerboscript from file
  //  205       select and load serializedkerboscript from file
  //  207       export sks to ks file 0 (ask name)
  //  208       export sks to ks file 1 (ask name)
  //  209       export sks to ks file 2 (ask name)
//  210       running program
//  211       ended program
//  218       View sks prog
//  220       view basic prog
//  221       select and load basic prog from file
  //  227        reaname basic prog 0
  //  228        reaname basic prog 1
  //  229        reaname basic prog 2
//  230       running basic program
//  237       edit basic program 0
//  238       edit basic program 1
//  239       edit basic program 2
//  240       edit basic program 3
//  243       save basic program 0
//  244       save basic program 1
//  245       save basic program 2
  //  253       save sks program 0
  //  254       save sks program 1
  //  255       save sks program 2

//  277       edit sks program 0
//  278       edit sks program 1
//  279       edit sks program 2
//  280       edit sks program 3

FUNCTION EscSaveFile {
	IF NPage = 52 OR NPage = 53 OR NPage = 54 {
		SET offsy TO 0.
		SET cuY TO 0.
		GoPage(50).
	}
	
	 // file rename
	IF NPage = 37 OR NPage = 38 OR NPage = 39 {
		SET offsy TO 0.
		SET cuY TO 0.
		GoPage(31).
	}
	IF NPage = 57 OR NPage = 58 OR NPage = 59 {
		SET offsy TO 0.
		SET cuY TO 0.
		GoPage(51).
	}
	IF NPage = 87 OR NPage = 88 OR NPage = 89 {
		SET offsy TO 0.
		SET cuY TO 0.
		GoPage(71).
	}
	IF NPage = 187 OR NPage = 188 OR NPage = 189 {
		SET offsy TO 0.
		SET cuY TO 0.
		GoPage(201).
	}
	IF NPage = 197 OR NPage = 198 OR NPage = 199 {
		SET offsy TO 0.
		SET cuY TO 0.
		GoPage(205).
	}
	IF NPage = 227 OR NPage = 228 OR NPage = 229 {
		SET offsy TO 0.
		SET cuY TO 0.
		GoPage(221).
	}
	
	IF NPage = 33 OR NPage = 34 OR NPage = 35 {
		SET offsy TO 0.
		SET cuY TO 0.
		Gopage(30).
	}
	IF NPage = 83 OR NPage = 84 OR NPage = 85 {
		SET offsy TO 0.
		SET cuY TO 0.
		Gopage(70).
	}
	IF NPage = 207 OR NPage = 208 OR NPage = 209 {
		SET emptyprog TO STextAux:COPY.
		STextAux:CLEAR.
		SET offsy TO 0.
		SET cuY TO 0.
		Gopage(218).
	}
	IF NPage = 243 OR NPage = 244 OR NPage = 245 {
		SET emptyprog TO STextAux:COPY.
		STextAux:CLEAR.
		SET offsy TO 0.
		SET cuY TO 0.
		Gopage(220).
	}
	IF NPage = 253 OR NPage = 254 OR NPage = 255 {
		SET emptyprog TO STextAux:COPY.
		STextAux:CLEAR.
		SET offsy TO 0.
		SET cuY TO 0.
		Gopage(218).
	}
}

FUNCTION TypeRealNumAccept {    
	IF Npage = 56 { //tipico caso in cui l'ordine degli if conta
		SET INPstr2 TO emptyprog[0].   
		GPSPOS:CLEAR.
		GPSPOS:ADD(INPstr1:tonumber(-9999)). //se non è un numero valido 	restituisce -9999
		GPSPOS:ADD(INPstr2:tonumber(-9999)).		
		GoPage(50).
    }
	IF Npage = 55 {
		SET INPstr1 TO emptyprog[0].
		cuBlank().  //Blanken the cursor
		TypeRealNum(56,"Type longitude: ",2, FALSE).
		
	}

	IF Npage = 101 {
		SET INPstr1 TO emptyprog[0].
		SET SettingsL[0] TO INPstr1:tonumber(-9999).
		GoPage(100).
	}
	IF Npage = 102 {
		SET INPstr1 TO emptyprog[0].
		SET SettingsL[1] TO INPstr1:tonumber(-9999).
		GoPage(100).
	}
	IF Npage = 103 {
		SET INPstr1 TO emptyprog[0].
		SET SettingsL[2] TO INPstr1:tonumber(-9999).
		GoPage(100).
	}
}



// cancella la pagina facendo sparire il cursore
FUNCTION ClsNoCur {
	CLEARSCREEN.
	FROM {               //porta il cursore dove non lo vede nessuno
		LOCAL xx IS 1.
	}
	UNTIL xx = 18 STEP {
		SET xx TO xx+1.
	} 
	DO {
		PRINT " ".
	}
}

FUNCTION SPage{
	PARAMETER p.
	ClsNoCur().
	PRINT "P" + p AT(SettingsL[3]-4,16).
		SET Npage TO p.
}


FUNCTION SPageTile{
	PARAMETER p,title.
	CLEARSCREEN.
	  PRINT "[#DFDFDF]" + title.
	FROM {               //porta il cursore dove non lo vede nessuno
		LOCAL xx IS 1.
		}
	UNTIL xx = 17 STEP {
		SET xx TO xx+1.
	} 
	DO {
		PRINT " ".
	}
	PRINT "P" + p AT(SettingsL[3]-4,16).
	SET Npage TO p.
}

FUNCTION SPageNoClear{
	PARAMETER p.
	PRINT "P" + p AT(SettingsL[3]-4,16).
	SET Npage TO p.
}


FUNCTION ruler {
	FROM {
		LOCAL xx IS 1.
		}
	UNTIL xx = 17 STEP {
		SET xx TO xx+1.
	} 
	DO {
		PRINT "- " + xx AT (0,xx).
	}
}

FUNCTION listafile {   //stampa una lista selezionalible di file
	PARAMETER li.
	LOCAL cou TO 0.
    LOCAL fileline TO "".
	IF lind > li:length-1 {
		SET lind TO 0.
	}
	IF lind < 0 {
		SET lind TO li:length-1.
	}
	
	FOR bod IN li {
		SET fileline TO bod:NAME + " (" + bod:size+" B)          ".
		IF cou = lind {
			PRINT " > [#FFFFFF]" + fileline AT(0,lind).
		} ELSE {
			PRINT "  " + fileline AT(0,cou).
		}
		SET cou TO cou + 1.
	}
	
	 
}

// prints the cursor and changes its position in memory. it is the cursor of the 
// text editors
FUNCTION SetEditCursor {
	PARAMETER li.
	LOCAL cou TO 0.
	FOR bod IN li {
		//PRINT "#" AT(bod:length,cou). // when it will scroll, cut it
		SET cou TO cou + 1.
	}
	IF lind > cou-1 {SET lind TO cou-1.}
	IF lind < 0 {SET lind TO 0.}
	PRINT "_" AT(li[lind]:length,lind). 
	setxy(emptyprog[lind]:length,lind).	
}

//setta il cursore per scrivere riscrivere tutta la riga (x=0)
FUNCTION SetEditCursor0 {
	PARAMETER li.
	LOCAL cou TO 0.
	
	FOR bod IN li {
		//PRINT "#" AT(bod:length,cou). // when it will scroll, cut it
		SET cou TO cou + 1.
	}
	
	IF lind > cou-1 {
		SET lind TO cou-1.
	}
	IF lind < 0 {
		SET lind TO 0.
	}
	//PRINT "#" AT(li[lind]:length + linea:length, lind). // when it will scroll, cut it
	PRINT "_" AT(li[lind]:length,lind). 
	
	setxy(0,lind).
	//print lind at(0,8). 
	
}



FUNCTION listastr {   //stampa una lista selezionalible di stringhe
	PARAMETER lis.
	//global li to LIST().
	LOCAL cou TO 0.
 
	FOR bod IN lis {
		PRINT "  " + bod AT(0,cou).
		SET cou TO cou + 1.
	}
	IF lind > cou-1 {
		SET lind TO 0.
	}
	IF lind < 0 {
		SET lind TO cou-1.
	}
	PRINT ">" AT(1,lind). 
}

FUNCTION ListaFileDown{
	//if (Npage = 10) or (Npage = 11) or (Npage = 51) {
		SET lind TO lind +1.
		listafile(li).
}

FUNCTION ListaFileUp{
	//if (Npage = 10 ) or (Npage = 11) or (Npage = 51) {
		SET lind TO lind -1.
		listafile(li).
}

//function EditLineDown{
//	//if (Npage = 10) or (Npage = 11) or (Npage = 51) {
//		//set emptyprog[lind] to linea.
//		PRINT " " AT(emptyprog[lind]:length, lind).
//		set lind to lind +1.
//		SetEditCursor(li).
//		
//		set linea to "".
//}

//function EditLineUp{
//	//if (Npage = 10 ) or (Npage = 11) or (Npage = 51) {
//		//set emptyprog[lind] to linea.
//		PRINT " " AT(emptyprog[lind]:length, lind).
//		set lind to lind -1.
//		SetEditCursor(li).
//		
//		set linea to "".	
//}

//save the current line. you must do it, when you change line before saving the file, before running it..
//function EditRecordLine{
//	set emptyprog[lind] to linea.
//}

FUNCTION ListaStrDown{
	//if (Npage = 10) or (Npage = 11) or (Npage = 51) {
		PARAMETER li.
		SET lind TO lind +1.
		listaStr(li).
}

FUNCTION ListaStrUp{
	//if (Npage = 10 ) or (Npage = 11) or (Npage = 51) {
		PARAMETER li.
		SET lind TO lind -1.
		listaStr(li).
}


// sistema deprecato: fare una funzionae per ogni if
FUNCTION EnterListselect{
	
	
	IF Npage = 51 {
		SET GPSPOS TO READJSON("/KOSmodore/positions/" + li[lind]).
		GoPage(50).
	}
	IF Npage = 31 {
		SET LoadedTrack TO READJSON("/KOSmodore/tracks/" + li[lind]).
		Gopage(30).
	}
	IF Npage = 71 {
		SET SensLog TO READJSON("/KOSmodore/sampling/" + li[lind]).
		
		
		//reimposta la lista risorse in accordo col file caricato
		LOCAL co TO 0.
		DataSourcesAdded:CLEAR.
		FOR ds IN SensLog[0] {
			//print DSname(ds) + " (" + ds + ")" AT(0,co).
			IF co > 0 {
				DataSourcesAdded:ADD(ds).
				PRINT DSname(ds) AT(0,co+5).
			}
			SET co TO co + 1.
		}
		
		GoPage(70).
	}
	IF Npage = 76 {
		SET DataSourcesAdded TO AddIfNoItem(DataSourcesAdded,DataSources[lind]).
		GoPage(75).
	}
	IF Npage = 77 {
		SET DataSourcesAdded TO SubItem(DataSourcesAdded,DataSourcesAdded[lind]).
		GoPage(75).
	}
	IF Npage = 201 {
		GoPage(210).
		RunKS(li[lind]).
		GoPage(211).
		
	}
	IF Npage = 205 {
		SET emptyprog TO readjson("/KOSmodore/sks/" + li[lind]).
		GoPage(218).
		
	}
	IF Npage = 221 {
		SET emptyprog TO readjson("/KOSmodore/ksp-basic/" + li[lind]).
		GoPage(220).
		
	}
}

FUNCTION PrevColumn {
	IF selcolumn > 1 {
		SET selcolumn TO selcolumn - 1.
		ViewDataLogSource(selcolumn).
	}
}
	
FUNCTION NextColumn {
	IF (selcolumn < maxcolumn) AND NOT(selcolumn = -1) {
		SET selcolumn TO selcolumn + 1.
		ViewDataLogSource(selcolumn).
	}
}

FUNCTION GoPageResettingCur {
	PARAMETER p.
	SET cuy TO 0.
	SET cux TO 0.
	SET offsy TO 0.
	GoPage(p).
}

