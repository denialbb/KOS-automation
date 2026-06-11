@LAZYGLOBAL OFF.

RUN once "/KOSmodore/texted.ks".

LOCAL tpress TO 0.
LOCAL conta TO 0.
LOCAL symset TO 0.
LOCAL tastopreced TO 0. //quando premo un tasto diverso il contatore deve 
						//azzerarsi e l'unico modo per saperlo e memorizzarlo
//global linea to "".    
//global editline to "".   // global linea da distruggere, sarà sostituito da editline

LOCAL x TO 0.
LOCAL y TO 0.

FUNCTION setxy {
	PARAMETER xx,yy.
	SET x TO xx.
	SET y TO yy.	
}

FUNCTION resetcicleset{
SET symset TO 0.
}

FUNCTION cicleset {
	SET symset TO symset + 1.
		
	IF NPage = 41 OR NPage = 42 OR NPage = 43 {
		IF symset > 2 { SET symset TO 0. }
		IF symset = 0 {	GoPage(41). }
		IF symset = 1 {	GoPage(42).	}
		IF symset = 2 {	GoPage(43).	}
	}
	IF NPage = 52 OR NPage = 53 OR NPage = 54 {
		IF symset > 2 { SET symset TO 0. }
		IF symset = 0 {	GoPage(52). }
		IF symset = 1 {	GoPage(53).	}
		IF symset = 2 {	GoPage(54).	}
	}
	IF NPage = 33 OR NPage = 34 OR NPage = 35 {
		IF symset > 2 { SET symset TO 0. }
		IF symset = 0 {	GoPage(33). }
		IF symset = 1 {	GoPage(34).	}
		IF symset = 2 {	GoPage(35).	}
	}
	//rename
	IF NPage = 37 OR NPage = 38 OR NPage = 39 {
		IF symset > 2 { SET symset TO 0. }
		IF symset = 0 {	GoPage(37). }
		IF symset = 1 {	GoPage(38).	}
		IF symset = 2 {	GoPage(39).	}
	}
	IF NPage = 57 OR NPage = 58 OR NPage = 59 {
		IF symset > 2 { SET symset TO 0. }
		IF symset = 0 {	GoPage(57). }
		IF symset = 1 {	GoPage(58).	}
		IF symset = 2 {	GoPage(59).	}
	}
	IF NPage = 87 OR NPage = 88 OR NPage = 89 {
		IF symset > 2 { SET symset TO 0. }
		IF symset = 0 {	GoPage(87). }
		IF symset = 1 {	GoPage(88).	}
		IF symset = 2 {	GoPage(89).	}
	}
	IF NPage = 187 OR NPage = 188 OR NPage = 189 {
		IF symset > 2 { SET symset TO 0. }
		IF symset = 0 {	GoPage(187). }
		IF symset = 1 {	GoPage(188).	}
		IF symset = 2 {	GoPage(189).	}
	}
	IF NPage = 197 OR NPage = 198 OR NPage = 199 {
		IF symset > 2 { SET symset TO 0. }
		IF symset = 0 {	GoPage(197). }
		IF symset = 1 {	GoPage(198).	}
		IF symset = 2 {	GoPage(199).	}
	}
	IF NPage = 227 OR NPage = 228 OR NPage = 229 {
		IF symset > 2 { SET symset TO 0. }
		IF symset = 0 {	GoPage(227). }
		IF symset = 1 {	GoPage(228).	}
		IF symset = 2 {	GoPage(229).	}
	}
	
	IF NPage = 83 OR NPage = 84 OR NPage = 85 {
		IF symset > 2 { SET symset TO 0. }
		IF symset = 0 {	GoPage(83). }
		IF symset = 1 {	GoPage(84).	}
		IF symset = 2 {	GoPage(85).	}
	}
	IF NPage = 207 OR NPage = 208 OR NPage = 209 {
		IF symset > 2 { SET symset TO 0. }
		IF symset = 0 {	GoPage(207). }
		IF symset = 1 {	GoPage(208).	}
		IF symset = 2 {	GoPage(209).	}
	}
	IF NPage = 243 OR NPage = 244 OR NPage = 245 {
		IF symset > 2 { SET symset TO 0. }
		IF symset = 0 {	GoPage(243). }
		IF symset = 1 {	GoPage(244).	}
		IF symset = 2 {	GoPage(245).	}
	}
	IF NPage = 253 OR NPage = 254 OR NPage = 255 {
		IF symset > 2 { SET symset TO 0. }
		IF symset = 0 {	GoPage(253). }
		IF symset = 1 {	GoPage(254).	}
		IF symset = 2 {	GoPage(255).	}
	}
	//if NPage = 263 or NPage = 264 or NPage = 265 {
	//	if symset > 2 { set symset to 0. }
	//	if symset = 0 {	GoPage(263). }
	//	if symset = 1 {	GoPage(264).	}
	//	if symset = 2 {	GoPage(265).	}
	//}
	IF NPage = 237 OR NPage = 238 OR NPage = 239 OR NPage = 240{
		IF symset > 3 { SET symset TO 0. }
		IF symset = 0 {	GoPage(237). }
		IF symset = 1 {	GoPage(238).	}
		IF symset = 2 {	GoPage(239).	}
		IF symset = 3 {	GoPage(240).	}
	}
	IF NPage = 277 OR NPage = 278 OR NPage = 279 OR NPage = 280{
		IF symset > 3 { SET symset TO 0. }
		IF symset = 0 {	GoPage(277). }
		IF symset = 1 {	GoPage(278).	}
		IF symset = 2 {	GoPage(279).	}
		IF symset = 3 {	GoPage(280).	}
	}
}

