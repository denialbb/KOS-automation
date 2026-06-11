@LAZYGLOBAL OFF.

GLOBAL LBook TO LIST(LIST()). //noooo correggi! a fare list(list()) crei subliste vuote!

GLOBAL CurrentNote TO 0. // n di pagina corrente del logbook



FUNCTION showNextNote {
	IF CurrentNote < LBook:LENGTH-1 {
		SET CurrentNote TO CurrentNote + 1.
		GoPage(40).
	}
	
}

FUNCTION LeaveLBook{
	SET CurrentNote TO LBook:LENGTH-1.
	GoPage(1).
}

FUNCTION showPrevNote {
	IF CurrentNote > 0 {
		SET CurrentNote TO CurrentNote - 1.
		GoPage(40).
	}
}

FUNCTION LbookNewPage{
	LOCAL stri TO "".
	LBook:ADD(LIST()).
	
	LOCAL datetime TO TIMESTAMP().
	SET stri TO "Time: " + datetime:full. //TIME:SECONDS.
	LBook[LBook:LENGTH-1]:ADD(stri).
	SET stri TO "Place: " + SHIP:BODY.
	LBook[LBook:LENGTH-1]:ADD(stri).
	SET CurrentNote TO LBook:LENGTH-1.
	GoPage(40).
}