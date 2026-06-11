@LAZYGLOBAL OFF.

RUN once "/KOSmodore/rover.ks".

// per il LOCATE x,y e il PRINT
LOCAL lx TO 0.
LOCAL ly TO 0.

//line execution counter (address)
GLOBAL co TO -1. //so it starts from 0. tsk!

//cumulative counter (to create the .ks file names)
LOCAL cco TO -1. //so it starts from 0. tsk!

//line numbers
LOCAL linumbers TO LIST(). 

LOCAL txtcolor TO "".

GLOBAL stepmode TO FALSE.

//"back to basic" case
GLOBAL backtobascase TO 0.


//debug mode. window on the right if true
GLOBAL debugbas TO FALSE.
//all the outputs will be moved right in debug mode for the window
GLOBAL debugoffset TO 0. 

//for the debug windows refreshing time
GLOBAL debugbasstart TO 0.

GLOBAL exodos TO FALSE.

//for the W command (backtobascase=2)
GLOBAL basWStart TO 0.
GLOBAL basWTime TO 0.

GLOBAL BASICrun TO FALSE.


FUNCTION basAbort {
	//set exodos to true.
	SET BASICrun TO FALSE.
	resetbasicstate().
	
}

FUNCTION steprun {
	SET stepmode TO TRUE.
    IF (npage <> 231) {
		spage(231).
		IF debugbas {debugwinframe().}
	}
	gopage(231).
}

//function refreshdebug{
//	parameter x.

//}


FUNCTION debugwinframe{
FROM {LOCAL ux IS 0.}
		UNTIL ux = 17 STEP {SET ux TO ux+1.}
		DO { PRINT "             |" AT(0,ux).}
		
		PRINT "T: ..." AT(0,0).                 
		PRINT "Line: " AT(0,1).           
		PRINT "Run:  " AT(0,2).     
		PRINT "Case: " AT(0,3).
		PRINT "Exit: " AT(0,4).     

}

FUNCTION toggledebug{
	PARAMETER ix.
	
	SET debugbas TO NOT debugbas.
	
	SET mylabels:currentmonitor TO ix.
	
	IF debugbas {
		mylabels:setlabel(0, "  Debug([#00FF00]on[#FFFFFF]) ").
		SET debugoffset TO 15.
		clsnoCur().
		debugwinframe().
		
	}
	
	IF NOT debugbas {
		mylabels:setlabel(0, " Debug([#FFA050]off[#FFFFFF]) ").
		SET debugoffset TO 0.
		clsnoCur().
	}
	
	IF Npage = 220{
		//ClsNoCur().
		LOCAL cou TO 0.
		
		FOR lin IN emptyprog {
			PRINT lin AT(0 + debugoffset, cou).
			SET cou TO cou + 1.
		}
	}
	
	
	
		
	//refreshdebug(ix).
	
	
}

FUNCTION debugwin{
	LOCAL ti TO ROUND(debugbasstart - (FLOOR(debugbasstart/1000)*1000), 1).
	
	PRINT ti + "  " AT(6,0).                 
	PRINT co + "  " AT(6,1).           
	PRINT BASICrun + "  " AT(6,2).     
	PRINT backtobascase + "  " AT(6,3).
	PRINT exodos + "  " AT(6,4).       
	
	//FROM {local x is 0.}
	//	UNTIL x = 17 STEP {set x to x+1.}
	//	DO { print "|" AT(debugoffset-2,x).}
	
}

FUNCTION resetbasicstate {
	
	IF Npage = 231 {
		Spage(231).
		IF debugbas {debugwinframe().}
	}
	
	SET lx TO 0.
	SET ly TO 0.
	SET txtcolor TO "".
	SET	co TO -1.
	SET	cco TO -1.
    linumbers:CLEAR.
	SET exodos TO FALSE.
	SET basicrun TO FALSE.
}

FUNCTION reclinumbers {
	PARAMETER progr.
	LOCAL cou TO 0.
	LOCAL sepi TO 0.
	LOCAL linu TO 0.	
	
		//clearscreen.
		FOR l IN progr {
			SET sepi TO l:FIND(" ").
	        IF sepi > -1 {
				SET linu TO l:REMOVE(sepi,(l:length-sepi)):tonumber(-1).
				IF linu > -1 {
					linumbers:ADD(LIST()).
					linumbers[linumbers:length-1]:ADD(linu).
					linumbers[linumbers:length-1]:ADD(cou).
				}
				//print "-" + linu + "-" AT(0,cou).
			}
			SET cou TO cou + 1.
		}
	//print linumbers.
	
}