FUNCTION T9bu1parE {
	PARAMETER sa, EdLine.
	
	SET EdLine TO EdLine:insert(cuX,sa).
	SET CuX TO Cux + 1.
	PRINT EdLine AT(0,Cuy+offsy).
	
	RETURN EdLine.
}

FUNCTION T9backspaceE {         //back space
	PARAMETER EdLine.
	IF CuX > 0 {
		SET CuX TO Cux - 1.
		SET EdLine TO EdLine:REMOVE(CuX, 1).
		PRINT EdLine + "  " AT(0,Cuy+offsy). //duoble space for there is also the cursor to delete
	}
	RETURN EdLine.
}

FUNCTION T9cancelE {         //canc
	PARAMETER EdLine.
	IF EdLine:length-CuX > 0 {
		SET EdLine TO EdLine:REMOVE(CuX, 1).
		PRINT EdLine + " " AT(0,Cuy+offsy).
	}
	RETURN EdLine.
}

FUNCTION T9bu3parE {
	PARAMETER sa, sb, sc, id, EdLine.
    
	IF (tpress > TIME:SECONDS - 0.6) {
		IF NOT (tastopreced = id) {SET conta TO 0.}		
	}
	ELSE {		
		SET conta TO 0.
	}
	SET tastopreced TO id.
	IF (tpress > TIME:SECONDS - 0.6) AND (conta = 3) {
		SET conta TO 0.
		SET cux TO cux - 1.
			SET EdLine TO EdLine:REMOVE(cuX, 1).
	}
	IF (tpress > TIME:SECONDS - 0.6) AND (conta = 2) {
		SET conta TO conta + 1.
		SET cux TO cux - 1.
			SET EdLine TO EdLine:REMOVE(cuX, 1).
			SET EdLine TO EdLine:insert(cuX, sc).
		SET cux TO cux + 1.
		PRINT EdLine AT(0,cuy+offsy).
	}
	IF (tpress > TIME:SECONDS - 0.6) AND (conta = 1) {
		SET conta TO conta + 1.
		SET cux TO cux - 1.
			SET EdLine TO EdLine:REMOVE(cuX, 1).
			SET EdLine TO EdLine:insert(cuX, sb).
		SET cux TO cux + 1.
		PRINT EdLine AT(0,cuy+offsy).
	}
	IF (conta = 0) {
			SET EdLine TO EdLine:insert(cuX,sa).
		SET cux TO cux + 1.
		SET conta TO conta + 1.
		PRINT EdLine AT(0,cuy+offsy).
	}
	SET tpress TO TIME:SECONDS.
	RETURN EdLine.
}

