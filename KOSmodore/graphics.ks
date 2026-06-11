RUN once "/KOSmodore/settings.ks".

LOCAL visualtrack TO LIST(). 


FUNCTION gvec {
	//PARAMETER targetOrbitable,vColor, vLabel IS "default".
	PARAMETER a,b,c,co.
	RETURN VECDRAW(
		v(0,0,0),
		v(a,b,c),
		co,
		"w",
		1,
		TRUE,
		SettingsL[0], //marker thikness
		TRUE,
		FALSE
	).
}

// piccolo esempio per illustrare come gestire singoli vettori disegnati in una lista
FUNCTION draw {
   LOCAL vecs TO LIST().
   vecs:ADD(gvec(-2,4,6,yellow)).
   WAIT 3.
   SET vecs[0]:show TO FALSE.
}

FUNCTION HideTRK {
	clearvecdraws().
}

// visualizza un segmento verticale sulla superficie
// in corrispondenza del puntop geografico
FUNCTION GSpot {
	PARAMETER gp, lbl.
RETURN VECDRAW(
			{RETURN gp:ALTITUDEPOSITION(gp:TERRAINHEIGHT+3).},
			{RETURN gp:POSITION - gp:ALTITUDEPOSITION(gp:TERRAINHEIGHT+3).},
			{RETURN red.},
			lbl, 1, TRUE, SettingsL[0], FALSE).
}

FUNCTION GDestination {
	clearvecdraws().
	GSpot(GeoPos,"Destination").
}

FUNCTION GTrack {
	PARAMETER LT.  
	LOCAL gp TO LATLNG(10, 20). //geo pos
	LOCAL cou TO 0.	
	clearvecdraws().
	
	//print  "l: " + LT:LENGTH + ", TCou = " + Tcou AT (0,5).
	
	FOR po IN LT {
	
		//print Tcou + "° pos: " + po[1] +", " + po[2] AT (0,6).
		SET gp TO LatLng(po[1], po[2]).
	
		IF cou > 0 {
			//wait 1.
			//print cou + ", " + gp:lat  + ", " + gp:lng .
			visualtrack:ADD(V(0,0,0)).
			SET visualtrack[cou-1] TO GSpot(gp, cou + "").
			
		}
		SET cou TO cou + 1.
	}
}	