FUNCTION removelinumber {
	PARAMETER li.
	LOCAL sepi TO li:FIND(" ").
	LOCAL linu TO 0.
	IF sepi > -1 {
		SET linu TO li:REMOVE(sepi,(li:length-sepi)):tonumber(-1).
		IF linu > -1 {
			SET li TO li:REMOVE(0,sepi+1).
		}
	}
	RETURN li.
}

FUNCTION printgotoid {
	CLEARSCREEN.
	PRINT linumbers.
	PRINT posline(14).
}

//return the position of the numbered line
FUNCTION posline {
	
	PARAMETER nu.
	//local co to 0.
	LOCAL re TO -1.
	FOR s IN linumbers {
	 //print "l:" + linumbers:length AT (14,co+6).
	 //print "co:" + co AT (14,co+7).
	 //print s[0] at (14,co+8).
	 //set co to co + 1.
	//print "s di 0:" + s[0] + ".".
	//print "s di 1:" + s[1] + ".".
		IF s[0] = nu {
			
			SET re TO s[1].
			BREAK.
		}// else {
			//set re to -1.
	//	}
	}
	
	RETURN re.
}



FUNCTION coCLS {
	PARAMETER li.
	IF li:trim:toupper = "CLS" {
		IF Npage = 230{ClsNoCur().}
		SET lx TO 0.
		SET ly TO 0.
	}
}

FUNCTION coPRINT {
	PARAMETER li.
	LOCAL l TO li:trim:toupper.
	LOCAL lxx TO 0.
	LOCAL uniq TO 0.
	LOCAL sepi TO l:FIND(" ").
	IF sepi > -1 {
		
		IF (l:REMOVE(sepi,(l:length-sepi)) = "PRINT") OR 
		   (l:REMOVE(sepi,(l:length-sepi)) = "?") {
			//misteriosamente se uso sempre lo stesso nome per il file runpath
			//esegue sempre il primo che ha eseguito. per cui metto nomi diversi 	
			IF Npage = 230 OR Npage = 231{
				SET lxx TO (lx + debugoffset).
				SET uniq TO random().
				//print "lxx:"+lxx+" do:"+debugoffset AT (44,ly).
				LOG "PRINT " + txtcolor + l:REMOVE(0,sepi+1) +
				" at(" + (lxx*1) + "," + ly +")." TO // string to number.. tsk!
				"/KOSmodore/temp/print" + uniq + ".ks".
				RUNPATH("/KOSmodore/temp/print" + uniq + ".ks").
				DELETEPATH("/KOSmodore/temp/print" + uniq + ".ks").
			}
			SET lx TO 0.
			SET ly TO ly + 1.
		}
	}
}

FUNCTION coWAIT {
	PARAMETER li.
	LOCAL l TO li:trim:toupper.
	LOCAL uniq TO 0.
	LOCAL sepi TO l:FIND(" ").
	IF sepi > -1 {
		
		IF (l:REMOVE(sepi,(l:length-sepi)) = "WAIT"){
			//misteriosamente se uso sempre lo stesso nome per il file runpath
			//esegue sempre il primo che ha eseguito. per cui metto nomi diversi 	
			SET uniq TO random().
			LOG "WAIT " + l:REMOVE(0,sepi+1) + "."
			TO "/KOSmodore/temp/wait" + uniq + ".ks".
			RUNPATH("/KOSmodore/temp/wait" + uniq + ".ks").
			DELETEPATH("/KOSmodore/temp/wait" + uniq + ".ks").
		}
	}
}