FUNCTION T9bu4parE {
	PARAMETER sa, sb, sc, sd, id, EdLine.
	
	IF (tpress > TIME:SECONDS - 0.6) {
		IF NOT (tastopreced = id) {SET conta TO 0.}		
	}
	ELSE {
		SET conta TO 0.
	}
	SET tastopreced TO id.
	IF (tpress > TIME:SECONDS - 0.6) AND (conta = 4) {
		SET conta TO 0.
		SET cux TO cux - 1.
			SET EdLine TO EdLine:REMOVE(cuX, 1).
	}
	IF (tpress > TIME:SECONDS - 0.6) AND (conta = 3) {
		SET conta TO conta + 1.
		SET cux TO cux - 1.
			SET EdLine TO EdLine:REMOVE(cuX, 1).
			SET EdLine TO EdLine:insert(cuX, sd).
		SET cux TO cux + 1.
		PRINT EdLine AT(0,cuy+offsy).
	}
	
	IF (tpress > TIME:SECONDS - 0.6) AND (conta = 2) {
		SET conta TO conta + 1.
		SET cux TO cux - 1.
			SET EdLine TO EdLine:REMOVE(cuX, 1).
			SET EdLine TO EdLine:insert(cuX, sc).
		SET cux TO cux + 1.
		PRINT EdLine AT(0,cuy+offsy).
	}
	
	IF (tpress > TIME:SECONDS - 0.6) AND (conta = 1) {
		SET conta TO conta + 1.
		SET cux TO cux - 1.
			SET EdLine TO EdLine:REMOVE(cuX, 1).
			SET EdLine TO EdLine:insert(cuX, sb).
		SET cux TO cux + 1.
		PRINT EdLine AT(0,cuy+offsy).
	}
	IF (conta = 0) {
			SET EdLine TO EdLine:insert(cuX,sa).
		SET cux TO cux + 1.
		SET conta TO conta + 1.
		PRINT EdLine AT(0,cuy+offsy).
	}
	SET tpress TO TIME:SECONDS.
	RETURN EdLine.
}

FUNCTION T9ABCe  { SET emptyprog[cuY] TO T9bu3parE("A","B","C",1, emptyprog[cuY]). }
FUNCTION T9DEFe  { SET emptyprog[cuY] TO T9bu3parE("D","E","F",2, emptyprog[cuY]). }
FUNCTION T9GHIe  { SET emptyprog[cuY] TO T9bu3parE("G","H","I",3, emptyprog[cuY]). }
FUNCTION T9JKLe  { SET emptyprog[cuY] TO T9bu3parE("J","K","L",4, emptyprog[cuY]). }
FUNCTION T9MNOe  { SET emptyprog[cuY] TO T9bu3parE("M","N","O",5, emptyprog[cuY]). }
FUNCTION T9PQRSe { SET emptyprog[cuY] TO T9bu4parE("P","Q","R","S",6, emptyprog[cuY]). }
FUNCTION T9TUVe  { SET emptyprog[cuY] TO T9bu3parE("T","U","V",7, emptyprog[cuY]). }
FUNCTION T9WXYZe { SET emptyprog[cuY] TO T9bu4parE("W","X","Y","Z",8, emptyprog[cuY]). }

FUNCTION T9ABCle  {SET emptyprog[cuY] TO T9bu3parE("a","b","c",9, emptyprog[cuY]). }
FUNCTION T9DEFle  {SET emptyprog[cuY] TO T9bu3parE("d","e","f",10, emptyprog[cuY]). }
FUNCTION T9GHIle  {SET emptyprog[cuY] TO T9bu3parE("g","h","i",11, emptyprog[cuY]). }
FUNCTION T9JKLle  {SET emptyprog[cuY] TO T9bu3parE("j","k","l",12, emptyprog[cuY]). }
FUNCTION T9MNOle  {SET emptyprog[cuY] TO T9bu3parE("m","n","o",13, emptyprog[cuY]). }
FUNCTION T9PQRSle {SET emptyprog[cuY] TO T9bu4parE("p","q","r","s",14, emptyprog[cuY]). }
FUNCTION T9TUVle  {SET emptyprog[cuY] TO T9bu3parE("t","u","v",15, emptyprog[cuY]). }
FUNCTION T9WXYZle {SET emptyprog[cuY] TO T9bu4parE("w","x","y","z",16, emptyprog[cuY]). }

FUNCTION T9strE {
PARAMETER stri.
	SET emptyprog[CuY] TO T9bu1parE(stri, emptyprog[Cuy]).
	SET cux TO cux + stri:length-1.
}

FUNCTION T9strCurE {
PARAMETER stri,offset.
	SET emptyprog[CuY] TO T9bu1parE(stri, emptyprog[Cuy]).
	SET cux TO cux + offset-1.
}

FUNCTION T9spaceE {
	SET emptyprog[CuY] TO T9bu1parE(" ", emptyprog[Cuy]).
}

FUNCTION T9CancE {
	
	IF cuX < emptyprog[cuY]:length {	
		SET emptyprog[cuY] TO T9cancelE(emptyprog[cuY]).
	} ELSE {
		IF cuy < emptyprog:length-1 {
			SET emptyprog[cuY] TO emptyprog[cuY] + emptyprog[cuY+1].
			emptyprog:REMOVE(cuY+1).
			ClsNoCur().
			LOCAL cou TO 0.
		
			FOR lin IN emptyprog {
				PRINT lin AT(0,cou).
				SET cou TO cou + 1.
			}
		}
	}
}


