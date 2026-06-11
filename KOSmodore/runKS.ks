@LAZYGLOBAL OFF.

GLOBAL emptyprog TO LIST(). //it may be called "sourceprog". it contains the program as it IS readed FROM file
GLOBAL preprocprog TO LIST(). //it contains the program withoyt the comments and the labels. informations about the labels for the GOTO command are stored in the GOTOInf list
GLOBAL GOTOInf TO LIST(LIST()). //it associate the position of GOTO line to the position where to jump
//global editedline to 0. // edited line of a text (up and down to scroll)
//noooo correggi! a fare list(list()) crei subliste vuote!

FUNCTION RunKS {
	//RUNPATH( "/KOSmodore/kerboscript/001.ks", 1, 2 ). 
	PARAMETER fname.
	RUNPATH( "/KOSmodore/kerboscript/" + fname). 
}


FUNCTION preprocess {

//!!!!!!!!!!!!!!!!!!!!!!!!!
//   invece che caricare nella nuova lista solo le righe che non da eliminare
//   duplica la lista e semplicemente togli quelle da eliminare
//   puoi fare anche più funzioni tipo: togli commenti, togli righe vuote..
//!!!!!!!!!!!!!!!!!!!!!!!!!

	PARAMETER prog.
	LOCAL pproced TO LIST().
	LOCAL auxi TO 0. //auxiliary nummber
	//local firstword to "".
	
	FROM {LOCAL x IS 4.} UNTIL x = prog:LENGTH-1 STEP {SET x TO x+1.} DO {
		//set firstword to prog[x].
		
		//Remove REM comments
		IF NOT(prog[x]:TOUPPER:startswith("REM ")) { 
		//	pproced:add(prog[x]).
		
		//Remove ' comments
			SET auxi TO prog[x]:FIND("'").
			IF auxi = -1 {
				pproced:ADD(prog[x]).
			} ELSE {
				pproced:ADD(prog[x]:REMOVE(auxi,(prog[x]:length-auxi))).
			}
		}
	}
	RETURN pproced.
}

FUNCTION ClearLine {
	SET emptyprog[CuY] TO "".
	PRINT "                                        " AT(0,CuY).
	SET CuX TO 0.
}

FUNCTION initstextvar {
	emptyprog:CLEAR.
	emptyprog:ADD("").   //otherwise he doesn't know where to draw the cursor
	ClsNoCur().
	
}

FUNCTION NewBasFile {
	ClearKSFile().
	SET cuy TO 0.  //would be better run it once
	//set offsy to 1. //
	SET cux TO 0.
	GoPage(237).
}

FUNCTION ClearKSFile {
	emptyprog:CLEAR.
	// add also the header (version ecc.)
	emptyprog:ADD("").   //otherwise he doesn't know where to draw the cursor
	ClsNoCur().
	//set lind to 0.
	//GoPage(277).
}

FUNCTION NewKSFile {
	ClearKSFile().
	SET cuy TO 0.  //would be better run it once
	//set offsy to 1. //
	SET cux TO 0.
	GoPage(277).
}





