@LAZYGLOBAL OFF.

setStage("Capture").
logMsg("Waiting for " + SHIP:BODY:NAME + " periapsis to capture.").
safeCoast(TIME:SECONDS + ETA:PERIAPSIS - 60).

logMsg("Calculating capture burn for 20km orbit.").
LOCAL r_peri IS SHIP:PERIAPSIS + BODY:RADIUS.
LOCAL targetPe IS 20000.
LOCAL r_apo_tgt IS targetPe + BODY:RADIUS. // 20km
LOCAL a_tgt IS (r_peri + r_apo_tgt) / 2.
LOCAL v_tgt IS sqrt(BODY:MU * (2/r_peri - 1/a_tgt)).
LOCAL v_peri_pred IS sqrt(BODY:MU * (2/r_peri - 1/ORBIT:semimajoraxis)).
LOCAL dV_cap IS v_peri_pred - v_tgt.

LOCAL nd_cap IS NODE(TIME:SECONDS + ETA:PERIAPSIS, 0, 0, -dV_cap).
ADD nd_cap.
RUNPATH("0:/MJ/ExeNode.ks").

setStage("Inclination Change").
logMsg("Adjusting to polar orbit (90 deg inclination).").
RUNPATH("0:/MJ/MJChangeInc.ks", 90).

setStage("Circularize").
logMsg("Circularizing at " + SHIP:BODY:NAME + " Apoapsis.").
RUNPATH("0:/MJ/MJCircToAp.ks").
RUNPATH("0:/MJ/MJChangeAp.ks", 20).
RUNPATH("0:/MJ/MJChangePe.ks", 20).

setStage("Mission Complete").
logMsg("Automation mission completed successfully! Orbit is polar 20km.").