FUNCTION T9backsE {
	IF cuX > 0 {	
		SET emptyprog[cuY] TO T9backspaceE(emptyprog[cuY]).
	} ELSE {
		IF cuy > 0 {
			SET cux TO emptyprog[cuY-1]:length.
			SET emptyprog[cuY-1] TO emptyprog[cuY-1] + emptyprog[cuY].
			emptyprog:REMOVE(cuY).
			SET cuy TO cuy -1.
			ClsNoCur().
			LOCAL cou TO 0.
		
			FOR lin IN emptyprog {
				PRINT lin AT(0,cou).
				SET cou TO cou + 1.
			}
		}
	}
}

FUNCTION InsertLineKST {
	
	LOCAL stri TO emptyprog[cuy].
	SET emptyprog[cuy] TO stri:substring(0,cux).
		
	emptyprog:insert(cuy+1,stri:REMOVE(0,cux)).
	SET cux TO 0.
	SET cuy TO cuy +1.
	
	ClsNoCur().
		LOCAL cou TO 0.
		
		FOR lin IN emptyprog {
			PRINT lin AT(0,cou).
			SET cou TO cou + 1.
		}	
}

FUNCTION T91e {SET emptyprog[cuY] TO T9bu1parE("1", emptyprog[cuY]).}
FUNCTION T92e {SET emptyprog[cuY] TO T9bu1parE("2", emptyprog[cuY]).}
FUNCTION T93e {SET emptyprog[cuY] TO T9bu1parE("3", emptyprog[cuY]).}
FUNCTION T94e {SET emptyprog[cuY] TO T9bu1parE("4", emptyprog[cuY]).}
FUNCTION T95e {SET emptyprog[cuY] TO T9bu1parE("5", emptyprog[cuY]).}
FUNCTION T96e {SET emptyprog[cuY] TO T9bu1parE("6", emptyprog[cuY]).}
FUNCTION T97e {SET emptyprog[cuY] TO T9bu1parE("7", emptyprog[cuY]).}
FUNCTION T98e {SET emptyprog[cuY] TO T9bu1parE("8", emptyprog[cuY]).}
FUNCTION T99e {SET emptyprog[cuY] TO T9bu1parE("9", emptyprog[cuY]).}
FUNCTION T90e   {SET emptyprog[cuY] TO T9bu1parE("0", emptyprog[cuY]).}
FUNCTION T9dotE {SET emptyprog[cuY] TO T9bu1parE(".", emptyprog[cuY]).}
FUNCTION T9minusE {SET emptyprog[cuY] TO T9bu1parE("-", emptyprog[cuY]).}

FUNCTION T9123e { SET emptyprog[cuY] TO T9bu3parE("1","2","3",17, emptyprog[cuY]). }
FUNCTION T9456e { SET emptyprog[cuY] TO T9bu3parE("4","5","6",18, emptyprog[cuY]). }
FUNCTION T9789e { SET emptyprog[cuY] TO T9bu3parE("7","8","9",19, emptyprog[cuY]). }
FUNCTION T90signsE { SET emptyprog[cuY] TO T9bu3parE("0","+","-",20, emptyprog[cuY]). }
FUNCTION parentesiE { SET emptyprog[cuY] TO T9bu4parE("(",")","=","#",21, emptyprog[cuY]). }

//forbidden file name characters

// < (less than)
// > (greater than)
// : (colon - sometimes works, but is actually NTFS Alternate Data Streams)
// " (double quote)
// / (forward slash)
// \ (backslash)
// | (vertical bar or pipe)
// ? (question mark)
// * (asterisk)

FUNCTION punct1e { SET emptyprog[cuY] TO T9bu4parE("-","/",":","'",22, emptyprog[cuY]). }
FUNCTION punct2e { SET emptyprog[cuY] TO T9bu4parE(".",",","!","?",23, emptyprog[cuY]).}

// filename alloweD
FUNCTION punct3e { SET emptyprog[cuY] TO T9bu4parE("-","+","&",".",24, emptyprog[cuY]).}
FUNCTION punct4e { SET emptyprog[cuY] TO T9bu4parE("""","*","^","$",25, emptyprog[cuY]). }
FUNCTION punct5e { SET emptyprog[cuY] TO T9bu4parE("<",">","@","/",26, emptyprog[cuY]). }