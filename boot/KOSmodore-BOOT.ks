//----------------------------------------------|
//                                              |
//  kOS-Computer 64 - by Sinucep                |
//                                              |
//----------------------------------------------|

WAIT UNTIL SHIP:STATUS <> "prelaunch" OR SHIP:unpacked.

switch TO 0.

RUNPATH( "/KOSmodore/main.ks").
