@LAZYGLOBAL OFF.

RUN once "/KOSmodore/runKS.ks".
//run once "/KOSmodore/texted.ks".

GLOBAL CuX TO 0.
GLOBAL CuY TO 0.
GLOBAL Cuc TO "_".
GLOBAL CuVisible TO TRUE.

GLOBAL STextAux TO LIST(). //used to temporary stock the serialized text before saving

GLOBAL offsy TO 0. //how much up or down to print the text

FUNCTION copyvarsave { //
	PARAMETER Pag,mult. //mult is a id needed if more strings are asked from the same page
	//resetcicleset().
	SET stextaux TO emptyprog:COPY.
	emptyprog:CLEAR.
	emptyprog:ADD("").
	//set cuy to 0.
	//set offsy to 1.
		
	//GoPage(Pag).
	Savefilelist(mult).
}

FUNCTION Cur {
	PRINT Cuc AT(Cux, Cuy+offsy).
}

//buffer state function (when you have to do something just once)
FUNCTION bufTextEdit {
	CuReset().
	GoPage(237).
}

FUNCTION CuReset { 
	SET CuX TO 0.
	SET Cuy TO 0.
}
	
FUNCTION cuBlank {
	PRINT " " AT(cux,cuy+offsy).
}

FUNCTION CuDel {   //what char there is in (x,y). Behind the cursor
	
	LOCAL cha TO "".
	IF cux < emptyprog[cuy]:length {
		SET cha TO emptyprog[cuy]:substring(cux,1).
	} ELSE {
		SET cha TO " ".
	}
	PRINT cha AT(cux,cuy+offsy).
}

FUNCTION CuRight {
	IF cuX < 40 {
		IF cux < emptyprog[Cuy]:length {
			CuDel().
			SET cuX TO cuX + 1.
			//Cur().
		}
	}
}

FUNCTION CuLeft {
	IF cuX > 0 {
		CuDel().
		SET cuX TO cuX - 1.
		//Cur().
	}
}

FUNCTION CuDown {
	IF cuY < 16 {
		IF Cuy < emptyprog:length-1 {
			
			CuDel().
			SET cuY TO cuY + 1.
			//set Edline to emptyprog[Cuy].
			IF emptyprog[Cuy]:length < CuX {
				SET Cux TO emptyprog[Cuy]:length.
			}
			//Cur().
		}
	}
}

FUNCTION CuUp {
	IF cuY > 0 {
		CuDel().
		SET cuY TO cuY - 1.
		IF emptyprog[Cuy]:length < CuX {
				SET Cux TO emptyprog[Cuy]:length.
		}
		//Cur().
	}
}

