

//Rover Things

//run once "/KOSmodore/main.ks".
GLOBAL speedPID TO PIDLoop(0.4, 0, 0, 0, 1).
GLOBAL turnPID TO PIDLOOP(0.3,0,0.1,-1,1).

GLOBAL controlrover TO 0.      // 0 = nessun rover da conrollare
                               // 1 = rover da mandare ad un posto specifico
							   // 2 = rover segue track

// stati del rover che va verso una posizione

GLOBAL roverstate TO 0.        // 0 = stato di nulla
							   // 1 = stato di puntamento iniziale lento
							   // 2 = dritto per due metri per raddrizzare le ruote
							   // 3 = veloce fino a 30 metri dall'arrivo
							   // 4 = frenata in caso di sbandamento che riconduce a 1
							   // 5 = piano gli ultimi metri
							   
LOCAL twompos TO LatLng(0,0).  //posizione ausiliaria per andare dritto due metri e raddrizzare le ruote prima di aumentare la velocità

GLOBAL TCou TO 1.              //indice che scorre il  track. parte da 1 perchè 0 è lo header

FUNCTION brakes_on {
	//print "BON".
	BRAKES ON.
}

FUNCTION brakes_off {
	//print "BOFF".
	BRAKES OFF.
}

FUNCTION conroverstate
{
	PARAMETER f.

	IF f = 0 {
		//Speed
		GLOBAL speedPID TO PIDLoop(6, 0, 0, 0, 1).
		SET speedPID:setPoint TO 0.
	
		//Direction
		GLOBAL turnPID TO PIDLOOP(0.3,0,0,-1,1).
		SET turnPID:setPoint TO 0.
	}
	
	IF f = 1 {
		//Speed
		GLOBAL speedPID TO PIDLoop(6, 0, 0, 0, 1).
		SET speedPID:setPoint TO 1.
	
		//Direction
		GLOBAL turnPID TO PIDLOOP(0.3,0,0,-1,1).
		SET turnPID:setPoint TO 0.
	}

	IF f = 2 {		
		// Speed
		GLOBAL speedPID TO PIDLoop(0.4, 0, 0, 0, 1).
		SET speedPID:setPoint TO 4.
	
		// Direction	
		GLOBAL turnPID TO PIDLOOP(0.01,0,0,-.8,.8).
		SET turnPID:setPoint TO 0.
	}

	IF f = 3 {		
		// Speed
		GLOBAL speedPID TO PIDLoop(0.4, 0, 0, 0, 1).
		SET speedPID:setPoint TO 15.
	
		// Direction	
		GLOBAL turnPID TO PIDLOOP(0.01,0,0,-.8,.8).
		SET turnPID:setPoint TO 0.
	}
}



FUNCTION ConRoverPos {
	
	PARAMETER LPos.     // loaded Pos
	
    //necessita in partenza roverstate = 1
	SET wanted_throttle TO SpeedPID:UPDATE(TIME:SECONDS,SHIP:VELOCITY:SURFACE:MAG).
	SET wanted_angle TO TurnPID:UPDATE(TIME:SECONDS,LPos:bearing).
	SET SHIP:CONTROL:wheelsteer TO wanted_angle.
	
	IF roverstate = 1 {
		conroverstate(1).
		IF LPos:distance < 5 {
			SET controlrover TO 0.
		}
		IF abs(LPos:bearing) < 8{
			SET roverstate TO 2.
			SET twompos TO LatLng(SHIP:geoposition:lat, SHIP:geoposition:lng).
			
		}
	}
	
	IF roverstate = 2 {
		conroverstate(1).
		IF abs(LPos:bearing) > 20{
			SET roverstate TO 4.
		}
		IF twomPos:distance > 2 {
			SET roverstate TO 3.
		}
		IF LPos:distance < 5 {
			SET controlrover TO 0.
		}
	}
	
	IF roverstate = 3 {
		conroverstate(3).
		IF abs(LPos:bearing) > 20{
			SET roverstate TO 4.
		}
		IF LPos:distance < 40 {
			conroverstate(2).
			BRAKES ON.
		
			IF SHIP:VELOCITY:SURFACE:MAG < 4 {
				BRAKES OFF.
				SET roverstate TO 5.
			}
		}
	}
	
	IF roverstate = 4{
		conroverstate(0).
		BRAKES ON.
		
		IF SHIP:VELOCITY:SURFACE:MAG < 1 {
			BRAKES OFF.
			SET roverstate TO 1.
		}
	}
	
	IF roverstate = 5{
		conroverstate(2).
		IF abs(LPos:bearing) > 20{
			SET roverstate TO 4.
		}
		IF LPos:distance < 5 {
			conroverstate(0).
			BRAKES ON.
		
			IF SHIP:VELOCITY:SURFACE:MAG < 1 {
				BRAKES OFF.
				SET controlrover TO 0.
			}
			
		}
	}
	
	IF controlrover = 0 {
		BRAKES ON.
		UNLOCK wheelThrottle.
		SET SHIP:CONTROL:wheelsteer TO 0.
		UNLOCK WHEELSTEERING.
	}

	IF Npage = 20 {
		FROM {               //porta il cursore dove non lo vede nessuno
			LOCAL xx IS 1.
		}
		UNTIL xx = 18 STEP {
			SET xx TO xx+1.
		} 
		DO {
			PRINT " ".
		}
		PRINT "Distance to target: " + ROUND(LPos:distance, 2) + (" m   ") AT (0,0).
		PRINT "Bearing to target: " + ROUND(LPos:bearing, 2) + ("°   ") AT (0,1).
		PRINT "State: " + roverstate AT (0,2).	
		PRINT "Speed: " + SHIP:VELOCITY:SURFACE:MAG AT (0,3).
		
	}
}

FUNCTION ConRoverTrack {
	PARAMETER LT.      //LoadedTrack
	 
	//print  "l: " + LT:LENGTH + ", TCou = " + Tcou AT (0,5).
	//print Tcou + "° pos: " + LT[TCou][1] +", " + LT[TCou][2] AT (0,6).
	
	//set endpos to LatLng(LT[TCou][1], LT[TCou][2]).
	//clearscreen.
	
	
	WAIT 0.1.
	//set TCou to TCou + 1.
	IF TCou <  LT:LENGTH {
		//print "Tcou: " + TCou AT(0,5).
		conroverPos(LatLng(LT[TCou][1], LT[TCou][2])).
		IF controlrover = 0 {    // lo header non mi interessa (-1)
			SET controlrover TO 2.
			SET TCou TO TCou + 1.
			
			SET speedPID:setPoint TO 1.
			SET turnPID:setPoint TO 0.
		
			GLOBAL wanted_throttle TO 0. // for now.
			LOCK wheelThrottle TO wanted_throttle.
			GLOBAL wanted_angle TO 0.
			LOCK WHEELSTEERING TO wanted_angle.
		}
	}
	ELSE {
		SET controlrover TO 0.
		SET TCou TO 1.
		BRAKES ON.
		UNLOCK wheelThrottle.
		SET SHIP:CONTROL:wheelsteer TO 0.
		UNLOCK WHEELSTEERING.
	}
}