FUNCTION coCOLOR {
	PARAMETER li.
	LOCAL l TO li:trim:toupper.
	LOCAL color TO "".
	LOCAL sepi TO l:FIND(" ").
	
	IF l = "CO" {SET Txtcolor TO "".}
	ELSE
		IF sepi > -1 {
			IF (l:REMOVE(sepi,(l:length-sepi)) = "CO"){
				SET color TO l:REMOVE(0,sepi+1).
			
				IF color = "R" {SET Txtcolor TO """[#FF0000]""+".}
				IF color = "G" {SET Txtcolor TO """[#00FF00]""+".}
				IF color = "B" {SET Txtcolor TO """[#0000FF]""+".}
				IF color = "Y" {SET Txtcolor TO """[#FFFF00]""+".}
				IF color = "C" {SET Txtcolor TO """[#FFFF00]""+".}
				IF color = "W" {SET Txtcolor TO """[#FFFFFF]""+".}
				IF color = "O" {SET Txtcolor TO """[#FF8000]""+".}
				IF color = "P" {SET Txtcolor TO """[#FF8080]""+".}
				IF color = "M" {SET Txtcolor TO """[#FF00FF]""+".}
				IF color = "V" {SET Txtcolor TO """[#9933FF]""+".}
				IF color = "BLACK" {SET Txtcolor TO """[#9933FF]""+".}
				IF color = "GRAY" {SET Txtcolor TO """[#909090]""+".}
				IF color = "BROWN" {SET Txtcolor TO """[#663300]""+".}		
			}
		}
}

FUNCTION coksline {
	PARAMETER li.
	LOCAL l TO li:trim.
	
	IF l:length >0 {
		IF l:SUBSTRING(0,1) = "#"{

			LOG l:REMOVE(0,1):trim TO "/KOSmodore/temp/coKSLine" + cco + ".ks".
			RUNPATH("/KOSmodore/temp/coKSLine" + cco + ".ks").
			DELETEPATH("/KOSmodore/temp/coKSLine" + cco + ".ks").
		}
	}
}

FUNCTION coSD {
	PARAMETER li.
	LOCAL l TO li:trim:toupper.
	
	LOCAL sepi TO l:FIND(" ").
	//local lat to 0.
	//local lon to 0.
	LOCAL wholeline TO li.
	LOCAL command TO "".
	LOCAL parameters TO "".
	LOCAL par1 TO "".
	LOCAL par2 TO "".
	
	IF sepi > -1 {
		SET command TO l:REMOVE(sepi,(l:length-sepi)).
		IF command = "SD" {
			SET l TO wholeline.
			SET parameters TO l:REMOVE(0,sepi+1).
			SET l TO parameters.
			SET sepi TO l:FIND(" ").
			SET par1 TO l:substring(0,sepi).
			SET l TO parameters.
			SET par2 TO l:REMOVE(0,sepi+1).
		   
		    GPSPOS:CLEAR.
			GPSPOS:ADD(par1:tonumber(-9999)).
			GPSPOS:ADD(par2:tonumber(-9999)).
		}
	}
}

FUNCTION coLOCATE {
	PARAMETER li.
	LOCAL l TO li:trim:toupper.
	
	LOCAL sepi TO l:FIND(" ").
	LOCAL wholeline TO li.
	LOCAL command TO "".
	LOCAL parameters TO "".
	LOCAL par1 TO "".
	LOCAL par2 TO "".
	
	IF sepi > -1 {
		SET command TO l:REMOVE(sepi,(l:length-sepi)).
		IF command = "LOCATE" {
			SET l TO wholeline.
			SET parameters TO l:REMOVE(0,sepi+1).
			SET l TO parameters.
			SET sepi TO l:FIND(" ").
			SET par1 TO l:substring(0,sepi).
			SET l TO parameters.
			SET par2 TO l:REMOVE(0,sepi+1).
		   	    
			SET lx TO par1:tonumber(-1).
			SET ly TO par2:tonumber(-1).
			
			//print "p1:" + par1.
			//print "p2:" + par2.
		}
	}
}

FUNCTION coSDF {
	PARAMETER li.
	LOCAL l TO li:trim:toupper.
	
	LOCAL sepi TO l:FIND(" ").
	LOCAL wholeline TO li.
	LOCAL command TO "".
	LOCAL param TO "".
	
	IF sepi > -1 {
		SET command TO l:REMOVE(sepi,(l:length-sepi)).
		IF command = "SDF" {
			SET l TO wholeline.
			SET param TO l:REMOVE(0,sepi+1).   
		    SET GPSPOS TO READJSON("/KOSmodore/positions/" + param + ".pos").
		}
	}
}

FUNCTION isGOTO {  //is a goto?
	PARAMETER li.
	LOCAL l TO li:trim:toupper.
	
	LOCAL sepi TO l:FIND(" ").
	LOCAL itis TO FALSE.
	IF sepi > -1 {
		IF (l:REMOVE(sepi,(l:length-sepi)) = "GOTO") {
			SET itis TO TRUE.
		}
	}
	RETURN itis.
}

FUNCTION coGOTO {
	PARAMETER li.
	LOCAL l TO li:trim:toupper.
	
	LOCAL sepi TO l:FIND(" ").
	IF sepi > -1 {
		
		IF (l:REMOVE(sepi,(l:length-sepi)) = "GOTO") {
			LOCAL numto TO l:REMOVE(0,sepi+1):tonumber(-1).
			//print "l:" + co  AT(8,11).
			//print "g:" + numto AT(8,12).
			//print "p:" + (posline(numto))-1 AT(8,13).
			SET co TO (posline(numto)-1).  //goto seeks the previous line
		}
	}
}

FUNCTION coShipSys {
	PARAMETER li.
	IF li:trim:toupper = "AG1" {toggle AG1.}
	IF li:trim:toupper = "AG2" {toggle AG2.}
	IF li:trim:toupper = "AG3" {toggle AG3.}
	IF li:trim:toupper = "AG4" {toggle AG4.}
	IF li:trim:toupper = "AG5" {toggle AG5.}
	IF li:trim:toupper = "AG6" {toggle AG6.}
	IF li:trim:toupper = "AG7" {toggle AG7.}
	IF li:trim:toupper = "AG8" {toggle AG8.}
	IF li:trim:toupper = "AG9" {toggle AG9.}
	IF li:trim:toupper = "AG10" {toggle AG10.}
	
	IF li:trim:toupper = "GEAR" {toggle GEAR.}
	
	
}

FUNCTION coRD {
	PARAMETER li.
	IF li:trim:toupper = "RD" {
		goroverpos().
	}
}

FUNCTION coWR {
	PARAMETER li.
	IF li:trim:toupper = "WR" {
		SET BASICrun TO FALSE.
		SET backtobascase TO 1.
	}
}

FUNCTION coW {
	PARAMETER li.
	IF li:trim:toupper = "W" {
		SET basWStart TO TIME:SECONDS.
		SET basWtime TO 1.
		SET BASICrun TO FALSE.
		SET backtobascase TO 2.
	}
}


FUNCTION coEND {
	PARAMETER li.
	LOCAL exo TO FALSE.
	IF li:trim:toupper = "END" {
		SET exo TO TRUE.
	}
	RETURN exo.
}



FUNCTION RunBASICline {
	LOCAL LiNoN TO "". //line without number
	
	IF co = -1 {reclinumbers(emptyprog).}
	
	IF (NOT (emptyprog:length > co+1)) {SET exodos TO TRUE.}
	
	IF (exodos=FALSE) {
		SET co TO co + 1.
		SET cco TO cco + 1.
		SET LiNoN TO removelinumber(emptyprog[co]).
		
		//commands
		coCLS(LiNoN).
		coPRINT(LiNoN).  
		coWAIT(LiNoN).
		coLOCATE(LiNoN).
		coSD(LiNoN).
		coSDF(LiNoN).
		coShipSys(LiNoN).
		coRD(LiNoN).
        //coW(LiNoN).
		coWR(LiNoN).
		coKSLine(LiNoN).	
		coCOLOR(LiNoN).			
		coGOTO(LiNoN).
		
		IF coEND(LiNoN) {SET exodos TO TRUE.}
		
	} ELSE {
		SET co TO -1.
		SET cco TO -1.
		SET exodos TO FALSE.
		SET BASICrun TO FALSE.
		resetbasicstate().
	}
	//print "co:" + co + "(" + emptyprog:length + ")" AT(11,11).
	
	//set BASICrun to false.
	IF stepmode {SET BASICrun TO FALSE.}
	
	
	IF exodos {
		SET BASICrun TO FALSE.
		resetbasicstate().
	
	}
}
