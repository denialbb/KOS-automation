PRINT "Basics #28".
WAIT 3.
SAS OFF.

LOCAL targvel IS 0.

LOCK STEERING TO UP.

SET throttlePID TO PIDLoop(1.02, 10.3, 0.03, 0, 1).
SET throttlePID:setpoint TO targvel.
SET wanted_throttle TO 1.
LOCK THROTTLE TO wanted_throttle.

STAGE.
//set throttlePID:SETPOINT to -2.
WAIT UNTIL alt:radar >= 10.
SET now TO TIME:SECONDS.

UNTIL TIME:SECONDS >= now + 15 {
  SET wanted_throttle TO throttlePID:UPDATE(TIME:SECONDS, SHIP:verticalspeed).
  PRINT "  PID Throttle : " + ROUND(THROTTLE,2) + "   " AT (0,6).
  PRINT "vertical speed : " + ROUND(SHIP:verticalspeed,2) + " m/s      " AT (0,7).
  PRINT "     alt:radar : " + ROUND(alt:radar,2) + " m      " AT (0,8).
}

SET throttlePID:SETPOINT TO -2.
UNTIL SHIP:STATUS = "landed" {
  SET wanted_throttle TO throttlePID:UPDATE(TIME:SECONDS, SHIP:verticalspeed).
  PRINT "  PID Throttle : " + ROUND(THROTTLE,2) + "   " AT (0,6).
  PRINT "vertical speed : " + ROUND(SHIP:verticalspeed,2) + " m/s      " AT (0,7).
  PRINT "     alt:radar : " + ROUND(alt:radar,2) + " m      " AT (0,8).
}

WAIT 0.
SAS ON.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
UNLOCK THROTTLE.