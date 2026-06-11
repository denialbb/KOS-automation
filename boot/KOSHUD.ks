GLOBAL boottime TO TIME:SECONDS.
GLOBAL debug TO 0. // shows input and output for triggered item. use for checking which modules are called for failed trigger. logging is better.
GLOBAL dbglog TO 0. // 0 = OFF 1 = LOG  2= Detailed Log 3 = advanced LOG WITH METER/FUEL CHECK AND STARTUP SPAM (you probably dont want 3) 4, manual entry only, color logging 5, manual entry only, skips logging for start
GLOBAL colorprint TO 1. // fancy colors?
GLOBAL ForceMon TO -1. // set to force specific monitorif over 0, will use forcemon-1 for trg mon
SET FASTBOOT TO 0. // REMOVES PAUSES FROM LOAD ITEMS LIST 

// file names
LOCAL cnt TO 0.
LIST PROCESSORS IN coreList.
FOR i IN corelist {IF i:TAG = "" SET i:TAG TO "C"+cnt. SET cnt TO cnt+1.}
GLOBAL proot IS "0:/". //path():root. 
GLOBAL SubDirSV IS proot+"ShipAutoSV/".                   //directory for auto option save
GLOBAL Autofile IS SHIP:NAME+"-"+core:tag+".json".        //filename for auto option save
GLOBAL AutofileBAK IS SHIP:NAME+"-"+core:tag+".bak.json". //filename for BKP option save
GLOBAL DebugLog TO proot+"KosHud.log".                       //filename for log file. 


//check

//Next update plans
  //Auto load backup if exists and current time is prior to backup time
  //lock control from here
  //REACTORS

//goals for later
    //scroll info list if on bot or top row
    //CYCLE FIELDS
    //SMART LOAD, CHECK IF TIME IS < LAST SAVRED TIME, IF SO, LOAD BKP IF SMART LOAD IS SELECTED
    //headless mode

// things to fix
  //check how it handles docking
  //check if 2 vehicles same docking
  //sounds

//items to update 

//STRETCH GOALS
  //autopilot speed toggle MAIN engines mode
  //make continue work on liist auto
  //check name saved for payloadpart
  //add to orbit to autopiilot
  //add copy to other core
  //make PAL work
  //hover option. (when i need it)
  //add option to change monitor in flight

//probably wont work or wont bother with
  //add biome to auto state //Need to figure out if i can get a list of all biomes on current SOI or wont work.
//#endregion

 //#region set start vars
SET config:ipu TO 200.
GLOBAL loadattempts TO 0.
LOCAL fileList IS LIST().
LOCAL found IS FALSE.
LIST files IN fileList.
FOR file IN fileList {IF file = DebugLog SET found TO TRUE.}
IF found = TRUE  DELETEPATH(DebugLog).
IF exists(DebugLog) AND NOT (DEFINED mchkcnt){ 
  DELETEPATH(DebugLog).
 IF dbglog > 0{
    log2file("################################################################################").
    log2file("|                              KERBAL HUD SYSTEM                               |").
    log2file("|                              BY  FUZZYMEEP TWO                               |").
    log2file("|                                VERSION 1.07                                  |").
    log2file("|___________________________________LOADING____________________________________|").
    log2file("################################################################################").
 }
}
GLOBAL CrewCap TO 0.
GLOBAL CrewAct TO LIST().
UNTIL SHIP:unpacked AND SHIP:loaded  WAIT 1.
IF SHIP:HASSUFFIX("CREWCAPACITY"){
  IF SHIP:crewcapacity > 0{
    SET crewcap TO SHIP:crewcapacity.
    IF SHIP:HASSUFFIX("CREW") IF SHIP:crew:length > 0 SET CrewAct TO SHIP:crew.}
}
CLEARSCREEN.
GLOBAL HEIGHT TO 0.
GLOBAL headless TO 0. // for future implimentation
IF  SHIP:STATUS = "LANDED" OR SHIP:STATUS = "PRELAUNCH"{
  SET BRAKES TO TRUE. // brakes and check height on launch.
  IF ALT:RADAR > 0 {SET HEIGHT TO HEIGHT-(0-(ALT:RADAR)).}
  ELSE{IF ALT:RADAR < 0 {SET HEIGHT TO HEIGHT+(0-(ALT:RADAR)).}}
}
//wait for monitors to load
IF CrewCap > 0 AND CrewAct:length > 0 {//crewed = wait for iva
   IF DbgLog > 0 log2file("WAITING FOR MONITORS").
UNTIL ADDONS:kpm:getmonitorcount() > 0  WAIT 1.}ELSE{ //uncrewed = restart a few times then go headless 
  IF NOT (DEFINED mchkcnt)GLOBAL mchkcnt TO 0.
  IF NOT (ADDONS:kpm:getmonitorcount() > 0 OR mchkcnt > 9){
    SET mchkcnt TO mchkcnt+1.
    IF DbgLog > 0 log2file("NoMonitors: "+mchkcnt+" of 10 waiting"+(10-mchkcnt+1)/2+" SECONDS TO RETRY" ).
    WAIT (10-mchkcnt+1)/2.
    IF exists("0:/boot/KOSHUD.ks") RUN "0:/boot/KOSHUD.ks".
  }
  IF mchkcnt > 9 SET headless TO 1.
  unset mchkcnt.
}
SET config:ipu TO 2000.
IF dbglog > 3{
  IF DbgLog > 0 log2file("startup logging skipped").
  SET dbglog TO -1.
}
SET QUICKREBOOT TO 1. //SKIPS ITEM DETECT ON match //2 loads all from file on fingerprint match
IF NOT (DEFINED PRTCount){GLOBAL PRTCount TO SHIP:PARTS:LENGTH.}ELSE{IF prtcount <> SHIP:PARTS:LENGTH{SET quickreboot TO 0. SET PRTCount TO SHIP:PARTS:LENGTH.}} 
GLOBAL FuelUpdRate TO "Fast".
GLOBAL ClrMin TO 0.
IF colorprint > 0 SET ClrMin TO 9.
GLOBAL acp TO 7.
GLOBAL LOADBKP TO 0.
GLOBAL printpause TO 0.
GLOBAL SAVEBKP TO 0.
GLOBAL twr TO 0.
GLOBAL LFX TO 0.
GLOBAL saveflag TO 0.
GLOBAL widthlim TO 80.
GLOBAL heightlim TO 18.
GLOBAL dctnmode TO 0.
GLOBAL cmdln TO 0.
GLOBAL meterpart TO 0.
GLOBAL ActionWait TO 0.
GLOBAL STPREV TO "".
GLOBAL BOTPREV TO "".
GLOBAL lastdir TO "+".
GLOBAL linklock TO 0.
GLOBAL setdelay TO 0.
GLOBAL Curdelay TO 0.
GLOBAL WarnOut TO "".
GLOBAL WarnLst TO "".
GLOBAL HDItm TO 1.
GLOBAL HDTag TO 1.
GLOBAL HDItmB TO 1.
GLOBAL newhud TO 1.
GLOBAL HDTagB TO 1.
GLOBAL pscnt TO 0.
GLOBAL apsel TO 1.
GLOBAL h5mode TO 0.
GLOBAL senseskp TO 0.
GLOBAL DCPRes TO 0.
GLOBAL Lscroll TO LIST(0,0).
GLOBAL scanlist TO LIST().
GLOBAL adjmode TO "num".
GLOBAL lastinput TO  TIME:SECONDS.
GLOBAL MISSINGPART TO 0.
GLOBAL AutoSetAct TO 1.
GLOBAL AutoSetMode TO 1.
GLOBAL AutoRstMode TO 1.
GLOBAL ItemLastRun TO 0.
GLOBAL refreshRateSlow TO 5.
GLOBAL refreshRateFast TO 1.
GLOBAL VLIMSTRT TO 10000.
GLOBAL PLIMSTRT TO 90.
GLOBAL LLIMSTRT TO 40.
GLOBAL HLIMSTRT TO 5000.
GLOBAL VLIM TO VLIMSTRT.
GLOBAL PLIM TO PLIMSTRT.
GLOBAL LLIM TO LLIMSTRT.
GLOBAL HLIM TO HLIMSTRT.
GLOBAL plimadj TO 0.
GLOBAL ln14 TO 0.
GLOBAL HLon TO 0.
GLOBAL HLPARTS TO 0.
GLOBAL flyadj TO LIST(0,0,0,0,0,0,0).
GLOBAL AgState TO LIST(AG1,ag2,ag3,ag4,ag5,ag6,ag7,ag8,ag9,ag10,0,RCS,ABORT,GEAR,LIGHTS,BRAKES).
GLOBAL AgSPrev TO AgState:COPY.
GLOBAL ALTPRV TO SHIP:ALTITUDE.
GLOBAL VSPDPRV TO SHIP:verticalspeed.
GLOBAL SPDPRV TO SHIP:VELOCITY:SURFACE:MAG.
GLOBAL RFSBAak TO refreshRateSlow.
GLOBAL NextGoodField TO 0.
GLOBAL lostparts TO LIST().
GLOBAL PRINTQ IS QUEUE().
GLOBAL THRTFIX TO 0.
GLOBAL THRTPREV TO THROTTLE.
GLOBAL AUTOBRAKE TO 2. //2 IS BRAKES ON UNDER 50% THROTTLE AND LANDED, 0 IS OFF, 1 IS ON.
GLOBAL AUTOLOCK TO 2. //AUTO LOCK MOVABLE PARTS AFTER MOVE 0 = off up to 5 seconds
GLOBAL IsPayload TO LIST(0,core:part).
SET IsPayload TO checkdcp(core:part,"payload").
//VARS NEEDED FOR CALLS.
GLOBAL ID TO "".
SET bigempty2 TO"                                                                              ".
SET bigempty TO"                                                                           ".
SET LNstp TO 1.
GLOBAL MeterGoodLast TO 0.
GLOBAL MeterCheckCur TO 1.
GLOBAL V0 TO GetVoice(0).
GLOBAL rowT1 TO "".
GLOBAL rowT2 TO "".
GLOBAL senselist TO LIST(0,0,0,0,0,0).
GLOBAL Speeds TO LIST(LIST(""," VRY SLOW ","   SLOW   ","  NORMAL  ","  DOUBLE  ","  TRIPLE  ","   QUAD   "),
                      LIST("",100         ,200        ,500          ,1000        ,1500        ,2000)).
GLOBAL SPEEDSET TO LIST(3,6,2,6).
GLOBAL CPUSPD TO SPEEDSET[0].
GLOBAL rowval TO 0.
GLOBAL rtech TO 0.
GLOBAL mks TO 0.
GLOBAL REMETER TO 0.
GLOBAL zop TO 1.
GLOBAL forcerefresh TO 0.
GLOBAL RunAuto TO 1.
GLOBAL MonAutoCyc TO 1.
GLOBAL BtnActn TO 0.
GLOBAL airmax TO 0.
GLOBAL monitorIndex TO -1.
    GLOBAL HudOpts TO LIST(0).
    GLOBAL ItemListHUD TO LIST().
    GLOBAL ItemList TO LIST(0).
      GLOBAL prtTagList TO LIST(LIST(0)).
          SET prtList TO LIST(LIST(LIST(0))).
            GLOBAL GrpOpsList TO LIST(LIST(LIST(0))).
            SET GrpDspList TO LIST(LIST(LIST(0))).
            GLOBAL GrpDspList2 TO LIST(LIST(LIST(0))).
            GLOBAL GrpDspList3 TO LIST(LIST(LIST(0))).
            GLOBAL AutoDspList TO LIST(LIST(LIST(0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0))).
            GLOBAL autoRstList TO LIST(LIST(LIST(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0))).
            GLOBAL AutoValList TO LIST(LIST(LIST(0))).
            GLOBAL AutoRscList TO LIST(LIST(LIST(0))).
            GLOBAL AutoTRGList TO LIST(LIST(LIST(0))).
GLOBAL botrow TO bigempty2.
GLOBAL paidmeter TO 0.
GLOBAL aplim TO 1.
GLOBAL ActionQNew TO LIST().
GLOBAL HdngSet TO LIST(LIST(9,0  ,0   ,0   ,0   ,0      ,0   ,60 ,40  ,60 ), //set
                       LIST(9,359, 180, 180,5000,1000000, 500,180,5000,180), //max
                       LIST(9,0  ,-180,-180,0   ,0      ,-500,0  ,0   ,0  ), //min
                       LIST(9,1  ,1   ,1   ,0   ,0      ,0   ,1  ,0   ,0  )). //on/off
                       IF SHIP:type = "plane" SET aplim TO 3.
GLOBAL MONITORID TO 0.
GLOBAL mtrcur TO LIST(0,100,5,1,1,1,1,LIST(),LIST()). //mtrvalmin[0],mtrvalmax[1],mtrvaladj[2],mtroptnmin[3],mtroptnmax[4],mtroptn[5],curfield[6], curfield ops in[7], curfield ops out[8].
GLOBAL StrLock TO 0.
GLOBAL cmlist TO LIST().
GLOBAL TrgLim TO 1.
GLOBAL  FindCl TO lexicon("GREEN","").
        FindCl:ADD("RED","[#FF0000]").
        FindCl:ADD("CYN","[#00FFFF]").
        FindCl:ADD("YLW","[#FFFF00]").
        FindCl:ADD("WHT","[#FFFFFF]"). 
        FindCl:ADD("BLU","[#0000FF]").
        FindCl:ADD("BLK","[#000000]").  
        FindCl:ADD("PRP","[#FF00FF]").
        FindCl:ADD("ORN","[#ffae00]").
        FindCl:ADD("YRN","[#ffb300]").
        FindCl:ADD("RRN","[#ff6200]").
        FindCl:ADD("YGR","[#c8ff00]").
        FindCl:ADD("GRN","[#00ff00]").
GLOBAL  FindCl2 TO lexicon(
" TURN ON  ", "RED", " TURN OFF ","CYN","  DELETE  ","ORN"," TRANSMIT ","WHT", " SET TRGT ", "WHT"," DPST RSC ","WHT","SPRNG AUTO","GRN","SPRNG MAN ","GRN", " RUN TEST ","WHT","  EXTEND  ","CYN", "clamped", "CYN", "unclamped", "WHT",
"  DEPLOY  ","CYN" ,"  RETRACT ","RED" ," LIGHT OFF","ORN"," LIGHT ON ","WHT"," MODE OFF ","YLW"  ," MODE ON  ","PRP","   FIRE   ","ORN"," DECOUPLE ","CYN", "DECOUPLED ","RED","BAY CLOSED","WHT"," BAY OPEN ","ORN",
" CRNT TRG ","WHT","SET TARGET","ORN"
). 
GLOBAL  FindCl3 TO lexicon(
"Active"  ,"CYN","Inactive"  ,"RED","NORMAL"     ,"CYN","INVERTED","RED","True"  ,"CYN","False","RED","All"  ,"WHT","Decreasing","ORN","Increasing"    ,"CYN","Descent"    ,"ORN","Ascent","CYN","Both","WHT","Departure","ORN","Approach","CYN",
"KSC Loss","ORN","Total Loss","RED","Initialized","WHT","nominal" ,"WHT","closed","RED","safe" ,"WHT","risky","ORN","immediate" ,"RED","Main Throttle" ,"WHT","Independent","ORN","off"   ,"RED","on"  ,"CYN","playing"  ,"WHT","paused"  ,"ORN",
"foward","CYN","reverse","ORN","SAS Only","ORN","Pilot Only","YLW","port(CCW)","YLW","stbd(CW)","orn","locked","ORN","free", "wht","retracted","WHT", "extended", "CYN", "enabled", "CYN", "disabled","RED", "yes", "CYN", "no","RED", "engaged", "CYN",
 "disengaged","RED","counterclockwise","CYN","clockwise","WHT","None","CYN","Repeat","ORN","Ping Pong","PRP","None-Restart","WHT","Moving...","YLW"
). 

GLOBAL actnlist TO LIST(1,"","","","").
GLOBAL biomecur TO "UNKNOWN".
GLOBAL trimwords TO LIST("Experiment","Sina","-MLEM","-MGS","-MGC","#LOC_AA_","_title","title", "DISPENSER", "Flight Computer").
GLOBAL ReplWRDS TO LIST(LIST("deploy Dir:True"  ,"deploy Dir:False"    ,"Current RPM","Effective Air Speed","deploy direction","Group:"    ,"wet"        , "dry"   ,"specific impulse","docking acquire force","rotation locked","safe to deploy?","deactivate at ec %","activate at ec %", "discharge rate","missiles/target","alternator output","SAS Only","Pilot Only","min altitude" ,"unclamp tuning ","standby mode ","mincombatspeed","\","electric charge","rotation direction","invert direction","kos average power","command state","kos disk space","powercoupler","No PDUs in Range"),
                        LIST("deploy Dir:Inverted","deploy Dir:Normal" ,"RPM"        ,"Eff.Speed"           ,"deploy Dir"      , "Group:AGX","Afterburner","normal", "SPi"            ,"Force"                , "rot. lock"     , "Safety"        ,"deact.ec%"         ,"act ec %"        , "disch. rate"   ,"Msl/trg"        , "E/C OUT"          ,"SAS"    ,"Pilot"     ,"min alt."     ,"clamp"          ,"standby"      ,"min cmbt spd"  ,"/","E/C"            ,"dir"               ,"dir"             ,"kos PWR"          ,"command"      ,"dsk space"     ,"PWR-CPL"     ,"No PDUs")).
//global trimwords2 to list("idle","percent").
GLOBAL MODESHRT TO LIST(15, " OFF", " SPD"," ALT"," AGL"," EC "," RSC ","THRT","PRES", " SUN","TEMP","GRAV"," ACC"," TWR","STAT","FUEL"). 
GLOBAL MODELONG TO LIST(15,"    OFF   ","   SPEED  "," ALTITUDE "," ALT AGL  ","ELEC. CHRG"," RESOURCE "," THROTTLE "," PRESSURE ","   SUN    ","   TEMP   ","  GRAVITY ","  ACCEL.  ","   TWR    ","  STATUS  ","   FUEL   ").
GLOBAL STATUSOPTS TO LIST(12,"LANDED","SPLASHED","PRELAUNCH","FLYING","SUB_ORBITAL","ORBITING","ESCAPING","DOCKED","APOAPSIS","PERIAPSIS","NEXT NODE","TRANSITION").
GLOBAL STATUSSAVE TO LIST("LANDED","SPLASHED","PRELAUNCH","ORBITING").
GLOBAL STATUSSPACE TO LIST("SUB_ORBITAL","ORBITING","ESCAPING").
GLOBAL STATUSLAND TO LIST("LANDED","SPLASHED","PRELAUNCH","FLYING").
GLOBAL STATUSFLY TO LIST("FLYING","SUB_ORBITAL").
GLOBAL MJEB TO LIST(
  LIST("PROGRADE"      , "RETROGRADE"     , "NORMAL"     , "ANTI NORMAL"    , "RADIAL OUT"     , "RADIAL IN"     , "KILL ROT"          , "deact SMARTACS"    , "LAND SOMEWHERE", "LAND @ KSC", "PANIC!","TRNSLTRN OFF"   ,"TRNSLTRN VERT"        ,"TRNSLTRN ZERO SPD"     ,"TRNSLTRN +1 SPD"     ,"TRNSLTRN -1 SPD"     ,"TRNSLTRN TGL H/S"       ,"ASCENT AP TGL"  ),
  LIST("orbit prograde","orbit retrograde","orbit normal","orbit antinormal","orbit radial out","orbit radial in","orbit kill rotation","deactivate smartacs","land somewhere" ,"land at ksc","panic!" ,"translatron off","translatron keep vert","translatron zero speed","translatron +1 speed","translatron -1 speed","translatron toggle h/s","ascent ap toggle")).
GLOBAL StsSelection TO 1.
GLOBAL buttons TO ADDONS:kpm:buttons.
GLOBAL AutoMinMax TO LIST(0,LIST(0,0)).
FOR i IN range (2,modelong[0]+1){AutoMinMax:ADD(LIST(0,LIST(0,0),LIST(0,0))).}
//CHECK ADDONS
GLOBAL agx TO 0.
IF ADDONS:AVAILABLE("AGX") SET AGX TO ADDONS:AGX.
IF ADDONS:AVAILABLE("RT") SET RTech TO ADDONS:RT.
GLOBAL mjb TO 0.
GLOBAL mjpart TO 0.
IF SHIP:modulesnamed("MechJebCore"):length > 0 {
  SET mjb TO 1.
  IF core:part:HASMODULE("mechjebcore") SET mjpart TO core:part. 
  ELSE{FOR p IN SHIP:parts IF core:part:HASMODULE("mechjebcore") {SET mjpart TO p. BREAK.}}
}
//#endregion
//#region set lists
GLOBAL  autotaglist TO listadd(LIST("ModuleScienceExperiment"),TrimModules(LIST("ModuleProceduralFairing","DischargeCapacitor","ModuleScienceLab","BDModulePilotAI","MissileFire","ModuleScienceLab","usi_converter","usi_harvester","DMModuleScienceAnimateGeneric","ModuleAnimationGroup", "WOLF_SurveyModule","SCANexperiment","ModuleOrbitalSurveyor","ModuleRoboticController"))).
GLOBAL AnimModAlt TO listadd(LIST("ModuleAnimateGeneric"),TrimModules(LIST("ModuleAnimationGroup","DMModuleScienceAnimateGeneric","USIAnimation","scansat"))).
GLOBAL lightMod TO LIST("Lights"     , "  LIGHTS  ","ModuleLight","ModuleNavLight", "ModuleColorChanger","ModuleAnimateGeneric").
GLOBAL lightmodskp TO LIST("RetractableLadder","ModuleDockingNode"). //ADD MODULES WITH BUILTIN LIGHTS TO SKIP ADD TO LIGHT
GLOBAL lightChkskp TO LIST("ModuleScienceConverter","ModuleScienceLab","ModuleWheelDeployment","RetractableLadder"). //ADD MODULES WITH BUILTIN LIGHTS TO SKIP light check to keep parts from turning their own lights on and off with actions
GLOBAL AGMod TO LIST("Action Group"  ," ACTN GRP ","").
GLOBAL FlyMod TO LIST("Flight Control","FLGHT CTRL","").
GLOBAL CMDMod TO LIST("Command"      , " COMMAND  ","ModuleCommand","MechJebCore", "kOSProcessor").
GLOBAL CntrlMod TO LIST("control srf", "CNTRL SURF","ModuleControlSurface","SyncModuleControlSurface", "ModuleAeroSurface").
GLOBAL CntrlFldList TO LIST("authority limiter", "deploy angle").
GLOBAL engMod TO LIST("Engines"      , " ENGINES  ","ModuleEnginesFX","ModuleEngines","FSengineBladed","MultiModeEngine","ProceduralSRB").// (name, name for hud, module1, module2)
GLOBAL INTMod TO LIST("Intake"       , "  INTAKES ","ModuleResourceIntake").
GLOBAL dcpMod TO LIST("Decoupler"    , "DECOUPLERS","ModuleDecouple","ModuleAnchoredDecoupler","ModuleAnchoredDecouplerBdb").
GLOBAL DcpModAlt TO dcpMod:sublist(2,dcpMod:length).
GLOBAL gearMod TO LIST("Gear"        , "   GEAR   ","ModuleWheelDeployment", "ModuleAnimateGeneric","ModuleWheelMotor").
GLOBAL chuteMod TO LIST("Parachute"  , "PARACHUTES","ModuleParachute","RealChuteModule").
GLOBAL ladMod TO LIST("Ladder"       , "  LADDER  ","RetractableLadder").
GLOBAL bayMod TO LIST("Cargo Bay"    , "CARGO BAYS","ModuleCargoBay", "Hangar").
GLOBAL DOCKMod TO LIST("Docking Port", "  DOCKING ","ModuleDockingNode","ModuleGrappleNode").
GLOBAL RWMod TO LIST("Reaction Wheel", " RCTNWHEEL","ModuleReactionWheel").
GLOBAL slrMod TO LIST("Solar Panel"  , "   POWER  ","ModuleDeployableSolarPanel","KopernicusSolarPanel","ModuleResourceConverter","modulegenerator").
GLOBAL RCSMod TO LIST("RCS"          , "   RCS    ", "ModuleRCSFX").
GLOBAL drillMod TO LIST("Drill"      , "  DRILLS  ","ModuleResourceHarvester", "ModuleAsteroidDrill", "ModuleCometDrill").
GLOBAL radMod TO LIST("Radiator"     , " RADIATORS","ModuleActiveRadiator","ModuleDeployableRadiator","ModuleSystemHeatRadiator").
GLOBAL scimod TO LIST("Experiment"   , "XPERIMENTS","ModuleScienceExperiment","ModuleResourceScanner","DMModuleScienceAnimateGeneric", "WOLF_SurveyModule","SCANexperiment","SCANsat","ModuleOrbitalSurveyor","ModuleBiomeScanner").
GLOBAL SciRun TO LIST("run","log","irradiate", "perform", "start", "measure","report"," observ","scan","take","survey").
GLOBAL sciModAlt  TO listadd(LIST("ModuleScienceExperiment"),TrimModules(LIST("DMModuleScienceAnimateGeneric","ModuleAnimationGroup", "WOLF_SurveyModule","SCANexperiment","ModuleOrbitalSurveyor","SCANsat"))).
GLOBAL sciModData TO listadd(LIST("ModuleScienceExperiment"),TrimModules(LIST("ModuleScienceExperiment","DMModuleScienceAnimateGeneric","SCANexperiment","ModuleOrbitalSurveyor", "scansat"))).
GLOBAL antMod TO LIST("Antenna"      , " ANTENNAS ","ModuleDeployableAntenna","modulertantenna", "ModuleRTAntennaPassive","ModuleDataTransmitter","ModuleAnimateGeneric").
GLOBAL AntModAlt TO LIST("ModuleDeployableAntenna","modulertantenna", "ModuleRTAntennaPassive","ModuleDataTransmitter","ModuleAnimateGeneric").
GLOBAL FWMod TO LIST("Firework"      , " FIREWRKS ","ModulePartFirework").
GLOBAL ISRUMod TO LIST("Converter"   , "   ISRU   ","ModuleResourceConverter").
GLOBAL LabMod TO LIST("Science Lab"  , " SCI-LAB  ","ModuleScienceLab","ModuleScienceConverter").
GLOBAL RBTMod TO LIST("Robotics"     , " ROBOTICS ","ModuleRoboticServoPiston","ModuleRoboticServoRotor","ModuleRoboticServoHinge","ModuleRoboticRotationServo","ModuleRoboticController","").
GLOBAL SMRTMod TO LIST("Smart Parts" , " SMRT PRT ","Stager","Altimeter","SmartOrbit","DPLD","SmartSRB"," Speedometer","Timer","ProxSensor").

//MKS MOD
GLOBAL MksDrlMod TO LIST("MKS Harvest"," MKS HRVST","usi_harvester").
GLOBAL MksDrlModAlt TO MksDrlMod:sublist(2,MksDrlMod:length).
GLOBAL PWRMod TO LIST("MKS Resources", " MKS RSC  ","usi_converter").
GLOBAL PWRModALT TO PWRMod:sublist(2,PWRMod:length).
GLOBAL DEPOMod TO LIST("MKS Depot"   , " MKS DPOT ","Wolf_Depotmodule").
GLOBAL habMod TO LIST("MKS Deployable", " MKS DPLY ","USIAnimation","USI_BasicDeployableModule").
GLOBAL CnstMod TO LIST("MKS Constructor"    , " CONSTRCT ","OrbitalKonstructorModule", "ModuleKonFabricator").
GLOBAL DcnstMod TO LIST("MKS Deconstructor", " DCNSTRCT ","ModuleDekonstructor").
GLOBAL ACDMod TO LIST("MKS Academy"  , " MKS ACDMY","spaceacademy").
//OTHER MODS
GLOBAL CapMod TO LIST("Capacitor"    , "CAPACITOR ","DischargeCapacitor").
GLOBAL BDPMod TO LIST("BD Pilot", " BD PILOT ","BDModulePilotAI").
GLOBAL CMMod TO LIST("Countermeasure", "CNTRMSURES","CMDropper").
GLOBAL RadarMod TO LIST("Radar"      , "  RADAR   ","ModuleRadar").
GLOBAL FRNGMod TO LIST("Fairing"     , "  FAIRING ","ModuleProceduralFairing").
GLOBAL WMGRMod TO LIST("Weapon Manager", " WEAPONS  ","MissileFire").

//#endregion
//#region Check BootLoop and Monitor
IF CORE:MESSAGES:EMPTY{}ELSE{
  SET RECEIVED TO CORE:MESSAGES:POP.
    IF RECEIVED:content < 0 {SET loadattempts TO 0.}
    ELSE{SET loadattempts TO 1+RECEIVED:CONTENT.}
}
IF loadattempts > 2 SET config:ipu TO 1000. 
SendBoot().
IF HEIGHT > 1000 SET HEIGHT TO 0.
IF NOT (DEFINED monitorGUID) GLOBAL monitorGUID TO 0.
desktop().
PRINT "LOAD ATTEMPTS:"+loadattempts+"        ("+(3-loadattempts)+" MORE TO TRIGGER BOOTLOOP FIX)" AT (1,heightlim). WAIT loadattempts.
IF dbglog > 0 log2file("LOAD ATTEMPTS:"+loadattempts+"        ("+(3-loadattempts)+" MORE TO TRIGGER BOOTLOOP FIX)").
IF loadattempts > 2 BootLoopFix().
IF file_exists(autofile){GLOBAL LISTIN TO READJSON(SubDirSV + autofile).
    IF NOT (DEFINED monitorselected){
       IF DEFINED listin{
        SET MONITORID TO listin[8].
        IF monitorid > 0 {IF MONITORID:substring(0,7) = "0000000" SET FORCEMON TO MONITORID:substring(7,1):TONUMBER+1.ELSE SET monitorGUID TO listin[8].}
      }
        LOCAL totalMonitors TO ADDONS:kpm:getmonitorcount() - 1.
          FOR index IN range(0, totalMonitors){
             IF forcemon > 0 {
            IF index = forcemon-1 {
              SET monitorGUID TO ADDONS:kpm:getguidshort(index). 
              SET buttons:currentmonitor TO index.
              SET id TO ADDONS:kpm:getguidshort(index).
              GLOBAL monitorselected TO 1. 
              PRINT "MONITOR FORCED TO MON "+index AT (1,heightlim).WAIT 1.
              IF dbglog > 0 log2file("MONITOR FORCED TO MON "+index).
               BREAK. 
            }}
            IF ADDONS:kpm:getguidshort(index) = monitorGUID {
              SET buttons:currentmonitor TO index.
              SET id TO ADDONS:kpm:getguidshort(index).
              GLOBAL monitorselected TO 1.
              PRINT "MONITOR LOADED FROM MEMORY" AT (1,heightlim). SET fastboot TO 1. WAIT 1.
              IF dbglog > 0 log2file("MONITOR LOADED FROM MEMORY").											  
            }
          }
    }
  }
IF NOT (DEFINED monitorselected) {setmonvis().}ELSE{IF monitorselected = 0 setmonvis().}
IF NOT (DEFINED setupdone){loadship().}ELSE{
  IF QUICKREBOOT > 0 {IF file_exists(autofile){loadAutoSettings().}}ELSE {loadship().}}
HudFuction().
    IF loadbkp = 2 { SET LNstp TO 1. SET line TO 1. DESKTOP(). loadship(0). HudFuction().}
//#endregion
//#region Ship Setup
FUNCTION desktop{
  CLEARSCREEN.
  FOR i IN range (0,heightlim){
                     LOCAL po TO "|                                                                              |".
    IF i = 0 OR i = heightlim-1 SET po TO "################################################################################".
    IF i = 8           SET po TO "|                              KERBAL HUD SYSTEM                               |".
    IF i = 9           SET po TO "|                              BY  FUZZYMEEP TWO                               |".
    IF i = 10          SET po TO "|                                VERSION 1.07                                  |".
    IF i = 15          SET po TO "|___________________________________LOADING____________________________________|".
    PRINT po AT (0,i).
}}
FUNCTION LoadShip{
   SpeedBoost().
   IF DbgLog > 0 log2file("LOADSHIP" ).
  LOCAL PARAMETER runop IS 1.
      SET loading TO 0.
    SET loadperstep TO 1.
    SET listinc TO 0.
    LOCAL rc TO 0.
    LOCAL la TO 2-runop.
  IF runop = 1 {DESKTOP(). firststrun().} ELSE SET listinc TO 0.
  FUNCTION firststrun{
    IF DbgLog > 0 log2file("FIRSTRUN" ).
  //#region set lists and tags
    GLOBAL PrtListIn TO SetPartList(SHIP:parts).
    loadbar().
    AutoTag(). //get science part names
      LOCAL prtlstintmp TO LIST().
      FOR prt IN PrtListIn{IF prt:tag <> "" prtlstintmp:ADD(prt).}
      SET PrtListIn TO prtlstintmp:COPY.
    SET lighttag TO makelists(lightMod,"lighttag").
    SET AGTag TO  makelists(AGMod,"AGTag").
    SET FlyTag TO makelists(FlyMod,"FlyTag").
    SET CMDTag TO makelists(CMDMod,"CMDTag").
    SET CntrlTag TO makelists(CntrlMod,"CntrlTag").
    SET engtag TO makelists(engMod,"engtag").
    SET IntTag TO makelists(INTmod,"IntTag").
    SET dcptag TO makelists(dcpMod,"dcptag").
    SET geartag TO makelists(gearMod,"geartag").
    SET chutetag TO makelists(chuteMod,"chutetag").
    SET ladtag TO makelists(ladMod,"ladtag").
    SET baytag TO makelists(bayMod,"baytag").
    SET Docktag TO makelists(DOCKMod,"Docktag").
    SET RWtag TO makelists(RWMod,"RWtag").
    SET slrtag TO makelists(slrMod,"slrtag").
    SET RCStag TO makelists(RCSMod,"RCStag").
    SET drilltag TO makelists(drillMod,"drilltag").
    SET radtag TO makelists(radMod,"radtag").
    SET scitag TO makelists(scimod,"scitag").
    SET anttag TO makelists(antMod,"anttag").
    SET FWtag TO makelists(FWMod,"FWtag").
    SET ISRUTag TO makelists(ISRUMod,"ISRUTag").
    SET Labtag TO makelists(LabMod,"Labtag").
    SET RBTTag TO makelists(RBTMod,"RBTTag").
    SET SMRTtag TO makelists(SMRTMod,"SMRTtag").
    //MKS MOD
    SET MksDrlTag TO makelists(MksDrlMod,"MksDrlTag").
    SET PWRTag TO makelists(PWRMod,"PWRTag").
    SET DEPOTag TO makelists(DEPOMod,"DEPOTag").
    SET habTag TO makelists(habMod,"habTag").
    SET CnstTag TO makelists(CnstMod,"CnstTag").
    SET DcnstTag TO makelists(DcnstMod,"DcnstTag").
    SET ACDTag TO makelists(ACDMod,"ACDTag").
    //OTHER MODS
    SET CapTag TO makelists(CapMod,"CapTag").
    //BDA MOD (KEEP LAST TO MAKE WMGR QUICKLY ACCESSABLE)
    SET BDPtag TO makelists(BDPMod,"BDPtag").
    SET CMtag TO makelists(CMMod,"CMtag").
    SET Radartag TO makelists(RadarMod,"Radartag").
    SET FRNGtag TO makelists(FRNGMod,"FRNGtag").
    SET WMGRtag TO makelists(WMGRMod,"WMGRtag").
    SET itemlist[0] TO listinc.
    ItemListHUD:INSERT(0,listinc).
  }
   LOCAL pc TO 3.
   loadbar().
   IF AutoDspList[0]:length < itemlist[0]  addlist().
    IF (DEFINED listin){IF LOADBKP <> 2 {printrow(GetColor("Loading Auto Settings.","CYN",0)). loadAutoSettings(la).SET LNstp TO LNstp-1.}} loadbar().
    IF LOADBKP = 2 {SET pc TO 2. SET rc TO 1. printrow(GetColor("Loading Backup Settings.","ORN",0)). loadAutoSettings(la). SET LNstp TO LNstp-1.} loadbar(). 
    IF GrpdspList:length < itemlist[0]+1 OR GrpdspList:length < itemlist[0]+1 OR runop = 0 OR rc = 1 OR LFX > 0{
        printrow(GetColor("Adjusting for Loaded Settings.","WHT",0)). dsplistfix().  loadbar().
    }
    IF runop <> 0 OR LOADBKP = 2{
      //set GrpdspList[flytag][1] to 1.
      IF AutoDspList[0]:length < itemlist[0]  addlist().
      printrow(GetColor("Checking Part Availability.","YLW",0)).partcheck(pc). loadbar().
      IF dcptag <> 0{printrow(GetColor("Checking Decoupler Parts.","ylw",0)). DcpGauges(prtTagList[dcptag]).} loadbar().
      printrow(GetColor("Setting Auto Triggers.","WHT",0)).SetAutoTriggers(2). loadbar(). 
      printrow(GetColor("Saving Auto Settings.","PRP",0)). SaveAutoSettings(0). loadbar(). 
      printrow(GetColor("Setting Module Commands.","WHT",0)). SetModules().    loadbar(). 
      printrow(GetColor("Checking Ship Resources.","YLW",0)). ISRUcheck().     loadbar(). 
      printrow(GetColor("Checking Module States.","YLW",0)).  CheckSettings(). loadbar(). 
      printrow(GetColor("Checking Sensor Availability.","YLW",0)). checkmodeavail(). loadbar().
      SET LOADBKP TO 0.
    }
    FOR i IN RANGE(1, 79) {
      PRINT "#" AT (i,16).
    IF FASTBOOT = 0 WAIT.01.
    }
      IF AutoDspList[0]:length < itemlist[0]  addlist().
      GLOBAL ActiveMeter TO LIST().
      FOR TMP IN RANGE (0,ITEMLIST[0]+1) ActiveMeter:ADD(1).
      GLOBAL setupdone TO 1.
      IF DbgLog > 0 log2file("STARTUP DONE").
      IF dbglog = -1{
        log2file("logging resumed").
        SET dbglog TO 4.
      }

  
  //#endregion setup done
    FUNCTION makelists{
      LOCAL PARAMETER ModulesIn, tagnameIn.
      LOCAL typename TO modulesin[0].
      LOCAL HUDname TO modulesin[1].
      LOCAL modules TO modulesin:sublist(2,modulesin:length).
      LOCAL hasmod TO 0.
      IF typename <> "Action Group" AND  typename <> "Flight Control"{
        FOR m IN modules{
          SET hasmod TO SHIP:MODULESNAMED(m).
          IF hasmod:length > 0 BREAK.
        }
      IF hasmod = 0 {IF listinc > 1 loadbar(). RETURN 0.}
      IF DbgLog > 2 log2file("MAKE LIST "+tagnameIn+"-"+LISTTOSTRING(modulesin)).
      GLOBAL tempTAGS TO TAGCHECK(typename,modules).
      }ELSE{
        IF typename = "Action Group"SET tempTAGS TO LIST(16,"AG1","AG2","AG3","AG4","AG5","AG6","AG7","AG8","AG9","AG10", "THROTTLE","RCS","ABORT","GEAR","LIGHTS","BRAKES").
        IF typename = "Flight Control"SET tempTAGS TO LIST(12,"HEADING","PROGRADE", "RETROGRADE", "NORMAL", "ANTI NORMAL", "RADIAL OUT", "RADIAL IN", "TARGET", "ANTI TARGET", "MANEUVER", "STABILITY ASSIST", "STABILITY").
         }
        IF typename = "Command"{SET cmdln TO tempTAGS[0]. IF mjb > 0{ SET temptags TO listadd(temptags,MJEB[0]). SET TEMPTAGS[0] TO tempTAGS:LENGTH-1.}}
      IF tempTAGS[0] = 0{IF listinc > 1 loadbar(). RETURN 0.}
        ELSE{
          SET listinc TO listinc+1. 
          ItemList:ADD(typename).
          prtlist:ADD(LIST(LIST(tagnameIn+"/"+listinc))).
          GrpOpsList:ADD(LIST(0)).
          ItemListHUD:ADD(HUDname).
          prtTagList:ADD(LIST(tempTAGS[0])).
          SET prttaglistR TO "".
        }
        IF listinc > 1 loadbar(). 
        IF tempTAGS[0] <> 0{
          FOR i IN RANGE(1, tempTAGS[0]+1) {
            SET prttaglistR TO prttaglistR+tempTAGS[I]+",".
            prtTagList[listinc]:ADD(tempTAGS[I]).
            LOCAL prt TO LIST().
            FOR m IN modules{
              IF SHIP:MODULESNAMED(m):length > 0 {
                //if dbglog > 2 log2file("         "+"    MODULE:"+m).
                FOR p IN SHIP:PARTSDUBBED(tempTAGS[I]){
                  IF p:HASMODULE(m){
                    //if dbglog > 2 log2file("         "+p).
                    IF typename = "Lights" {
                      
                      IF m="ModuleColorChanger" OR m="ModuleAnimateGeneric"{IF NOT p:getmodule(m):hasaction("toggle lights") SET p TO "".}
                      IF p:typename <> "string" FOR md IN lightmodskp{ IF p:HASMODULE(md) {SET p TO "". BREAK.}}
                    }
                    IF p <>"" AND NOT prt:contains(p)prt:ADD(p).
                  }
                }
              }
            }
            IF typename = "Action Group" prt:ADD(core:part). 
            IF typename = "Flight Control" prt:ADD(core:part). 
            IF typename = "Command" AND mjb > 0 prt:ADD(mjpart).
            prt:insert(0, prt:length). 
            prtList[listinc]:ADD(prt).
          } 
          LOCAL TG TO " Tags". IF tempTAGS[0] = 1 SET TG TO " Tag".
         IF typename ="Experiment" OR typename ="Action Group" OR  typename ="Flight Control" OR  typename ="Command" {printrow(tempTAGS[0]+":"+typename +TG+" Found").}ELSE{printrow(tempTAGS[0]+":"+typename +TG+" Found:"+prttaglistR).}
        }
        loadbar(). 
        IF tempTAGS[0] <> 0{
          dsplists(tempTAGS[0]+1,typename,listinc,1).
          IF typename = "Lights" { PRINT "|       Tagged Lights Found. Lights Will Turn on With Matching Tags" AT (0,LNstp).SET LNstp TO LNstp+1.}
        }
        loadbar().
        FUNCTION TAGCHECK{
          LOCAL PARAMETER tname, ml.
          IF DbgLog > 1 log2file("   TAGCHECK:"+TNAME+" Mods:"+LISTTOSTRING(ml)).
          LOCAL tl TO LIST(). 
          FOR m IN ml{
            LOCAL ModFound TO 0.
            LOCAL MDLGD TO 0.
            LOCAL TGLGD TO 0..
              FOR p IN PrtListIn {
                IF p:HASMODULE(m) {
                  SET ModFound TO 1.
                  LOCAL t TO p:Tag. 
                  IF NOT tl:contains(p:tag) {
                    SET TGLGD TO 0.
                    IF tname = "Converter" {
                      IF p:NAME:contains("fuelcell") SET t TO "".}
                    ELSE{
                    IF tname = "Solar Panel" {
                      IF p:NAME:contains("ISRU") SET t TO "".
                      //set ModFound to 1.
                      }
                    ELSE{
                    IF tname = "Cargo Bay" {
                      IF p:HASMODULE("ModuleProceduralFairing") SET t TO "".}
                    ELSE{
                    IF tname = "Lights"{
                      IF p:HASMODULE("ModuleColorChanger") {IF NOT p:getmodule("ModuleColorChanger"):hasaction("toggle lights") SET t TO "".}
                        ELSE{
                          IF p:HASMODULE("ModuleAnimateGeneric") {IF NOT p:getmodule("ModuleAnimateGeneric"):hasaction("toggle lights") SET t TO "".}
                        }
                          FOR md IN lightmodskp IF p:HASMODULE(md) {SET t TO "". BREAK.}
                      }
                    ELSE{
                    IF tname = "Antenna" {
                      IF p:HASMODULE("ModuleRTAntenna"){IF p:getmodule("ModuleRTAntenna"):hasfield("omni range") OR rtech = 0 {SET t TO "".}}
                      IF p:HASMODULE("ModuleAnimateGeneric"){LOCAL aa TO p:getmodule("ModuleAnimateGeneric"):allactions. FOR a IN aa{IF NOT a:contains("anten") AND NOT p:HASMODULE("ModuleRTAntenna") SET t TO "".}}}
                    ELSE{
                    IF tname = "Gear"{
                      IF p:HASMODULE("ModuleAnimateGeneric"){
                        IF NOT p:HASMODULE("ModuleWheelDeployment"){
                          IF NOT p:getmodule("ModuleAnimateGeneric"):hasaction("toggle leg"){SET t TO "".}}}}
                    ELSE{
                    IF tname = "RCS" {
                      IF p:HASMODULE("ModuleRCSFX"){
                        IF p:getmodule("ModuleRCSFX"):hasevent("show actuation toggles"){p:getmodule("ModuleRCSFX"):doevent("show actuation toggles").}}}
                    ELSE{
                    IF tname = "Engines" {
                      IF p:HASMODULE("ModuleGimbal"){
                        IF p:getmodule("ModuleGimbal"):hasevent("show actuation toggles"){p:getmodule("ModuleGimbal"):doevent("show actuation toggles").}}}
                    ELSE{

                    }}}}}}}}
                    IF t <>"" tl:ADD(t).
                  }
                  IF MDLGD = 0 AND dbglog > 2 {log2file("       MOD:"+M ). SET MDLGD TO 1.}
                  IF dbglog > 2 AND t <>"" {
                    IF TGLGD = 0 {log2file("           TAG:"+t). SET TOUT TO T.}
                    IF P:TAG = TOUT log2file("               "+P ).
                    SET TGLGD TO 1.
                  }
                }
              }
              //if ModFound = 1 break.
              }
          tl:insert(0, tl:length). 
          IF TL:empty{SET TL TO LIST(0).}
          RETURN tl.
        }
        IF tempTAGS[0] = 0{RETURN 0.}ELSE{RETURN listinc.}
    }
    FUNCTION dsplistfix{
      IF DbgLog > 0 log2file("dsplistfix" ).
            SET  GrpOpsList TO LIST(LIST(LIST(0))).
            SET  GrpDspList TO LIST(LIST(LIST(0))).
            SET  GrpDspList2 TO LIST(LIST(LIST(0))).
            SET  GrpDspList3 TO LIST(LIST(LIST(0))).
            SET ItemListHUD TO LIST().
            LOCAL loadp TO 28. IF colorprint > 0{ SET loadp TO loadp+9. PRINT " " AT (80,LNstp-1).}
        FOR I IN Range(1,ItemList[0]+1){
          GrpOpsList:ADD(LIST(0)).
          SET loadp TO loadp+1. PRINT "." AT (loadp,LNstp-1).
          dsplists(prtTagList[I][0]+1, prtList[I][0][0]:split("/")[1]:tonumber,i,2).
        }
        ItemListHUD:insert(0,ItemListHUD:length).
    }
    FUNCTION dsplists{ 
          LOCAL PARAMETER Tgin, typename, lnc, opin. //this is to fix mismatched lists, it looks redundant, but is very important.
            IF opin = 2{
              LOCAL HUDname TO "          ".
              IF typename = lighttag {SET typename TO "Lights". SET HUDname TO  "  LIGHTS  ".}ELSE{
              IF typename = AGtag {SET typename TO "Action Group". SET HUDname TO " ACTN GRP ".}ELSE{
              IF typename = Flytag {SET typename TO "Flight Control". SET HUDname TO "FLGHT CTRL".}ELSE{
              IF typename = CMDTag {SET typename TO "command". SET HUDname TO  " COMMAND  ".}ELSE{
              IF typename = Cntrltag {SET typename TO "control srf". SET HUDname TO  "CNTRL SURF".}ELSE{
              IF typename = engtag {SET typename TO "Engines". SET HUDname TO  " ENGINES  ".}ELSE{
              IF typename = Inttag {SET typename TO "Intake". SET HUDname TO  "  INTAKES ".}ELSE{
              IF typename = dcptag {SET typename TO "Decoupler". SET HUDname TO  "DECOUPLERS".}ELSE{
              IF typename = geartag {SET typename TO "Gear". SET HUDname TO  "   GEAR   ".}ELSE{
              IF typename = chutetag {SET typename TO "Parachute". SET HUDname TO  "PARACHUTES".}ELSE{
              IF typename = ladtag {SET typename TO "Ladder". SET HUDname TO  "  LADDER  ".}ELSE{
              IF typename = baytag {SET typename TO "Cargo Bay". SET HUDname TO  "CARGO BAYS".}ELSE{
              IF typename = Docktag {SET typename TO "Docking Port". SET HUDname TO  "  DOCKING ".}ELSE{
              IF typename = RWtag {SET typename TO "Reaction Wheel". SET HUDname TO  " RCTNWHEEL".}ELSE{
              IF typename = slrtag {SET typename TO "Solar Panel"  . SET HUDname TO  "   POWER  ".}ELSE{
              IF typename = RCStag {SET typename TO "RCS". SET HUDname TO  "   RCS    ".}ELSE{
              IF typename = drilltag {SET typename TO "Drill". SET HUDname TO  "  DRILLS  ".}ELSE{
              IF typename = radtag {SET typename TO "Radiator". SET HUDname TO  " RADIATORS".}ELSE{
              IF typename = scitag {SET typename TO "Experiment". SET HUDname TO  "XPERIMENTS".}ELSE{
              IF typename = anttag {SET typename TO "Antenna". SET HUDname TO  " ANTENNAS ".}ELSE{
              IF typename = FWtag {SET typename TO "Firework". SET HUDname TO  " FIREWRKS ".}ELSE{
              IF typename = ISRUtag {SET typename TO "Converter". SET HUDname TO  "   ISRU   ".}ELSE{
              IF typename = Labtag {SET typename TO "Science Lab". SET HUDname TO  " SCI-LAB  ".}ELSE{
              IF typename = RBTtag {SET typename TO "Robotics". SET HUDname TO  " ROBOTICS ".}ELSE{
              IF typename = SMRTtag {SET typename TO "Smart Parts". SET HUDname TO  " SMRT PRT ".}ELSE{
              //MKS MOD
              IF typename = MksDrltag {SET typename TO "MKS Harvest". SET HUDname TO " MKS HRVST".}ELSE{
              IF typename = PWRtag {SET typename TO "MKS Resources". SET HUDname TO  " MKS RSC  ".}ELSE{
              IF typename = DEPOtag {SET typename TO "MKS Depot". SET HUDname TO  " MKS DPOT ".}ELSE{
              IF typename = habtag {SET typename TO "MKS Deployable". SET HUDname TO  " MKS DPLY ".}ELSE{
              IF typename = Cnsttag {SET typename TO "MKS Constructor". SET HUDname TO  " CONSTRCT ".}ELSE{
              IF typename = Dcnsttag {SET typename TO "MKS Deconstructor". SET HUDname TO  " DCNSTRCT ".}ELSE{
              IF typename = ACDtag {SET typename TO "MKS Academy". SET HUDname TO  " MKS ACDMY".}ELSE{
              //OTHER MODS
              IF typename = Captag {SET typename TO "Capacitor". SET HUDname TO  "CAPACITOR ".}ELSE{
              IF typename = BDPtag {SET typename TO "BD Pilot". SET HUDname TO  " BD PILOT ".}ELSE{
              IF typename = CMtag {SET typename TO "Countermeasure". SET HUDname TO  "CNTRMSURES".}ELSE{
              IF typename = Radartag {SET typename TO "Radar". SET HUDname TO  "  RADAR   ".}ELSE{
              IF typename = FRNGtag {SET typename TO "Fairing". SET HUDname TO  "  FAIRING ".}ELSE{
              IF typename = WMGRtag {SET typename TO "Weapon Manager". SET HUDname TO  " WEAPONS  ".}ELSE{
              }}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}
              ItemListHUD:ADD(HUDname).
            }
            IF DbgLog > 2{ 
              log2file("        dsplist:"+typename ).
              log2file(+"         Tgin:"+Tgin+" typename:"+typename+" lnc:"+lnc+" opin:"+opin ).
            }
          FOR i IN RANGE(1, tgin+1) {
              LOCAL t TO LIST(                             " TURN ON  "," TURN OFF ","          ","          ","          ","          ","          ","          ").  
              IF typename =  "Solar Panel"  {SET t TO LIST("  ENABLE  "," DISABLE  ","  EXTEND  ","  RETRACT ","          ","          ","          ","          ").}ELSE{
              IF typename ="Ladder"
              OR typename = "control srf"   {SET t TO LIST("  EXTEND  "," RETRACT  ","          ","           ","          ","          ","          ","          ").}ELSE{
              IF typename ="Decoupler" {SET t TO      LIST(" DECOUPLE ","DECOUPLED "," XFEED OFF"," XFEED ON "," INFLATE  "," DEFLATE  ","          ","          ").}ELSE{ 
              IF typename ="Antenna" {SET t TO        LIST("  EXTEND  ","  RETRACT ","          ","          ","XMIT DATA ","XMIT DATA ","          ","          ").}ELSE{ 
              IF typename ="Gear" {SET t TO           LIST("  EXTEND  ","  RETRACT ","          ","          ","          ","          ","          ","          ").} ELSE{
              IF typename ="Command" {SET t TO        LIST("CNTRL FROM","CNTRL FROM"," TGL HBRNT"," TGL HBRNT"," CLCT SCI "," CLCT SCI ","          ","          ").} ELSE{
              IF typename ="Cargo Bay" {SET t TO      LIST("BAY CLOSED "," BAY OPEN ","          ","          ","          ","          ","          ","          ").} ELSE{
              IF typename ="Parachute" {SET t TO      LIST("   ARM    ","   ARMED  ","    CUT   ","    CUT   ","          ","          ","          ","          ").} ELSE{
              IF typename ="Drill" {SET t TO          LIST("  EXTEND  ","  RETRACT ","  TOGGLE  ","  TOGGLE  ","          ","          ","          ","          ").} ELSE{
              IF typename ="Experiment"  {SET t TO    LIST(" RUN TEST "," RUN TEST ","  DEPLOY  ","  RETRACT ","          ","          ","          ","          ").} ELSE{
              IF typename ="Lights"      {SET t TO    LIST(" LIGHT OFF"," LIGHT ON "," BLINK OFF"," BLINK ON ","          ","          ","          ","          ").} ELSE{
            IF typename = "Docking Port"{SET t TO    LIST("NOT DOCKED"," SEPERATE ","  EXTEND  ","  RETRACT "," XFEED OFF"," XFEED ON ","          ","          ").} ELSE{
              IF typename = "Converter"  {SET t TO    LIST("  TOGGLE  ","  TOGGLE  ","          ","          ","          ","          ","          ","          ").} ELSE{
              IF typename = "firework"   {SET t TO    LIST("   FIRE   ","   FIRE   ","          ","          ","          ","          ","          ","          ").} ELSE{
              IF typename = "Robotics"   {SET t TO    LIST(" TGL DPLY "," TGL DPLY "," TGL LOCK "," TGL LOCK ","          ","          ","          ","          ").} ELSE{
              IF typename = "Capacitor"  {SET t TO    LIST("DISCHARGE ","DISCHARGE "," CHG ENAB "," CHG ENAB "," CHG DISAB"," CHG DISAB","          ","          ").} ELSE{
              IF typename = "Radar"      {SET t TO    LIST(" TURN ON  "," TURN OFF ","PREV TRGT ","PREV TRGT ","NEXT TRGT ","NEXT TRGT ","          ","          ").} ELSE{
          IF typename = "Reaction Wheel"{SET t TO    LIST(" TURN ON  "," TURN ON  "," TURN OFF "," TURN OFF ","          ","          ","          ","          ").} ELSE{
              IF typename = "Science Lab"{SET t TO    LIST("STRT RSRCH","STOP RSRCH","XMIT SCNCE","XMIT SCNCE","          ","          ","          ","          ").} ELSE{
              IF typename = "Countermeasure"{SET t TO LIST("   FIRE   ","   FIRE   ","          ","          ","          ","          ","          ","          ").} ELSE{
              IF typename = "Fairing"    {SET t TO    LIST(" JETTISON "," JETTISON ","          ","          ","          ","          ","          ","          ").} ELSE{
              IF typename ="MKS Harvest" {SET t TO    LIST("  EXTEND  ","  RETRACT "," STRT DRL "," STOP DRL ","          ","          ","          ","          ").} ELSE{
              IF typename = "MKS Depot"  {SET t TO    LIST(" ESTABLISH","          ","          ","          ","          ","          ","          ","          ").} ELSE{
              IF typename = "MKS Deployable"{SET t TO LIST("  DEPLOY  ","  DEPLOY  ","          ","          ","          ","          ","          ","          ").} ELSE{
              IF typename = "MKS Resources"{SET t TO  LIST("  START   ","   STOP   ","          ","          ","          ","          ","          ","          ").} ELSE{
              IF typename = "MKS Academy"  {SET t TO  LIST("  TRAIN   "," TRAINING "," LEVEL UP "," LEVEL UP ","          ","          ","          ","          ").} ELSE{
            IF typename = "MKS Constructor"{SET t TO  LIST(" CONSTRCT "," CONSTRCT "," FABRICTE "," FABRICTE ","ENAB CNSTR","ENAB CNSTR","          ","          ").} ELSE{
            IF typename ="Flight Control"  {SET t TO LIST(" TURN ON  "," TURN OFF ","          ","          "," DSP HERE ","ALWAYS DSP","          ","          ").} ELSE{
          IF typename = "MKS Deconstructor"{SET t TO LIST(" DECNSTRCT"," DECNSTRCT","          ","          ","          ","          ","          ","          ").} ELSE{
          IF typename = "Weapon Manager"{SET t TO    LIST("   FIRE   ","   FIRE   "," TGL GUARD"," TGL GUARD","  CHF/FLR "," CHF/FLR  ","          ","          ").} ELSE{
          IF typename = "BD Pilot"{       SET t TO    LIST(" TURN ON  "," TURN OFF "," STDBY OFF"," STDBY ON ","  CLAMPED ","UNCLAMPED ","          ","          ").} ELSE{
              IF typename = "Engines" AND i < tgin+1{
                LOCAL k TO i. IF i > tgin-1 SET k TO tgin-1.
                FOR j IN RANGE(1, prtlist[lnc][k][0]) {
                  LOCAL prt2 TO prtlist[lnc][k][J].
                      IF prt2:HASMODULE("MultiModeEngine"){IF NOT t:contains("TOGL MODE "){SET t[2]TO "TOGL MODE ".SET t[3] TO"TOGL MODE ".}}
                      IF prt2:HASMODULE("ModuleGimbal"){IF NOT t:contains(" TGL GMBL "){SET t[4]TO " TGL GMBL ".SET t[5] TO" TGL GMBL ".}}
                      }}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}
              t:insert(0, t:length). 
              GrpOpsList[lnc]:ADD(t).
              
              IF i = 1{
                LOCAL ladd1 TO LIST(1).
                LOCAL ladd3 TO LIST(1).
                LOCAL ladd5 TO LIST(1).
                LOCAL ladd0 TO LIST(t[0]).
                LOCAL laddu0 TO LIST(15).
                LOCAL laddu1 TO LIST(15).
                FOR l IN range (0,tgin+1){
                  ladd0:ADD(0).
                  ladd1:ADD(1).
                  ladd3:ADD(3).
                  ladd5:ADD(5).
                  laddu0:ADD(0).
                  laddu1:ADD(1).
                }
               GrpDspList:ADD(ladd1:COPY).
              GrpDspList2:ADD(ladd3:COPY).
              GrpDspList3:ADD(ladd5:COPY).
              IF opin = 1{
                AutoDspList:ADD(laddu1:COPY).
                autoRstList:ADD(laddu1:COPY).
                AutoValList:ADD(laddu0:COPY).
                AutoRscList:ADD(laddu0:COPY).
                AutoTRGList:ADD(laddu1:COPY).
                AutoRscList[0]:ADD(1).
                AutoTRGList[0]:ADD(laddu0:COPY).
              }
            }
          }
        }
    FUNCTION AutoTag{
      IF DbgLog > 0  log2file("AUTOTAG" ).
     IF colorprint > 0 PRINT "  " AT (80,1).
      PRINT printrow(GetColor("Setting Auto Tags.","WHT",0)).  
      LOCAL loadp TO 17. IF colorprint > 0{ SET loadp TO loadp+9. PRINT " " AT (80,LNstp-1).}
      LOCAL cnt2 TO 0.
          FOR m IN autotaglist{SET loadp TO loadp+1. PRINT "." AT (loadp,LNstp-1).
          IF dbglog > 2 log2file("    Module:"+m).
            SET cnt TO 1.
            IF SHIP:MODULESNAMED(m):length <> 0 {
              FOR prt IN PrtListIn {
                  IF prt:HASMODULE("ModuleScienceExperiment") {
                    LOCAL pm TO prt:GETmodule("ModuleScienceExperiment").
                    IF pm:HASACTION("log pressure data") SET senselist[3] TO 1.
                    IF pm:HASACTION("log gravity data")  SET senselist[1] TO 1.
                    IF pm:HASACTION("log temperature")   SET senselist[4] TO 1.
                    IF pm:HASACTION("log seismic data")  SET senselist[0] TO 1.
                  }
                  IF prt:HASMODULE("ModuleGPS") {
                    IF prt:TAG = ""  SET prt:TAG TO prt:TITLE+cnt.
                    IF prt:GETmodule("ModuleGPS"):HASfield("biome") {SET senselist[5] TO 1. SET BSensor TO prt. }
                  }
                  IF prt:HASMODULE("ModuleDeployableSolarPanel") OR prt:HASMODULE("KopernicusSolarPanel") SET senselist[2] TO 1.
                  IF prt:HASMODULE("CMDropper")  cmlist:ADD(prt).
                IF prt:TAG = "" {
                IF prt:HASMODULE("ModuleGPS") {SET prt:TAG TO prt:TITLE+cnt.}
                ELSE{
                  IF sciModAlt:contains(m){ IF prt:HASMODULE(m) {SET cnt2 TO cnt2+1. SET prt:TAG TO CNT2+":"+prt:TITLE.}}
                  ELSE{
                    IF prt:HASMODULE("CMDropper"){SET prt:TAG TO prt:TITLE.}
                      ELSE{
                        IF prt:HASMODULE(m){
                            LOCAL tgt TO prt:TITLE. 
                            FOR wd IN trimwords SET tgt TO Removespecial(tgt,wd).
                            IF tgt:contains("weapon manager") SET tgt TO tgt:REPLACE("weapon manager", "WM-").
                            SET prt:TAG TO tgt+cnt.
                          SET cnt TO cnt+1.}}}}			 
                          IF dbglog > 2 AND prt:TAG <> "" log2file("      "+prt+"-"+prt:TAG).
                }														
              }
            }
          }
          LOCAL SENSORPRINT TO "Sensors Found:".  
                  IF senselist[3] = 1 SET SENSORPRINT TO SENSORPRINT+"Pressure,".
                  IF senselist[1] = 1 SET SENSORPRINT TO SENSORPRINT+"Gravity,".
                  IF senselist[4] = 1 SET SENSORPRINT TO SENSORPRINT+"Temperature,".
                  IF senselist[0] = 1 SET SENSORPRINT TO SENSORPRINT+"Acceleration,".
                  IF senselist[2] = 1 SET SENSORPRINT TO SENSORPRINT+"Light,".
                  IF SENSORPRINT <> "Sensors Found:" printrow(SENSORPRINT).
                  GLOBAL alltagged TO SHIP:ALLTAGGEDPARTS():COPY.
                  GLOBAL PrtListcur TO SetPartList(SHIP:ALLTAGGEDPARTS(),1).
    }
    FUNCTION checkmodeavail{
                    IF colorprint > 0 PRINT " " AT (80,LNstp-1).
                    IF senselist[3] = 0 SET AutoValList[0][0][3][8]  TO -1.
                    IF senselist[1] = 0 SET AutoValList[0][0][3][11] TO -1. 
                    IF senselist[4] = 0 SET AutoValList[0][0][3][10] TO -1.
                    IF senselist[0] = 0 SET AutoValList[0][0][3][12] TO -1.
                    IF senselist[2] = 0 SET AutoValList[0][0][3][9]  TO -1.
                    IF DCPTAG       = 0 SET AutoValList[0][0][3][15] TO -1.
                    IF senselist[0]+senselist[1]+senselist[2]+senselist[3]+senselist[4]=0 SET senseskp TO 1.
    }
    FUNCTION DcpGauges{
      LOCAL PARAMETER Taglist.
      IF colorprint > 0 PRINT " " AT (80,LNstp-1).
      LOCAL dcpprt TO LIST("").
      LOCAL prt TO 0.
      GLOBAL DcpPrtList TO LIST("0").
      FOR i IN RANGE(1, Taglist[0]+1) {
        DcpPrtList:ADD(LIST()).
        FOR j IN RANGE(1, PrtList[dcptag][I][0]+1) {
            SET prt TO PrtList[dcptag][I][J]. 
           IF prt:HASSUFFIX("children") IF prt:children:empty = FALSE{SET dcpprt TO prt:children.}ELSE{SET dcpprt TO LIST("").}
          IF j=1 DcpPrtList[I]:ADD(PrtList[dcptag][I][0]).
          FOR itm IN dcpprt {
          IF NOT DcpPrtList[I]:contains(itm) AND itm <> "" DcpPrtList[I]:ADD(itm).}
        }
        IF DcpPrtList[I]:length = 1 DcpPrtList[I]:ADD("").
      }
      
    }
    FUNCTION SetModules {
      LOCAL loadp TO 24. IF colorprint > 0{ SET loadp TO loadp+9. PRINT " " AT (80,LNstp-1).}
        LOCAL a TO itemlist[0].
        LOCAL b TO LIST("").
        LOCAL c TO LIST(0,0).
        SET b TO  FillList(b, 12).
        GLOBAL MeterList TO LIST(
          LIST(a,LIST(a),LIST(a)), //meterlist[0][0] = current option name //meterlist[0][1] = Active part Module names //meterlist[0][2] = active part options
          LIST(a),                 //meterlist[1][tagnum] = attached part Module names 
          LIST(a),                 //meterlist[2][tagnum] = attached part options
          LIST(0),                 //meterlist[3][tagnum] = name for report vals when no field to pull 
          LIST(0)).                //meterlist[4][tagnum]1/2 = addon on/off 
        GLOBAL Modulelist TO LIST( // USED TO SUPPORT OLD LIST BASED CODE, WILL REMOVE EVENTUALLY
          LIST(b:COPY), //Modulelist[0][tagnum] =MODULE 1 INFO   (TO SUPPORT OLD CODE AND PARTIALLY RECOGNIZED PARTS) 
          LIST(b:COPY), //Modulelist[1][tagnum] = MODULE 1 INFO  (TO SUPPORT OLD CODE AND PARTIALLY RECOGNIZED PARTS) 
          LIST(b:COPY)). //Modulelist[2][tagnum] = REPORT VALUESS (TO SUPPORT OLD CODE AND PARTIALLY RECOGNIZED PARTS) 
          GLOBAL MtrOps TO LIST(c:COPY).
          GLOBAL ALTVAL TO 0.
        FOR k IN range (1,itemlist[0]+1) {
          IF k < 3 MeterList[0]:ADD(LIST(0)). MeterList[1]:ADD(LIST(0)). MeterList[2]:ADD(LIST(0)).  MeterList[3]:ADD(LIST(0)). MeterList[4]:ADD(LIST(LIST(),LIST())).
          Modulelist[0]:ADD(LIST(b:COPY)). Modulelist[1]:ADD(LIST(b:COPY)). Modulelist[2]:ADD(LIST(b:COPY)).
          MtrOps:ADD(c:COPY).
          }
         GLOBAL MtrSpecList TO LIST("ModuleOverheatDisplay").
              IF DbgLog > 0 log2file("SET MODULES" ).
                        SET loadp TO loadp+1. PRINT "." AT (loadp,LNstp-1).

      GLOBAL  RPTWords TO lexicon(
      "extend", "EXTENDED","retract","RETRACTED","decouple","DECOUPLED","activate","ACTIVATED"      ,"shutdown" ,"SHUT DOWN"       ,"Toggle Mode"        ,"MODE TOGGLED"  ,"toggle gimbal"  ,"GIMBAL TOGGLED","Enable Crossfeed","CROSSFEED ENABLED"
      ,"open","OPENED"    ,"close"  ,"CLOSED"   ,"arm"     ,"ARMED"    ,"disarm"  ,"DISARMED"       ,"cut chute","CHUTE CUT"       ,"deploy chute"       ,"CHUTE DEPLOYED","deploy"         ,"DEPLOYED"      ,"start"           ,"STARTED"
      ,"stop","STOPPED"   , "toggle","TOGGLED","transmit","TRANSMITTED","blink on","BLINK TURNED ON","blink off","BLINK TURNED OFF","discharge capacitor","DISCHARGING   ","enable recharge","CHARGING"      ,"Launch"          , "LAUNCHED"
      ,"Use Minutes", "SWITCHED TO SECONDS"   , "Use Seconds","SWITCHED TO MINUTES","disable recharge", "RECHARGE DISABLED","Reset", "RESET","target PREV","PREVIOUS TARGET","target next","NEXT TARGET","countermeasure","COUNTERMEASURE FIRED"
      ). 


      //good5b check lander
      IF lighttag > 0  {LOCAL ctag TO lighttag.    SET  MeterList[3][ctag] TO "LIGHT".
          SET modulelist[0][ctag] TO LIST("Action"      ,"ModuleLight"           ,"lights on"          ,"lights off"         ,"ModuleLight"             ,"blink on"          ,"blink off"         ).
          SET modulelist[1][ctag] TO LIST("Action"      ,"ModuleNavLight"        ,"turn light on"      ,"turn light off"     ,""                        ,""                  ,""                  ). 
          SET modulelist[2][ctag] TO LIST("light status","light status"          ," TURNED ON "        ," TURNED OFF "       ,"off"                     ," BLINK TURNED  ON "," BLINK TURNED OFF ").
          SET  MeterList[1][ctag] TO TrimModules(lightMod:sublist(2,lightMod:length)).
          SET  MeterList[2][ctag] TO LIST(
            LIST(""                                        ,"blink period","pitch angle", "light emission"),
            LIST("status/light status/blink/light emission","0.2/2/0.1"   ,"0/180/5"    , "False/True/0"),
            LIST("Names"                                   ,""            ,""           , "Inactive/Active/0")).
      } 


      //Good5
      IF CMDtag > 0  {LOCAL ctag TO CMDtag. SET  MeterList[3][ctag] TO "COMMAND".
          SET modulelist[0][ctag] TO LIST("Action" ,"ModuleCommand","control from here","control from here"  ,"ModuleCommand" ,"toggle hibernation"    ,"toggle hibernation"           ,"ModuleScienceContainer","collect all","collect all"               ).
          SET modulelist[1][ctag] TO LIST(""). 
          SET modulelist[2][ctag] TO LIST(" "      ,""             ," CONTROL FROM HERE","CONTROL FROM HERE" ,""              ," HIBERNATTION TOGGLED" ," HIBERNATTION TOGGLED"        ,""                      ," SCIENCE COLLECTED" ," SCIENCE COLLECTED").
          SET  MeterList[1][ctag] TO TrimModules(listadd(CMDMod:sublist(2,CMDMod:length),LIST("ModulePowerCoupler","ModuleOverheatDisplay","ModulePowerDistributor","MKSModule"))).
          SET  MeterList[2][ctag] TO LIST(
            LIST(""                                                                                      ),
            LIST(       "comm signal/comm first hop dist/command state/core temp/thermal efficiency/powercoupler/pdu range/kos disk space/kos average power" ),
            LIST("Values/           /                  /            /          /                  /             /         /               /ec\s            "),
            LIST("style/           /                  /             /Mp-0-0   /Mp-0-100          /              /         /              /                 ")).
      }
      //good5
      IF engtag > 0    {LOCAL ctag TO engtag. SET  MeterList[3][ctag] TO "ENGINE".
          LOCAL fldsout TO       "Status/mode/Gimbal/current rpm/specific impulse/collective/fuel flow/burn time/alternator output".
          LOCAL Stylout TO "Style/      /    /       /Mn-0-1000/                 /          /         /         /                 ".
          LOCAL ValOut  TO "Values/     /    /       /           /s              /          /u        /s        /ec\s".
          SET modulelist[0][ctag] TO LIST("Event"  ,"ModuleEnginesFX"             ,"activate engine"    ,"shutdown engine"    ,"MultiModeEngine"         ,"Toggle Mode"      ,"Toggle Mode"       ,"ModuleGimbal","toggle gimbal" ,"toggle gimbal"  ).
          SET modulelist[1][ctag] TO LIST("Event"  ,"ModuleEngines"               ,"activate engine"    ,"shutdown engine"    ,""                        ,""                 ,""                  ,""             ,""              ,""              ).
          SET modulelist[2][ctag] TO LIST(" "      ,"Status"                      ," ACTIVATED "        ," SHUT DOWN "        ,"mode"                    ," MODE TOGGLED"    ,"MODE TOGGLED"      ,"gimbal"       ,"GIMBAL TOGGLED","GIMBAL TOGGLED").
          SET  MeterList[1][ctag] TO TrimModules(listadd(engMod:sublist(2,engMod:length),LIST("Modulegimbal","ModuleAlternator"))).
          GLOBAL engmods TO TrimModules(engMod:sublist(2,engMod:length-3)).
          SET  MeterList[2][ctag] TO LIST(
            LIST(""      ,"thrust limiter", "Throttle"                    ,"Max RPM"        ,"Steering Response" ,"gimbal"       ,"gimbal limit" ,"pitch"             ,"yaw"               ,"roll"   ),
            LIST(fldsout ,"0/100/1"       ,"false/true/0"                 ,"100/1000/25"    ,"0.0/15/0.1"       , "False/True/0" ,"0/100/1"      , "False/True/0"     , "False/True/0"     , "False/True/0"   ),
            LIST("Names" ,""              ,"Main Throttle/Independent/0"  ,""               ,""                , "free/locked/0" ,""             , "Inactive/Active/0", "Inactive/Active/0", "Inactive/Active/0" ),
            LIST("BotRow5/pitch/yaw/roll"),
            LIST(Stylout),
            LIST(ValOut)).
      }

      //good5a
      IF ladtag > 0    {LOCAL ctag TO ladtag. SET  MeterList[3][ctag] TO "LADDER".
          SET modulelist[0][ctag] TO LIST("Event"  ,"RetractableLadder"           ,"extend ladder"     ,"retract ladder"     ).
          SET modulelist[1][ctag] TO LIST(""       ,""                            ,""                  ,""                   ).
          SET modulelist[2][ctag] TO LIST(" "      ,""                            ," EXTENDED"         ," RETRACTED"         ).
          //set  MeterList[1][ctag] to TrimModules(ladMod:sublist(2,ladMod:length)).
      } 

      //good5a
      IF DcpTag > 0    {LOCAL ctag TO DcpTag. SET  MeterList[3][ctag] TO "DECOUPLER".
          SET modulelist[0][ctag] TO LIST("Event"  ,"ModuleDecouple"              ,"decouple"          ,""                    ,"ModuleToggleCrossfeed"  ,"Enable Crossfeed" , "disable crossfeed" ,"ModuleAnimateGeneric" ,"inflate"         ,"deflate"         ).
          SET modulelist[1][ctag] TO LIST("Event"  ,"ModuleAnchoredDecoupler"     ,"decouple"          ,""                    ,""                       ,""                 ,""                   ,""                     ,""         ,""         ).
          SET modulelist[2][ctag] TO LIST(" "      ,""                            ," DECOUPLED"        ," ATTACHED"           ,""                        ,"CROSSFEED ENABLED","CROSSFEED DISABLED",""                     ," INFLATED"         ," DEFLATED"         ).
          SET meterlist[4][ctag] TO LIST(LIST("jettison"),LIST(),LIST(),LIST(),LIST("inflate","deflate","deploy"),LIST()).
          SET  MeterList[1][ctag] TO TrimModules(listadd(dcpMod:sublist(2,dcpMod:length),LIST("ModuleToggleCrossfeed","ModuleAnimateGeneric","MODULEJETTISON"))).
      }         

      //good5z problems with spring /friction/ steering manual auto display, ksp menu actions not changing doesnt help
      IF geartag > 0   {LOCAL ctag TO geartag.  SET  MeterList[3][ctag] TO "GEAR".
          SET modulelist[0][ctag] TO LIST("Action" ,"ModuleWheelDeployment"       ,"extend/retract"    ,"extend/retract"     ,"ModuleWheelSteering"     ,"toggle steering"  ,"toggle steering"   ,"ModuleWheelSteering" ,"toggle steering"  ,"toggle steering"   ).
          SET modulelist[1][ctag] TO LIST("Event"  ,"ModuleAnimateGeneric"        ,"extend"            ,"retract"            ,""                        ,""                 ,""                  ,""                    ,""                 ,""                  ). 
          SET modulelist[2][ctag] TO LIST("state"  ,"state"                       ," EXTENDED"         ," RETRACTED"         ,"Retracted"               ,""                 ,""                  ,"steering"            ,"STEERING ENABLED" ,"STEERING DISABLED" ).
          SET MeterList[1][ctag] TO TrimModules(listadd(GEARMod:sublist(2,GEARMod:length),LIST("ModuleWheelSuspension","ModuleWheelSteering","ModuleWheelBrakes","ModuleWheelBase"))).
          SET  MeterList[2][ctag] TO LIST(
            LIST(""                               , "steering"          , "steering: direction","steering angle limiter","steering response","brakes"  ,"friction control","spring strength" ,"damper strength"  , "deploy shielded"   ,"drive limiter" ),
            LIST("state/status/steering/motor"    , "False/True/0"      ,"False/True/0"        ,"0/30/1"               ,"0.1/10/0.1"        ,"0/200/10","0.0/10/0.1"      ,"0.05/3/0.05"     ,"0.05/2/0.05"      ,"False/True/0"       ,"0/100/1"       ),
            LIST("Names"                          , "Disabled/Enabled/0","Normal/Inverted/0"   ,""                     , ""                 , ""       , ""               , ""               , ""                , "disabled/enabled/0", ""             )).
      }

      //good5a
      IF baytag > 0    {LOCAL ctag TO baytag. SET  MeterList[3][ctag] TO "BAY".
          SET modulelist[0][ctag] TO LIST("Event"  ,"ModuleAnimateGeneric"        ,"open"              ,"close"      ).
          SET modulelist[1][ctag] TO LIST("Event"  ,"hangar"                      ,"open gates"        ,"close gates"). 
          SET modulelist[2][ctag] TO LIST(" "      ,"STATUS"                      ," OPENED"           ," CLOSED"    ).
          SET  MeterList[1][ctag] TO TrimModules(bayMod:sublist(2,bayMod:length)).
          SET  MeterList[1][ctag] TO TrimModules(listadd(bayMod:sublist(2,bayMod:length),LIST("ModuleAnimateGeneric","SimpleHangarStorage"))).
          //set  MeterList[2][ctag] to LIST(
          //    list(""      ),
          //    list("status/hangar name/vessels/stored mass/stored cost/used volume")).
      } 

      //Good5
      IF chutetag > 0  {LOCAL ctag TO chutetag. SET  MeterList[3][ctag] TO "CHUTE".
          SET modulelist[0][ctag] TO LIST("Action" ,"RealChuteModule"             ,"arm parachute"     ,"disarm parachute"  ,"RealChuteModule"          ,"cut chute"      ,"cut chute"           ,"RealChuteModule","deploy chute","deploy chute").
          SET modulelist[1][ctag] TO LIST("Event"  ,"moduleparachute"             ,"deploy chute"      ,"disarm"             ,"moduleparachute"         ,"cut chute"        ,"cut chute"         ,""               ,""            ,""            ,""). 
          SET modulelist[2][ctag] TO LIST(" "      ,"altitude"                    ," ARMED"            ," DISARMED"          ,"safe to deploy?"         ," CHUTE CUT"       ," CHUTE CUT"        ,""              ).
          SET  MeterList[1][ctag] TO TrimModules(chuteMod:sublist(2,chuteMod:length-1)).//REMOVE -1 AFTER TESTING REALCHUTE
          SET  MeterList[2][ctag] TO LIST(
            LIST(""                                                        ,"min pressure"   ,"altitude"     ,"spread angle"  ,"deploy mode"),
            LIST(       "altitude/min pressure/spread angle/safe to deploy?","0.01/0.75/0.01" ,"50/5000/50"   ,"0/10/1"        ,"0/1/2/-1"),
            LIST("Values/M       /kPa        /            / "               ,"kPa"            ,"M"            ,""              ,""),
            LIST("Names"                                                   ,""               ,""             ,""              ,"safe/risky/immediate/-1")).
      }
      //good5
      IF slrtag > 0    {LOCAL ctag TO slrtag. SET  MeterList[3][ctag] TO "GENERATOR".
          SET modulelist[0][ctag] TO LIST("Event"  ,"ModuleDeployableSolarPanel"   ,"extend Solar Panel" ,"retract Solar Panel" ,"ModuleAnimateGeneric" ,"extend arm"     ,"retract arm").
          SET modulelist[1][ctag] TO LIST("Action" ,"ModuleResourceConverter"       ,"start fuel cell"    ,"STOP fuel cell").
          SET modulelist[2][ctag] TO LIST(" "      ,"Sun exposure"                  ," ENABLED"           ," DISABLED"          ,""                        ," EXTENDED"   ," RETRACTED" ).
          SET  MeterList[1][ctag] TO TrimModules(listadd(slrMod:sublist(2,slrMod:length),LIST("ModuleAnimateGeneric"))).
          SET  MeterList[2][ctag] TO LIST(
              LIST(""                     ),
              LIST("sun exposure/energy flow/generator/efficiency/status")).///fuel cell wont work. bad vals when full
              SET meterlist[4][ctag] TO LIST(LIST("activate"),LIST("shutdown"),LIST("deploy","extend"),LIST("retract")).
      } 

      //good5
      IF drilltag > 0  {LOCAL ctag TO drilltag. SET  MeterList[3][ctag] TO "DRILL".
          SET modulelist[0][ctag] TO LIST("Event" ,"ModuleAnimationGroup"         ,"deploy drill"       ,"retract drill"      ,""                        ,""               ,""                  ,"ModuleOverheatDisplay",""               ,""                  ).
          SET modulelist[1][ctag] TO LIST("Action",""                            ,""                  ,""                   ,"ModuleResourceHarvester" ,"toggle surface harvester" ,"toggle surface harvester", ""                    ,""                  ,""                  ). 
          SET modulelist[2][ctag] TO LIST(" "      ,""                            ," DEPLOYED"          ," RETRACTED"         ,"ore rate"                ," TOGGLED        " ," TOGGLED           ","core temp"            ,""                  ,""                  ).
          SET  MeterList[1][ctag] TO TrimModules(listadd(DrillMod:sublist(2,DrillMod:length),LIST("ModuleOverheatDisplay","ModuleAnimationGroup"))).
          SET  MeterList[2][ctag] TO LIST(
              LIST(""                     ),
              LIST(       "ore rate/core temp/thermal efficiency"),//surface harvester display wont work throws bad values if RC menu not up
              LIST("Style/         /Mp-0-0   /Mp-0-100   ")).
      } 

      //good5
      IF radtag > 0    {LOCAL ctag TO radtag. SET  MeterList[3][ctag] TO "RADIATOR".
          SET modulelist[0][ctag] TO LIST("Event" ,"ModuleDeployableRadiator"     ,"extend radiator"       ,"retract Radiator"       ,"" ,"" ,"").
          SET modulelist[1][ctag] TO LIST(""      ,"ModuleSystemHeatRadiator"     ,"activate radiator"     ,"shutdown radiator"      ,""                        ,""               ,""                  ).
          SET modulelist[2][ctag] TO LIST(" "      ,""                            ," EXTENDED / ACTIVATED" ," RETRACTED / DEACTIVATED" ,"cooling"                 ," ACTIVATED      " ,"DEACTIVATED"       ).
          SET  MeterList[1][ctag] TO TrimModules(RadMod:sublist(2,RadMod:length)).
          SET  MeterList[2][ctag] TO LIST(
              LIST(""                     ),
              LIST(      "cooling/radiator efficiency"),
              LIST("Style/Mp-0-100/Mp-0-100")).
      } 

      //GOOD3 (add collect science to cmd pod //didn't work)
      IF scitag > 0    {LOCAL ctag TO scitag. SET  MeterList[3][ctag] TO "EXPERIMENT".
          SET modulelist[0][ctag] TO LIST("Action","ModuleScienceExperiment"       ,"getname"            ,"getname"            ,""                        ,""               ,""                  ,"ModuleScienceExperiment","delete data"      ," "                  ).
          SET modulelist[1][ctag] TO LIST("Event" ,""                            ,""                  ,""                   ,"ModuleAnimationGroup"   ,"deploy"          ,"retract"            ,"ModuleScienceExperiment","delete data"      ," "                  ).
          SET modulelist[2][ctag] TO LIST(" "     ,""                            ," RUN"               ," DELETED"           ,""                        ,"DEPLOYED"        ,"RETRACTED"          ,""                    ,"DELETED"           ," "                  ).
      } 

      //good5
      IF anttag > 0    {LOCAL ctag TO anttag. SET  MeterList[3][ctag] TO "ANTENNA".
          LOCAL antoff TO "off". IF rtech = 0 SET antoff TO "retracted".
          SET modulelist[0][ctag] TO LIST("Event" ,"ModuleDeployableAntenna"       ,"extend antenna"    ,"retract antenna"    ,"ModuleAnimateGeneric"    ,"extend antennas" ,"retract antennas"   ,"ModuleDataTransmitter","transmit data"    ,"transmit data").
          SET modulelist[1][ctag] TO LIST("Action","ModuleRTAntenna"                 ,"activate"          ,"deactivate"         ,""                        ,""                ,""                   ,""                    ,""                 ,"").
          SET modulelist[2][ctag] TO LIST("Status","Status"                          ," EXTENDED"         ," RETRACTED"         ,antoff                    ,""                ,""                   ,""                    ,""                 ,"").
          SET  MeterList[1][ctag] TO TrimModules(ANTMod:sublist(2,ANTMod:length)).
          SET  MeterList[2][ctag] TO LIST(
              LIST(""                                           ,"Set Target","deactivate at ec %","activate at ec %"),
              LIST("status/target/dish range/omni range/energy" ,"0/0/0/-2"  ,"0/100/1"           ,"0/100/1")).
      }

      //good5
      IF Docktag > 0    {LOCAL ctag TO Docktag.  SET  MeterList[3][ctag] TO "DOCKING PORT".
          SET modulelist[0][ctag] TO LIST("Event" ,"ModuleDockingNode"             ,"undock"            ,"undock"             ,"ModuleAnimateGeneric"    ,"open"              ,"close"              ,"ModuleToggleCrossfeed"    ,"Enable Crossfeed" , "disable crossfeed").
          SET modulelist[1][ctag] TO LIST(""      ,"ModuleGrappleNode"             ,"undock"            ,"undock"             ,""                        ,""                  ,""                   ,""                         ,""                 ,"").
          SET modulelist[2][ctag] TO LIST(" "     ,"Status"                        ," DECOUPLED"        ," ATTACHED"          ,""                        ," OPENED"           ," CLOSED",""         ,""                         ,"CROSSFEED ENABLED","CROSSFEED DISABLED").
          SET MeterList[1][ctag] TO TrimModules(listadd(DockMod:sublist(2,DockMod:length),"ModuleAnimateGeneric")).
          SET MeterList[2][ctag] TO LIST(
              LIST(""                                            ,"docking acquire force","rotation locked"), 
              LIST("status/docking acquire force/rotation locked","0/220/5"               , "false/true/0")).
      }

      //GOOD5
      IF CntrlTag > 0 {LOCAL ctag TO CntrlTag. SET  MeterList[3][ctag] TO "CONTROL SURFACE".
          SET modulelist[0][ctag] TO LIST("Event" ,"ModuleControlSurface"          ,"toggle deploy"     ,"toggle deploy"      ,"ModuleControlSurface"    ,"activate control","deactivate control").
          SET modulelist[1][ctag] TO LIST("Action","SyncModuleControlSurface"      ,"toggle deploy"     ,"toggle deploy"      ,"SyncModuleControlSurface","activate control","deactivate control").
          SET modulelist[2][ctag] TO LIST("Deploy",""                              ," EXTENDED"         ," RETRACTED"          ,"False"                   ," ENABLED"         ," DISABLED").
          SET  MeterList[1][ctag] TO TrimModules(CntrlMod:sublist(2,CntrlMod:length)).
          SET  MeterList[2][ctag] TO  
            LIST(LIST(""                                                          ,"pitch"             ,"yaw"               ,"roll"              ,"authority limiter"  , "deploy angle"   , "deploy direction" ),
            LIST("authority limiter/deploy angle/deploy direction/pitch/yaw/roll" , "False/True/0"     , "False/True/0"     , "False/True/0"     ,"-25/25/1"           , "-25/25/1"       , "False/True/0"         ),
            LIST("Names"                                                          , "Active/Inactive/0", "Active/Inactive/0", "Active/Inactive/0",""                   , ""               , "Normal/Inverted/0"    ),
            LIST("BotRow/pitch/yaw/roll")).
      }

      //good2
      IF ISRUTag > 0    {LOCAL ctag TO ISRUTag. SET  MeterList[3][ctag] TO "CONVERTER".
          SET modulelist[0][ctag] TO LIST("Action" ,"ModuleISRU"                    ,"start isru "       ,"start isru "        ,"ModuleOverheatDisplay").
          SET modulelist[1][ctag] TO LIST(""        ,""                              ,""                  ,""                   ,""                     ).
          SET modulelist[2][ctag] TO LIST(" "       ,""                              ," CONVERTING"       ," NOT CONVERTING"    ,"Core Temp"            ).
      }

      //GOOD5
      IF CapTag > 0     {LOCAL ctag TO CapTag. SET  MeterList[3][ctag] TO "CAPACITOR".
          SET modulelist[0][ctag] TO LIST("Action"  ,"DischargeCapacitor"            ,"discharge capacitor","enable recharge"    ,"DischargeCapacitor"     ,"enable recharge" ,"enable recharge"  ,"DischargeCapacitor","disable recharge","disable recharge").
          SET modulelist[1][ctag] TO LIST(""        ,""                              ,""                    ,""                 ,""                       ,""                ,""                   ,""                ,""                ,"").
          SET modulelist[2][ctag] TO LIST(" "       ,"Status"                        ," DISCHARGING"        ," CHARGING"        ,""                       ," CHARGE ENABLED "," CHARGE ENABLED   ",""                ,"CHARGE DISABLED   ","CHARGE DISABLED   ").
          SET  MeterList[1][ctag] TO TrimModules(CAPMod:sublist(2,CAPMod:length)).
          SET  MeterList[2][ctag] TO LIST(
              LIST(""                     ,"discharge rate"), 
              LIST("status/discharge rate","40/80/1"        ),
              LIST("FuelLeft"             ,"Stored Charge"  )).
      }

      //GOOD5
      IF Radartag > 0    {LOCAL ctag TO Radartag. SET MeterList[3][ctag] TO "RADAR".
          SET modulelist[0][ctag] TO LIST("Event"  ,"ModuleRadar"                   ,"enable radar"      ,"disable radar"      ,""              ,""                ,""                   ,""             ,""         ,""         ).
          SET modulelist[1][ctag] TO LIST("Action" ,""                              ,""                  ,""                   ,"ModuleRadar"   ,"target PREV"    ,"target PREV"         ,"ModuleRadar"  ,"target next" ,"target next"         ).
          SET modulelist[2][ctag] TO LIST(" "      ,"current locks"                 ," RADAR ON"         ," RADAR OFF"         ,""              ," PREVIOUS TARGET"," PREVIOUS TARGET"   ,""             ," NEXT TARGET"," NEXT TARGET"         ).
          SET  MeterList[1][ctag] TO TrimModules(RadarMod:sublist(2,RadarMod:length)).
          SET  MeterList[2][ctag] TO LIST(
              LIST(""                     ),
              LIST("current locks")).
      }

      //good5
      IF Inttag > 0     {LOCAL ctag TO Inttag. SET MeterList[3][ctag] TO "INTAKE".
          SET modulelist[0][ctag] TO LIST("Action" ,"ModuleResourceIntake"          ,"open intake"       ,"close intake"      ,"ModuleResourceIntake"    ,""                  ,""                   ,"ModuleResourceIntake",""         ,""         ).
          SET modulelist[1][ctag] TO LIST(""        ,""                              ,""                  ,""                   ,""                      ,""                  ,""                   ,""                    ,""         ,""         ).
          SET modulelist[2][ctag] TO LIST(""        ,"status"                        ,"INTAKE OPENED     ","INTAKE CLOSED    ","closed"                    ,""                  ,""                   ,"effective air speed" ,""         ,""         ).
          SET  MeterList[1][ctag] TO TrimModules(INTMod:sublist(2,INTMod:length)).
          SET  MeterList[2][ctag] TO LIST(
              LIST(""                     ),
              LIST("status/flow/effective air speed")).
      }

      //GOOD3
      IF FWtag > 0      {LOCAL ctag TO FWtag. SET MeterList[3][ctag] TO "FIREWORK".
          SET modulelist[0][ctag] TO LIST("Event" ,"ModulePartFirework"             ,"Launch"            ,"Launch"  ).
          SET modulelist[1][ctag] TO LIST(""      ,""                              ,""                  ,""        ).
          SET modulelist[2][ctag] TO LIST(" "     ,""                              ,"LAUNCHED"          ,"LAUNCHED").
      }

      //good5
      IF RBTTag > 0      {LOCAL ctag TO RBTTag. SET MeterList[3][ctag] TO "ROBOTIC PART".
          SET modulelist[0][ctag] TO LIST("ACTION","ModuleRoboticServoPiston"      ,"toggle piston"     ,""                    ,"ModuleRoboticServoPiston","toggle locked"           ,""                   ).
          SET modulelist[1][ctag] TO LIST(""       ,""                              ,""                  ,""                    ,""                        ,""                        ,""                   ).
          SET modulelist[2][ctag] TO LIST(" "      ,"current extension"             ,"MOVING"            ,"MOVING"              ,"locked"                  ,"LOCK TOGGLED   "         ,"LOCK TOGGLED       ").
          SET  MeterList[1][ctag] TO TrimModules(listadd(RBTMod:sublist(2,RBTMod:length),"ModuleResourceAutoShiftState")).
          SET MeterList[2][ctag] TO LIST(5).
          FOR md IN rbtMod{
            IF SHIP:modulesnamed(md):length > 0{
              IF md = "ModuleRoboticServoPiston"{
                  MeterList[2][RBTtag]:ADD(LIST(
                  LIST("ModuleRoboticServoPiston/ModuleResourceAutoShiftState","force limit(%)"   , "target extension",  "traverse rate" , "damping" , "locked"     , "motor"              , "on power loss"   , "use percentage"    ,"shutdown electric charge%", "restart electric charge%" ),
                  LIST("current extension/locked/target extension/motor"      ,"0/100/1"          , "0.00/5/.05"      ,  "0.0/2/0.1"     , "0/200/5" ,"False/True/0","False/True/0"        ,"False/True/0"     ,"False/True/0"       ,"0.0/100/0.5"              ,"0.0/100/.05"     ),
                  LIST("Names"                                                ,""                 ,""                 ,""                ,""         ,"No/Yes/0"    ,"Disengaged/Engaged/0","Free/Locked/0"    ,"Disabled/Enabled/0" ,""                         ,""              ))).
              }ELSE{
              IF md = "ModuleRoboticServoRotor"{
                  MeterList[2][RBTtag]:ADD(LIST(
                  LIST("ModuleRoboticServoRotor/ModuleResourceAutoShiftState" ,"torque limit(%)"  , "rpm limit"       ,"rotation direction"           , "invert direction" , "brake"  , "locked"     , "motor"              , "on power loss"   , "use percentage"    ,"shutdown electric charge%", "restart electric charge%" ),
                  LIST("current rpm/locked/rpm limit/motor/rotation direction" ,"0/100/1"         , "0/460/5"         ,"False/True/0"                 , "False/True/0"     , "0/200/5","False/True/0","False/True/0"        ,"False/True/0"     ,"False/True/0"       ,"0.0/100/0.5"              ,"0.0/100/.05"     ),
                  LIST("Names"                                                ,""                 ,""                 ,"clockwise/counterclockwise/0" ,"normal/inverted/0" ,""        ,"No/Yes/0"    ,"Disengaged/Engaged/0","Free/Locked/0"    ,"Disabled/Enabled/0" ,""                         ,""              ))).
              }ELSE{
              IF md = "ModuleRoboticServoHinge"{
                  MeterList[2][RBTtag]:ADD(LIST(
                  LIST("ModuleRoboticServoHinge/ModuleResourceAutoShiftState","torque limit(%)"   , "target angle"    ,  "traverse rate" , "damping" , "locked"     , "motor"              , "on power loss"   , "use percentage"    ,"shutdown electric charge%", "restart electric charge%" ),
                  LIST("current angle/locked/target angle/motor"             ,"0/100/1"           , "-180.0/180/5"    ,  "0/180/1"       , "0/200/5" ,"False/True/0","False/True/0"        ,"False/True/0"     ,"False/True/0"       ,"0.0/100/0.5"              ,"0.0/100/.05"     ),
                  LIST("Names"                                               ,""                  ,""                 ,""                ,""         ,"No/Yes/0"    ,"Disengaged/Engaged/0","Free/Locked/0"    ,"Disabled/Enabled/0" ,""                         ,""              ))).
              }ELSE{
              IF md = "ModuleRoboticRotationServo"{
                  MeterList[2][RBTtag]:ADD(LIST(
                  LIST("ModuleRoboticRotationServo/ModuleResourceAutoShiftState" ,"torque limit(%)", "target angle"   , "invert direction" , "brake"  ,  "traverse rate" , "damping" , "locked"     , "motor"              , "on power loss"   , "use percentage"    ,"shutdown electric charge%", "restart electric charge%" ),
                  LIST("current angle/locked/target angle/motor"                 ,"0/100/1"        , "-180.0/180/5"   , "False/True/0"     , "0/200/5",  "0/180/1"       , "0/200/5" ,"False/True/0","False/True/0"        ,"False/True/0"     ,"False/True/0"       ,"0.0/100/0.5"              ,"0.0/100/.05"     ),
                  LIST("Names"                                                   ,""               ,""                ,"normal/inverted/0" ,""        ,""                ,""         ,"No/Yes/0"    ,"Disengaged/Engaged/0","Free/Locked/0"    ,"Disabled/Enabled/0" ,""                         ,""              ))).
              }ELSE{
                IF md = "ModuleRoboticController"{
                  MeterList[2][RBTtag]:ADD(LIST(
                  LIST("ModuleRoboticController/ModuleResourceAutoShiftState"                   ,"play position", "play speed"       ,"enabled"     , "play/pause"        ,"play direction"   , "loop mode"                             ,"controller priority"),
                  LIST("sequence/play position/play\pause/play speed/loop mode\play direction"  ,"0.0/5/0.1"    , "0/100/1"          ,"False/True/0", "0/1/-1"            ,"0/1/-1"           , "0/1/2/3/-1"                            ,"1/5/1"              ),
                  LIST("Names"                                                                  , ""            ,""                  , ""           , "playing/paused/-1" ,"foward/reverse/-1", "None/Repeat/Ping Pong/None-Restart/-1" ,""                   ))).
                }
              }}}}}}
      }

      //Good5
      IF SMRTtag > 0   {LOCAL ctag TO SMRTtag. SET MeterList[3][ctag] TO "SMART PART".
          SET modulelist[0][ctag] TO LIST("Action"      ,"Stager"                     ,"activate detection" ,"deactivate detection",""     ,""                     ,""                   ,""      ,""      ,""     ).
          SET modulelist[1][ctag] TO LIST("Action"      ,"Timer"                      ,"Start countdown"   ,""                     ,"Timer", "Use Minutes"         , "Use Seconds"       , "Timer", "Reset", "Reset"    ). 
          SET modulelist[2][ctag] TO LIST("Active"      ,""                           ," TURNED ON "       ," TURNED OFF "        ,"False", " SWITCHED TO SECONDS","SWITCHED TO MINUTES",""      ," RESET", " RESET").
                  SET MeterList[1][ctag] TO TrimModules(SMRTMod:sublist(2,SMRTMod:length)).
                  SET MeterList[2][ctag] TO LIST(8).
                  LOCAL groupops TO "0/1/2/3/4/5/6/7/8/9/10/11/12/13/14/15/16/-1".
                  IF agx <> 0{
                    SET groupops TO "stage/Action Group(AGX)/NoAct/NoAct/NoAct/NoAct/NoAct/NoAct/NoAct/NoAct/NoAct/lights/RCS/SAS/BRAKES/ABORT/GEAR/-1".
                  }
                  FOR md IN SMRTMod{
                    IF SHIP:modulesnamed(md):length > 0{
                      IF md = "stager"{
                          MeterList[2][ctag]:ADD(LIST(
                          LIST("Stager"                              ,"percentage", "Group"                                      , "Group:" ,"Active"      ),
                          LIST("active/resource/trigger when/monitor","0/100/1"   , "0/1/2/3/4/5/6/7/8/9/10/11/12/13/14/15/16/-1", "0/250/1","False/True/0"),
                          LIST("Names"                               ,""          , groupops                                     ,""        ,""            ))).
                      }ELSE{
                        IF md = "Altimeter"{ MeterList[2][ctag]:ADD(LIST(
                          LIST("Altimeter"        ,"kilometers","meters"   , "Group"                                      , "Group:" , "use agl"     , "auto reset"  ,"Trigger on"           ,"Active"      ),
                          LIST("active/trigger on","0/1000/25" ,"0/1000/25", "0/1/2/3/4/5/6/7/8/9/10/11/12/13/14/15/16/-1", "0/250/1", "false/True/0", "false/True/0","All/Ascent/Descent/-1","False/True/0"),
                          LIST("Names"            ,""          ,""         , groupops                                     ,""       ,""              ,""             ,""                     ,""            ))).
                      }ELSE{
                        IF md = "SmartOrbit"{ MeterList[2][ctag]:ADD(LIST(
                          LIST("SmartOrbit"       ,"kilometers"  ,"meters"   , "Group"                                      , "Group:", "auto reset"  ,"Trigger on"                   ,"Active"      ),
                          LIST("active/trigger on","0/1000/25"   ,"0/1000/25", "0/1/2/3/4/5/6/7/8/9/10/11/12/13/14/15/16/-1", "0/250/1", "false/True/0","All/Decreasing/Increasing/-1","False/True/0"),
                          LIST("Names"            ,""            ,""         , groupops                                     ,""        ,""             ,""                            ,""            ))).
                      }ELSE{
                          IF md = "SmartSRB"{ MeterList[2][ctag]:ADD(LIST(
                          LIST("SmartSRB"       ,"srb twr %"  , "Group"                                         , "Group:"),
                          LIST("srb twr %"        ,"100/150/5"   , "0/1/2/3/4/5/6/7/8/9/10/11/12/13/14/15/16/-1", "0/250/1"),
                          LIST("Names"            ,""            , groupops                                     ,""))).
                      }ELSE{
                        IF md = "ProxSensor"{ MeterList[2][ctag]:ADD(LIST(
                          LIST("ProxSensor"                        ,"channel"  ,"distance" , "Group"                                      , "Group:", "auto reset"   ,"Trigger on"                ,"Active"      ),
                          LIST("active/channel/distance/trigger on","0/20/1"   ,"0/2000/25", "0/1/2/3/4/5/6/7/8/9/10/11/12/13/14/15/16/-1", "0/250/1", "false/True/0","Both/Departure/Approach/-1","False/True/0"),
                          LIST("Names"                             ,""         ,""         , groupops                                     ,""        ,""             ,""                          ,""            ))).
                        }ELSE{
                        IF md = "Timer"{ MeterList[2][ctag]:ADD(LIST(
                          LIST("Timer"                                ,"seconds","minutes"  , "Group"                                      , "Group:", "auto reset"  ,"Trigger on"                 ,"Active"      ),
                          LIST("Active/remaining time/seconds/minutes","0/120/1","0/360/1"  , "0/1/2/3/4/5/6/7/8/9/10/11/12/13/14/15/16/-1", "0/250/1", "false/True/0","Both/Departure/Approach/-1","False/True/0"),
                          LIST("Names"                                ,""       ,""         , groupops                                     ,""        ,""             ,""                          ,""            ))).
                        }ELSE{
                        IF md = "Speedometer"{ MeterList[2][ctag]:ADD(LIST(
                          LIST("Speedometer"       ,"speed"   ,"speed mode"                           , "Group"                                      , "Group:", "auto reset"  ,"Trigger on"                   ,"Active"      ),
                          LIST("active/trigger on","0/1000/5","surface/horizontal/vertical/orbital/-1", "0/1/2/3/4/5/6/7/8/9/10/11/12/13/14/15/16/-1", "0/250/1", "false/True/0","All/Decreasing/Increasing/-1","False/True/0"),
                          LIST("Names"            ,""        ,""                                      , groupops                                     ,""        ,""             ,""                            ,""            ))).
                        }ELSE{
                        IF md = "DPLD"{ MeterList[2][ctag]:ADD(LIST(
                          LIST("DPLD"             , "Group"                                      , "Group:", "auto reset"  ,"Trigger on"                         ,"Active"      ),
                          LIST("active/trigger on", "0/1/2/3/4/5/6/7/8/9/10/11/12/13/14/15/16/-1", "0/250/1", "false/True/0","KSC Loss/Total Loss/Initialized/-1","False/True/0"),
                          LIST("Names"            , groupops                                     ,""        ,""             ,""                                  ,""            ))).
                      }ELSE{
                        }}}}}}}}
                    }
                  }
      } 
        //GOOD5 
      IF rwtag > 0      {LOCAL ctag TO rwtag. SET MeterList[3][ctag] TO "REACTION WHEEL".
          SET modulelist[0][ctag] TO LIST("Action" ,"ModuleReactionWheel"           ,"activate wheel"  ,"activate wheel"     ,"ModuleReactionWheel"     ,"deactivate wheel","deactivate wheel").
          SET modulelist[1][ctag] TO LIST(""       ,""                              ,""                  ,""                 ,""                        ,""                ,""                ).
          SET modulelist[2][ctag] TO LIST(" "      ,""                              ," ENABLED          "," ENABLED          ",""                       ," DISABLED"       ,"DISABLED"        ).
          SET  MeterList[1][ctag] TO TrimModules(rwMod:sublist(2,rwMod:length)).
          SET  MeterList[2][ctag] TO LIST(
              LIST(""                               ,"reaction wheels"              , "wheel authority"),
              LIST("reaction wheels/wheel authority","0/1/2/-1"                     , "0/100/5"        ),
              LIST("Names"                          ,"normal/SAS Only/Pilot Only/-1","")).
      }

      //GOOD5
      IF RCStag > 0    {LOCAL ctag TO RCStag. SET MeterList[3][ctag] TO "RCS".
          SET modulelist[0][ctag] TO LIST("Action"    ,"ModuleRCSFX"                ,"toggle rcs thrust" ,"toggle rcs thrust").
          SET modulelist[1][ctag] TO LIST(""       ,""                           ,""                     ,""                 ).
          SET modulelist[2][ctag] TO LIST("RCS"    ,""                           ," RCS ON"              ," RCS OFF","False"            ).
          SET MeterList[1][ctag] TO TrimModules(RCSMod:sublist(2,RCSMod:length)).
          SET MeterList[2][ctag] TO  LIST(
            LIST(""                                                 ,"thrust limiter" ,"pitch"             ,"yaw"               ,"roll"              ,"fore/aft"          ,"port/stbd"         ,"dorsal/ventral"    ,"fore by throttle"  ,"always full action"             ),
            LIST("pitch/yaw/roll/fore\aft/port\stbd/dorsal\ventral" ,"0/100/1"        , "False/True/0"     , "False/True/0"     , "False/True/0"     , "False/True/0"     , "False/True/0"     , "False/True/0"     , "False/True/0"     , "False/True/0"     ),
            LIST("Names"                                            ,""               , "Inactive/Active/0", "Inactive/Active/0", "Inactive/Active/0", "Inactive/Active/0", "Inactive/Active/0", "Inactive/Active/0", "Inactive/Active/0", "Inactive/Active/0"),
            LIST("BotRow/pitch/yaw/roll"),
            LIST("BotRow5/fore\aft/port\stbd/dorsal\ventral")
            ).
      }

      //good5
      IF Labtag > 0 {LOCAL ctag TO Labtag. SET MeterList[3][ctag] TO "LAB".
          SET modulelist[0][ctag] TO LIST("Action"  ,"ModuleScienceConverter" ,"START RESEARCH"   ,"STOP RESEARCH"     ,"ModuleScienceLab","transmit science"  ,"transmit science","ModuleScienceContainer","collect all","collect all"  ). 
          SET modulelist[1][ctag] TO LIST("").
          SET modulelist[2][ctag] TO LIST("research","inactive"               ," RESEARCH STARTED"," RESEARCH STOPPED" ,"inactive"        ," XMITTING SCIENCE "," XMITTING SCIENCE ",""                     ," SCIENCE COLLECTED" ," SCIENCE COLLECTED").
          SET  MeterList[1][ctag] TO TrimModules(LabMod:sublist(2,LabMod:length)).
          SET  MeterList[1][ctag] TO TrimModules(listadd( LabMod:sublist(2,LabMod:length),LIST("ModuleScienceContainer"))).
          SET  MeterList[2][ctag] TO LIST(
              LIST(""                               ), 
              LIST("lab status/data/rate/research/science")).
      }

      //good5
      IF CMtag > 0 {LOCAL ctag TO CMtag. SET MeterList[3][ctag] TO "COUNTERMEASURE". 
          SET modulelist[0][ctag] TO LIST("EVENT"     ,"CMDropper"                   ,"fire countermeasure","fire countermeasure").
          SET modulelist[1][ctag] TO LIST(""       ,""                            ,""                      ,""                   ).
          SET modulelist[2][ctag] TO LIST(" "      ,""                            ," COUNTERMEASURE OUT"   ," COUNTERMEASURE OUT").
          SET  MeterList[1][ctag] TO TrimModules(CmMod:sublist(2,CmMod:length)).
          SET  MeterList[2][ctag] TO LIST(
              LIST(""        ), 
              LIST(""        ),////
              LIST("FuelLeft","auto/EMPTY/READY"  )).
      }

      //good2
      IF FRNGtag > 0 {LOCAL ctag TO FRNGtag. SET MeterList[3][ctag] TO "FAIRING".
          SET modulelist[0][ctag] TO LIST("EVENT"     ,"ModuleProceduralFairing"    ,"deploy"              ,"").
          SET modulelist[1][ctag] TO LIST(""       ,""                            ,""                      ,""      ).
          SET modulelist[2][ctag] TO LIST(" "      ,""                            ,"DEPLOYED"                 ," READY",""      ).
      }

      //GOOD5
      IF WMGRtag > 0 {LOCAL ctag TO WMGRtag.  SET MeterList[3][ctag] TO "WEAPON MANAGER".
          SET modulelist[0][ctag] TO LIST("Action"   ,"MissileFire"                 ,"fire guns (hold)","fire guns (hold)"     ,"MissileFire"             ,"toggle guard mode" ,"toggle guard mode" ,"CMDropper" ,"fire countermeasure","fire countermeasure").
          SET modulelist[1][ctag] TO LIST(""       ,""                            ,""                  ,""                     ,""                        ,""                  ,""                  ,""          ,""                   ,""           ).
          SET modulelist[2][ctag] TO LIST(" "      ,"weapon"                      ," FIRING"           ," DISABLED"            ,"Team"                    ," GUARD TOGGLED"    ," GUARD TOGGLED"    ,""          ," COUNTERMEASURE OUT"," COUNTERMEASURE OUT").
          SET MeterList[1][ctag] TO TrimModules(WMGRMod:sublist(2,WMGRMod:length)).
          SET MeterList[2][ctag] TO  LIST(
            LIST(""                           , "Weapon"  ,"missiles/target"),
            LIST("weapon/team/missiles\target", "0/0/0/-2","1/18/1"         )).
      }

      //good5
      IF BDPtag > 0 {LOCAL ctag TO BDPtag. SET MeterList[3][ctag] TO "AI PILOT ".
      LOCAL DSP TO "default alt./min altitude/max speed/mincombatspeed/max g/max aoa".
          SET modulelist[0][ctag] TO LIST("Event"  ,"BDModulePilotAI"           ,"activate pilot"     ,"deactivate pilot"     ,"BDModulePilotAI"         ).
          SET modulelist[1][ctag] TO LIST(""       ,""                          ,""                   ,""                     ,""                        ).
          SET modulelist[2][ctag] TO LIST(" "      ,""                          ," ACTIVATED"         ," DEACTIVATED"         ,""                        ).
          SET  MeterList[1][ctag] TO TrimModules(BDPMod:sublist(2,BDPMod:length)).
          SET  MeterList[2][ctag] TO LIST(
            LIST(""        ,"default alt." ,"min altitude" ,"steer factor"  ,"steer ki"   ,"STEER LIMITER","steer damping"  ,"max speed" ,"takeoff speed" ,"mincombatspeed" ,"idle speed" ,"max g"     ,"max aoa" ,"orbit "               ,"unclamp tuning "      ,"standby mode "),
            LIST(DSP       ,"500/15000/50" ,"150/6000/50"  ,"0.05/1/.05"    ,"0.05/1/.05" ,"0.05/1/.05"   ,"1/8/.5"         ,"20/800/10" ,"10/200/5"      ,"20/200/5"       ,"10/200/5"   ,"2/45/.25"  ,"0/85/.5" , "False/True/0"        , "False/True/0"        , "False/True/0"),
            LIST("AltVal/1","500/100000/50","150/30000/50" ,"0.05/200/.05"  ,"0.05/20/.05","0.05/1/.05"   ,"1/100/.5"       ,"20/3000/10","10/2000/5"     ,"20/2000/5"      ,"10/3000/5"  ,"2/1000/.25","0/180/.5", "False/True/0"        , "False/True/0"        , "False/True/0"), 
            LIST("Names"   ,""             , ""            , ""             , ""          , ""            , ""              , ""         , ""             , ""              , ""          , ""         , ""       , "port(CCW)/stbd(CW)/0", "clamped/unclamped/0" , "off/on/0"    ),
            LIST("STATE-Land/min altitude/takeoff speed/idle speed/mincombatspeed/max g/max aoa")
            ).      
      }
      //if mks = 1{//needs 5
      //good3
      IF MksDrlTag > 0 {LOCAL ctag TO MksDrlTag. SET MeterList[3][ctag] TO "MKS DRILL". 
          SET modulelist[0][ctag] TO LIST("Event"  ,"ModuleAnimationGroup"       ,"deploy"           ,"retract"               ,"usi_harvester"           ,"togle converter"  ,"toggle converter"  ,"mksmodule"    ,""         ,""         ,"ModuleOverheatDisplay" ,""         ,""         ).
          SET modulelist[1][ctag] TO LIST(""       ,""                           ,""                 ,""                      ,""                        ,""                 ,""                  ,""             ,""         ,""         ,""                      ,""         ,""         ).
          SET modulelist[2][ctag] TO LIST(" "      ,""                           ," DEPLOYED"        ," RETRACTED",""                        ,""                 ,""                  ,"governor"     ,""         ,""         ,"Core Temp"             ,""         ,""         ).
          SET  MeterList[1][ctag] TO TrimModules(listadd(MksDrlMod:sublist(2,MksDrlMod:length),LIST("ModuleOverheatDisplay","ModuleAnimationGroup"))).
        //  set  MeterList[2][ctag] to LIST(
        //      list(""                     ),
        //      list(       "ore rate/core temp/thermal efficiency"),
        //      list("Style/         /Mp-0-0   /Mp-0-100   ")).
      }

      //good2                    
      IF DEPOtag > 0 {LOCAL ctag TO DEPOtag. SET MeterList[3][ctag] TO "DEPO".
          SET modulelist[0][ctag] TO LIST("Event"  ,"Wolf_Depotmodule"           ,"establish depot"  ,""                      ).
          SET modulelist[1][ctag] TO LIST(""       ,""                           ,""                 ,""                      ).
          SET modulelist[2][ctag] TO LIST(" "      ,"wolf biome"                 ," DEPOT ESTABLISHED"," DEACTIVATED         ").
          SET  MeterList[1][ctag] TO TrimModules(DEPOMod:sublist(2,DEPOMod:length)).
      }

      //good2
      IF habtag > 0 {LOCAL ctag TO habtag. SET MeterList[3][ctag] TO "HABITAT".
          SET modulelist[0][ctag] TO LIST("Event"   ,"USIAnimation"               ,"toggle module"    ,"toggle module"         ,"USI_BasicDeployableModule",""                 ,""                  ,""             ,""         ,""         ).
          SET modulelist[1][ctag] TO LIST(""       ,"USI_BasicDeployableModule"  ,"deposit resources","deposit resources"     ,""                         ,""                 ,""                  ,""             ,""         ,""         ).
          SET modulelist[2][ctag] TO LIST(" "      ,""                           ,"TOGGLED"          ,"TOGGLED "              ,"paid"                     ,""                 ,""                  ,""             ,""         ,""         ).
          SET  MeterList[1][ctag] TO TrimModules(HABMod:sublist(2,HABMod:length)).
      }

      //good2
      IF CnstTag > 0 {LOCAL ctag TO CnstTag. SET MeterList[3][ctag] TO "KONSTRUCTOR".
          SET modulelist[0][ctag] TO LIST("Event"   ,"OrbitalKonstructorModule"  ,"open konstructor" ,"open konstructor"      ,"ModuleKonFabricator"     ,"konfabricator"    ,"konfabricator"     ,"ModuleKonstructionForeman","enable konstruction","enable konstruction").
          SET modulelist[1][ctag] TO LIST(""       ,""                           ,""              ,""                         ,""                        ,""                 ,""                  ,""                         ,""                   ,""         ).
          SET modulelist[2][ctag] TO LIST(" "      ,""                           ,"TOGGLED"       ,"TOGGLED"                  ,""                        ,""                 ,""                  ,""                         ,""                   ,""         ).
          SET  MeterList[1][ctag] TO TrimModules(CnstMod:sublist(2,CnstMod:length)).
      } 

      //good2
      IF DcnstTag > 0 {LOCAL ctag TO DcnstTag. SET MeterList[3][ctag] TO "DECONSTRUCTOR".
          SET modulelist[0][ctag] TO LIST("Event"   ,"ModuleDekonstructor"      ,"dekonstructor"    ,"dekonstructor").
          SET modulelist[1][ctag] TO LIST(""       ,""                           ,""              ,""                ).
          SET modulelist[2][ctag] TO LIST(" "      ,""                           ,"       "       ,"        "        ).
          SET  MeterList[1][ctag] TO TrimModules(DcnstMod:sublist(2,DcnstMod:length)).
      }

      //good2
      IF PWRtag > 0 {LOCAL ctag TO PWRtag. SET MeterList[3][ctag] TO "CONVERTER".
          SET modulelist[0][ctag] TO LIST("Event"   ,"usi_converter"              ,"start reactor"     ,"stop reactor"         ,"ModuleOverheatDisplay"    ,""                 ,""                 ,"mksmodule"  ,""         ,""         ).
          SET modulelist[1][ctag] TO LIST(""        ,""                           ,""                  ,""                     ,""                         ,""                 ,""                 ,""            ,""           ,""         ).
          SET modulelist[2][ctag] TO LIST(" "       ,""                           ," STARTED"          ," STOPPPED"            ,"Core Temp"                ," "                ,""                 ,"governor"    ,""           ,""         ).
          SET  MeterList[1][ctag] TO TrimModules(PWRMod:sublist(2,PWRMod:length)).
      }

      //good2                                                           
      IF ACDtag > 0 {LOCAL ctag TO ACDtag. SET MeterList[3][ctag] TO "ACADEMY".
          SET modulelist[0][ctag] TO LIST("Event"   ,"spaceacademy"               ,"conduct training"  ,"conduct training"    ,"ModuleExperienceManagement","level up crew"    ,"level up crew").
          SET modulelist[1][ctag] TO LIST(""       ,""                           ,""                  ,""                    ,""                          ,""                 ,""             ).
          SET modulelist[2][ctag] TO LIST(" "      ,""                           ,"             "     ,"             "       ,""                          ," "                ,""             ).
          SET  MeterList[1][ctag] TO TrimModules(listadd(ACDMod:sublist(2,ACDMod:length),LIST("ModuleExperienceManagement"))).
      }
      //}
      //good5
      IF AGtag > 0 {LOCAL ctag TO AGtag. SET MeterList[3][ctag] TO "ACTION GROUP".
          SET modulelist[0][ctag] TO LIST("AG"     ,"AG"  ,""          ,"").
          SET modulelist[1][ctag] TO LIST(""       ,""    ,""          ,""           ).
          SET modulelist[2][ctag] TO LIST(" "      ,""    ," TURNED ON"," TURNED OFF").
      }
      //good5
      IF Flytag > 0 {LOCAL ctag TO Flytag. SET MeterList[3][ctag] TO "FLIGHT CONTROL".
          SET modulelist[0][ctag] TO LIST("AG"     ,"AG"                         ,""           ,"").
          SET modulelist[1][ctag] TO LIST(""       ,""                           ,""          ,""           ).
          SET modulelist[2][ctag] TO LIST(" "      ,""                           ," TURNED ON"," TURNED OFF").
      }
      FOR i IN RANGE(1, ItemList[0]+1) {
        IF modulelist[0][I]:LENGTH < 11 SET modulelist[0][I] TO FillList(modulelist[0][I], 12).
        IF modulelist[1][I]:LENGTH < 11 SET modulelist[1][I] TO FillList(modulelist[1][I], 12).
        IF modulelist[2][I]:LENGTH < 11 SET modulelist[2][I] TO FillList(modulelist[2][I], 12).
      }   
    }
    FUNCTION CheckSettings{LOCAL loadp TO 22. IF colorprint > 0{ SET loadp TO loadp+9. PRINT " " AT (80,LNstp-1).}
    IF DbgLog > 0 log2file("CHECK SETTINGS" ).
    LOCAL CHECKPRT TO 0.
      FOR I IN Range(1,ItemList[0]+1){
        SET loadp TO loadp+1. PRINT "." AT (loadp,LNstp-1).
        FOR j IN Range(1,prtTagList[I][0]+1){
          LOCAL L TO 1.
          IF i = agtag OR i = flytag OR (i = CMDTag AND j > cmdln) BREAK.
          //if i = CMDTag and j > cmdln break. 
          FOR k IN range (1,4){IF K = 4 BREAK.
            LOCAL ModSt TO CheckModule(i,j,k,L).
            IF ModSt <> " "{
              IF modst = "Bad Part" BREAK.
              IF k = 1 SET GrpDspList[I][J] TO ModSt.
              IF k = 2 SET GrpDspList2[I][J] TO ModSt.
              IF k = 3 SET GrpDspList3[I][J] TO ModSt.
            }
            SET L TO 0.
          }
        }
      }
    }
    FUNCTION CheckModule {
      LOCAL PARAMETER Inum, tagnum, optn IS 1, L IS 0.
          FUNCTION SetTrgVars2{
            LOCAL PARAMETER inlst,fldin IS 0, evactin IS 0.
            IF DbgLog > 2 log2file("     SETTRGVARS2-MODULE:"+INLST[0]+" EVENT1ON:"+inlst[1]+" EVENT1OFF:"+inlst[2]).
            IF evactin = 0 SET ea1 TO inlst[4].
              IF inlst[0] <> "" AND inlst[0] <> module2 SET module1 TO inlst[0]. 
              IF inlst[1] <> "" AND inlst[1] <> Event2On  SET Event1On  TO inlst[1].
              IF inlst[2] <> "" AND inlst[2] <> Event2Off SET Event1Off TO inlst[2]. 
            IF fldin > -1{
              IF fldin = 0 SET fld TO " ". ELSE SET fld TO fldin.
            }
          }
          FUNCTION clearev2{
            LOCAL PARAMETER op IS 0.
            IF dbglog > 2 log2file("        CLEAREV2").
            IF op = 0 {
              SET event1on TO "". SET event1off TO "". SET module1 TO "".
              SET event2on TO "". SET event2off TO "". SET module2 TO "".
            }ELSE{
              SET Event1Off TO event1on. SET fld TO " ".
              IF op = 1 {SET Event1Off TO "". SET Event2Off TO "".}
              IF op = 2 {SET Event1On  TO "". SET Event2On  TO "".}
            }
          }
      LOCAL MDL TO modulelist[0][inum].
      LOCAL MDL2 TO modulelist[1][inum].
      LOCAL MDL3 TO modulelist[2][inum].
      LOCAL opset TO 0.
      LOCAL optn3 TO optn*3.
      LOCAL optn2 TO optn3-1.
      LOCAL optn1 TO optn3-2.
      LOCAL CMans TO " ".
      LOCAL Module1 TO MDL[optn1].
      LOCAL Module2 TO MDL2[optn1].
      LOCAL Event1On TO MDL[optn2].
      LOCAL Event1Off TO MDL[optn3].
      LOCAL Event2On TO MDL2[optn2].
      LOCAL Event2Off TO MDL2[optn3].
      LOCAL modov TO "".
      IF Event1On+Event1Off+Event2On+Event2Off <> ""{
        IF DbgLog > 0{ 
          log2file("   CHECK MODULE-"+ITEMLIST[Inum]+"("+Inum+")"+PRTTAGLIST[Inum][tagnum]+"("+tagnum+")-"+optn ).
          IF dbglog > 2{
            log2file("     modulesPri:-"+LISTTOSTRING(MDL) ).
            log2file("     modulesAlt:-"+LISTTOSTRING(MDL2) ).
            log2file("     Report Val:-"+LISTTOSTRING(MDL3) ).
          }
        }
      IF MeterList[1][inum][0] <> 0 SET modov TO TrimModules2(MeterList[1][inum],inum,tagnum).
          IF inum = AGTag {SET opset TO 1.
            IF tagnum = 1  AND ag1  = TRUE {SET opset TO 2.}ELSE{
            IF tagnum = 2  AND ag2  = TRUE {SET opset TO 2.}ELSE{
            IF tagnum = 3  AND ag3  = TRUE {SET opset TO 2.}ELSE{
            IF tagnum = 4  AND ag4  = TRUE {SET opset TO 2.}ELSE{
            IF tagnum = 5  AND ag5  = TRUE {SET opset TO 2.}ELSE{
            IF tagnum = 6  AND ag6  = TRUE {SET opset TO 2.}ELSE{
            IF tagnum = 7  AND ag7  = TRUE {SET opset TO 2.}ELSE{
            IF tagnum = 8  AND ag8  = TRUE {SET opset TO 2.}ELSE{
            IF tagnum = 9  AND ag9  = TRUE {SET opset TO 2.}ELSE{
            IF tagnum = 10 AND ag10 = TRUE {SET opset TO 2.}ELSE{
            IF tagnum = 11 AND THROTTLE > 0 {SET opset TO 2.}ELSE{
            IF tagnum = 12 AND RCS = TRUE {SET opset TO 2.}ELSE{
            IF tagnum = 13 AND ABORT = TRUE {SET opset TO 2.}ELSE{
            IF tagnum = 14 AND GEAR = TRUE {SET opset TO 2.}ELSE{
            IF tagnum = 15 AND LIGHTS = TRUE {SET opset TO 2.}ELSE{
            IF tagnum = 16 AND BRAKES = TRUE {SET opset TO 2.}
            }}}}}}}}}}}}}}}
          }
          ELSE{
          IF inum = FlyTag {
            SET opset TO 1.
            IF tagnum = 1 {IF steeringmanager:enabled = TRUE SET OPSET TO 2.}
            ELSE{
              IF sasmode =  Removespecial(prtTagList[Flytag][tagnum]," ") AND SAS = TRUE {SET opset TO 2. SET StrLock TO tagnum.}
            }
          }
          ELSE{
        LOCAL pl TO prtList[inum][tagnum].
        SET pl TO pl:sublist(1, pl:length).
        LOCAL Pnum TO "".
        IF L = 1 {SET Pnum TO getgoodpart(inum,tagnum,2). SET CHECKPRT TO prtlist[inum][tagnum][pnum].}
        IF pnum = 0 {IF dbglog > 0 log2file("     NO GOOD PART"). RETURN "Bad Part".}
        LOCAL p TO CHECKPRT.
        LOCAL fld TO mdl3[0]. 
        LOCAL op TO mdl3[4]. 
        LOCAL ea1 TO MDL[0].
        LOCAL ea2 TO MDL2[0]. 
            IF inum = lighttag{
          SET PRFX TO "LIGHT ".
          IF P:HASMODULE("modulecommand") OR optn > 1 SET fld TO " ".
          IF optn = 1{
            LOCAL ccc TO              getactions("Actions"+Pnum,MeterList[1][inum],inum, tagnum,optn,1,LIST("on"),LIST("off")).
            IF  ccc[3] = 0 SET ccc TO getactions("Actions"+Pnum,MeterList[1][inum],inum, tagnum,optn,5,LIST("on"),LIST("off")).
            IF  ccc[3] = 0 OR ccc[0] = "moduleanimategeneric" {
              SET ccc TO getactions("Actions"+Pnum,MeterList[1][inum],inum, tagnum,optn,2,LIST("toggle light"),LIST("toggle light")).
              IF ccc[3] > 0 {SET ccc[3] TO getactions("OnOff"+Pnum,MeterList[1][inum],inum, tagnum,optn,3,LIST("on"),LIST("off")).}
            }
            IF  ccc[3] > 0 {
              clearev2().
              SetTrgVars2(CCC,-1).
              IF ccc[0] = "moduleanimategeneric" {
                SET Event1Off TO Event1On. 
                SET fld TO " ".    
                clearev2(ccc[3]).         
                IF ccc[3] = 1 {SET Event1Off TO "". SET Event2Off TO "".}
                IF ccc[3] = 2 {SET Event1On TO "". SET Event2On TO "".}
              }
            }
          }
        }
            ELSE{
            IF inum = ENGtag {
              IF optn = 1 {
                clearev2().
                LOCAL lon TO LIST("on", "activate").
                LOCAL loff TO LIST("off","shutdown").
                LOCAL Elst TO MeterList[1][inum].
                IF p:HASMODULE("FSengineBladed"){IF getEvAct(p,"FSengineBladed","Status",30,-1,2):contains("inactive") SET loff TO LIST(""). ELSE SET lon TO LIST("").}
                ELSE{
                    IF p:HASSUFFIX("modes") IF P:modes:length > 1 IF NOT P:primarymode SET Elst TO LIST("MultiModeEngine").
                    IF p:HASSUFFIX("ignition"){IF p:ignition = FALSE {SET loff TO LIST(""). SET OPSET TO 1.} ELSE {SET lon TO LIST(""). SET OPSET TO 2.}}  
                }
                LOCAL ccc TO getactions("Actions"+Pnum,Elst,inum,tagnum,optn,3,lon,loff,2).
                IF  ccc[3] > 0 SetTrgVars2(CCC,-1).
              }
              IF optn = 3 {
                IF p:HASMODULE("ModuleGimbal"){SET fld TO "GIMBAL". SET op TO FALSE. SET ea1 TO "Action".SET ea2 TO "Action".}
                IF p:HASMODULE("FSswitchEngineThrustTransform"){
                    LOCAL ccc TO getactions("Actions"+Pnum,LIST("FSswitchEngineThrustTransform"),inum, tagnum,optn,3,LIST("reverse"),LIST("normal"),2).
                    IF  ccc[3] > 0 SetTrgVars2(CCC,-1).
                }
              }
            }
            ELSE{
            IF inum = geartag{
            IF pl[0]:HASMODULE(module2) SET fld TO " ".
            IF getactions("OnOff"+Pnum,AnimModAlt ,inum, tagnum,1,1,LIST("extend"),LIST("retract")) <> 0{
              LOCAL ccc TO getactions("Actions"+Pnum,AnimModAlt,inum, tagnum,optn,1,LIST("extend"),LIST("retract")).
              IF  ccc[3] > 0 SetTrgVars2(CCC,-1).
            }
            }
            ELSE{
            IF inum = PWRTag {
              LOCAL fl TO "".
              SET fl TO prtlist[pwrtag][tagnum][1]:getmodule("usi_converter"):allfieldnames[0]. 
              SET Event1On TO "start"+fl. 
              SET Event1Off TO "stop"+fl.
            }
            ELSE{
            IF inum = dcptag{
              IF optn = 1{
              LOCAL ct TO 0.
                FOR pt IN pl {
                  FOR md IN DcpModAlt{
                    IF pt:HASMODULE(md){SET ct TO ct+1.
                      IF ct = 1 SET module1 TO md. 
                      IF ct = 2 SET module2 TO md.
                  }
                }
                }
              }

            }
            ELSE{
            IF inum = CNTRLtag {
              IF  p:HASMODULE("ModuleAeroSurface")SET module1 TO "ModuleAeroSurface".
            }
            ELSE{
            IF inum = Docktag {
              IF optn = 1 IF p:HASSUFFIX("HASPARTNER") IF p:HASPARTNER = TRUE RETURN 2. ELSE RETURN 1.
              IF optn = 2 IF p:HASSUFFIX("STATE") IF p:STATE ="DISABLED" RETURN 3.
            }ELSE{
            IF mks = 1 {
              IF inum = MksDrlTag {
                LOCAL ccc TO getactions("Actions"+Pnum,LIST("usi_harvester"),inum, tagnum, optn, 0,LIST("start","activate"),LIST("stop","deactivate"),2).
                clearev2().
                IF  ccc[3] > 0 SetTrgVars2(CCC,-1).
                }
            }
          }}}}}}}
            IF modov = "" SET modsout TO LIST(module1,module2). ELSE SET modsout TO modov.
            IF fld <>" "{ 
              LOCAL ddd TO getactions("Actions"+Pnum,modsout,inum, tagnum,optn,4,LIST(fld),LIST("zzz"),2).
              SET opset TO ddd[3].
              SET module1 TO ddd[0]. 
              SET module2 TO "".
              SET fld TO ddd[1]. 
              LOCAL FldVal TO ddd[2]. 
              IF FldVal = op SET opset TO 1. ELSE SET opset TO 2. 
              IF modov = "" SET modsout TO LIST(module1,module2).
            }
                ELSE{
                IF opset = 0 {IF ea1 = "Event" OR ea2 = "Event"   SET opset TO getactions("OnOff"+Pnum,modsout,inum, tagnum,optn,1,LIST(Event1On,Event2On),LIST(Event1Off,Event2Off),2).}
                IF opset = 0 {IF ea1 = "Action" OR ea2 = "Action" SET opset TO getactions("OnOff"+Pnum,modsout,inum, tagnum,optn,2,LIST(Event1On,Event2On),LIST(Event1Off,Event2Off),2).}
                IF opset = 0 {                                    SET opset TO getactions("OnOff"+Pnum,modsout,inum, tagnum,optn,3,LIST(Event1On,Event2On),LIST(Event1Off,Event2Off),2).}
                  }}}
                  IF opset = 1 {
                    IF optn =1  SET CMans TO 1.
                    IF optn =2  SET CMans TO 3.
                    IF optn =3  SET CMans TO 5.
                    SET ANS2 TO "OFF".
                  }
                  IF opset = 2 {                  
                    IF optn =1  SET CMans TO 2.
                    IF optn =2  SET CMans TO 4.
                    IF optn =3  SET CMans TO 6.
                    SET ANS2 TO "ON".
                  }
                  IF dbglog > 2{
                    log2file("      "+"Module1:"+ MDL[optn1]+" Module2:"+ MDL2[optn1] ).
                    log2file("      "+" Event2On:"+ MDL2[optn2]+" Event2Off:"+ MDL2[optn3]).
                    log2file("      "+" Event1On:"+ MDL[optn2]+" Event1Off:"+ MDL[optn3]).
                  IF DbgLog > 1 AND CMANS:TYPENAME <> "STRING" log2file("      "+mdl3[CMans]+"("+ANS2+")").
                }
      
    }  
                RETURN CMans.
      }
  }
FUNCTION printrow{
      LOCAL PARAMETER var, wt IS 2.
      SET lns TO FLOOR((var:length/(widthlim-2))+1).
      IF  LNstp = 8 OR LNstp = 7 {
        PRINT "                                        " AT (20,8). 
        PRINT "                                        " AT (20,9). 
        PRINT "                                        " AT (20,10). 
      }
      IF LNstp = 14 OR LNstp+lns > 14 {
      IF wt = 0 RETURN 1. ELSE PRINT "More in "+wt+" seconds..." AT (1,LNstp). 
      IF (FASTBOOT = 0 AND loadattempts < 3) OR wt <> 2 WAIT wt. 
      IF wt = 2{
      FOR z IN range(1,LNstp+1) PRINT "|"+Bigempty2+"|" AT(0,z). 
      SET LNstp TO 1.
      }
      }
      PRINT var AT (1,LNstp).
      IF DbgLog > 0 log2file("   PRINTROW:"+var ).
      SET LNstp TO LNstp+lns.
      RETURN 0.
    }
FUNCTION ISRUcheck{
      IF colorprint > 0 PRINT " " AT (80,LNstp-1).
      IF DbgLog > 2 log2file("   ISRUcheck and settings lists" ).
      IF ISRUTag <> 0 {
      SET isruoptlst TO LIST().
      LOCAL pt TO prtList[ISRUTag][1][1].
          FOR mdls IN pt:modules {
            LOCAL t TO pt:getmodule(mdls):allfieldnames.
            IF t:length > 0 IF NOT isruoptlst:contains(t[0]) isruoptlst:ADD(t[0]).
          }
      isruoptlst:insert(0, isruoptlst:length).}
        IF PWRTag <> 0 SET mks TO 1.
        IF HABTag <> 0 SET mks TO 1.
        IF DEPOTag <> 0 SET mks TO 1.
        IF MksDrlTag <> 0 SET mks TO 1.

        //set Control Surface Limits
        IF CntrlTag > 0 {
          IF DbgLog > 1 log2file("      setting Control Surface Limits" ).
          LOCAL ladd TO LIST(0).
          FOR i IN range(0,CntrlFldList:length) ladd:ADD(0).
          GLOBAL CNTRLLimLst TO LIST(ladd:COPY).
          FOR t IN range(1,prtTagList[CntrlTag][0]+1){
            IF DbgLog > 1 log2file("            TAG:"+prttaglist[cntrltag][t]+"("+t+")").
            CNTRLLimLst:ADD(ladd:COPY).
            FOR m IN MeterList[1][CntrlTag] {
              LOCAL p TO prtlist[CntrlTag][t][getgoodpart(CntrlTag,t)].
              IF p:HASMODULE(m){
              IF DbgLog > 1 log2file("              MOD:"+m+":"+p).
                LOCAL act TO 0.
                LOCAL cnt TO 0.
                FOR fld IN CntrlFldList{
                  IF DbgLog > 1 log2file("                FIELD:"+fld ).
                  SET CNTRLLimLst[t][0] TO ROUND(getEvAct(p,M,FLD,30,-1,3),0).
                  IF DbgLog > 1 log2file("                    INIT("+prttaglist[CntrlTag][T]+")set to :"+CNTRLLimLst[t][0]).
                  SET cnt TO cnt+1.
                  LOCAL trg TO 0.
                FOR k IN range (0,200){
                SET trg TO trg+50.
                  SET act TO CEILING(getEvAct(p,M,FLD,40,trg,3),0).
                    IF trg > act {
                      SET CNTRLLimLst[t][cnt] TO act. 
                      getEvAct(p,M,FLD,40,CNTRLLimLst[t][0],3).
                      IF DbgLog > 1 log2file("                    MAX("+prttaglist[CntrlTag][T]+")set to :"+CNTRLLimLst[t][cnt]).
                      BREAK.
                    }
                  }
                }
              }
            }
          }
        }
      //set DCP PARTS
      GLOBAL DcpXtraMod TO LIST().
      FOR itm IN LIST(MeterList[1][ENGTag],MeterList[1][Chutetag],MeterList[1][CntrlTag]){
       IF itm:istype("list") FOR itm2 IN itm{DcpXtraMod:ADD(itm2).}
      }
      LOCAL rscl TO getRSCList(SHIP:RESOURCES,2).
      GLOBAL rsclist TO rscl[0].
      GLOBAL RscNum TO rscl[1].
      GLOBAL rsclist2 TO rscl[2].
      GLOBAL prsclist TO LIST("").
      

}
FUNCTION SetPartList{
LOCAL PARAMETER lin, OPT2 IS 0.
IF dbglog > 1 log2file("    SET PART LIST").
SET checktime TO TIME:SECONDS.
LOCAL prtltmp TO LIST().
  IF OPT2 = 1 {SET lin TO CheckAttached(lin).}
FOR prt IN lin{
  IF prt:tag <> "" OR opt2 = 0{
    IF dbglog > 2 log2file("        PART:"+prt).
    LOCAL opt TO checkdcp(prt,"payload").
    IF IsPayload[0] = 0 AND opt[0] = 0 prtltmp:ADD(prt).
    IF IsPayload[0] = 1 AND opt[0] = 1 prtltmp:ADD(prt).
  }
}
RETURN prtltmp.
}
FUNCTION getRSCList{
  LOCAL PARAMETER lin, opt IS 0. 
  IF dbglog > 0 log2file("    GET RESOURCE LIST").
  IF dbglog > 1 FOR itm IN lin log2file("     "+itm).
  LOCAL count TO 0.
  LOCAL loadp TO 23. IF colorprint > 0{ SET loadp TO loadp+9. PRINT " " AT (80,LNstp-1).}
  LOCAL RscL TO LIST().
  LOCAL RscL2 TO LIST().
  LOCAL RscN TO lexicon().
  FOR RSC IN lin{
        IF opt = 2 {SET loadp TO loadp+1. PRINT "." AT (loadp,LNstp-1).}
      IF rsc:NAME = "ElectricCharge" {RscL:ADD(LIST(rsc:NAME, "Electric Charge",rsc:CAPACITY,count)). RscN:ADD(rsc:NAME,count). IF OPT > 0 SET ecmax TO rsc:CAPACITY.}ELSE{
      IF rsc:NAME = "IntakeAir" {RscL:ADD(LIST(rsc:NAME, "Intake Air",rsc:CAPACITY,count)). RscN:ADD(rsc:NAME,count).  IF OPT > 0  SET airmax TO rsc:CAPACITY.}ELSE{          
      IF rsc:NAME = "XenonGas" {RscL:ADD(LIST(rsc:NAME, "Xenon Gas",rsc:CAPACITY,count)). RscN:ADD(rsc:NAME,count).}ELSE{
      IF rsc:NAME = "LiquidHydrogen" {RscL:ADD(LIST(rsc:NAME, "Liquid Hydrogen",rsc:CAPACITY,count)). RscN:ADD(rsc:NAME,count).}ELSE{
      IF rsc:NAME = "LiquidOxygen" {RscL:ADD(LIST(rsc:NAME, "Liquid Oxygen",rsc:CAPACITY,count)). RscN:ADD(rsc:NAME,count).}ELSE{
      IF rsc:NAME = "LiquidFuel" {RscL:ADD(LIST(rsc:NAME, "Liquid Fuel",rsc:CAPACITY,count)). RscN:ADD(rsc:NAME,count).}ELSE{
      IF rsc:NAME = "SolidFuel" {RscL:ADD(LIST(rsc:NAME, "Solid Fuel",rsc:CAPACITY,count)). RscN:ADD(rsc:NAME,count).}ELSE{
        IF mks = 1{
          IF rsc:NAME = "EnrichedUranium" {RscL:ADD(LIST(rsc:NAME, "Enriched Uranium",rsc:CAPACITY,count)). RscN:ADD(rsc:NAME,count).}ELSE{
          IF rsc:NAME = "ColonySupplies" {RscL:ADD(LIST(rsc:NAME, "Colony Supplies",rsc:CAPACITY,count)). RscN:ADD(rsc:NAME,count).}ELSE{
          IF rsc:NAME = "SpecialisedParts" {RscL:ADD(LIST(rsc:NAME, "Specialised Parts",rsc:CAPACITY,count)). RscN:ADD(rsc:NAME,count).}ELSE{
          IF rsc:NAME = "MaterialKits" {RscL:ADD(LIST(rsc:NAME, "Material Kits",rsc:CAPACITY,count)). RscN:ADD(rsc:NAME,count).}ELSE{
          IF rsc:NAME = "RefinedExotics" {RscL:ADD(LIST(rsc:NAME, "Refined Exotics",rsc:CAPACITY,count)). RscN:ADD(rsc:NAME,count).}ELSE{
          IF rsc:NAME = "DepletedFuel" {RscL:ADD(LIST(rsc:NAME, "Depleted Fuel",rsc:CAPACITY,count)). RscN:ADD(rsc:NAME,count).}ELSE{
          IF rsc:NAME = "DepletedUranium" {RscL:ADD(LIST(rsc:NAME, "Depleted Uranium",rsc:CAPACITY,count)). RscN:ADD(rsc:NAME,count).}ELSE{
          IF rsc:NAME = "MetallicOre" {RscL:ADD(LIST(rsc:NAME, "Metallic Ore",rsc:CAPACITY,count)). RscN:ADD(rsc:NAME,count).}ELSE{
          IF rsc:NAME = "ExoticMinerals" {RscL:ADD(LIST(rsc:NAME, "Exotic Minerals",rsc:CAPACITY,count)). RscN:ADD(rsc:NAME,count).}ELSE{
          IF rsc:NAME = "RareMetals" {RscL:ADD(LIST(rsc:NAME, "Rare Metals",rsc:CAPACITY,count)). RscN:ADD(rsc:NAME,count).}ELSE{
          IF rsc:NAME = "SpecializedParts" {RscL:ADD(LIST(rsc:NAME, "Specialized Parts",rsc:CAPACITY,count)). RscN:ADD(rsc:NAME,count).}
          ELSE{RscL:ADD(LIST( rsc:NAME, rsc:NAME,rsc:CAPACITY,count)). RscN:ADD(rsc:NAME,count).}}}}}}}}}}}
        }ELSE{ RscL:ADD(LIST( rsc:NAME, rsc:NAME,rsc:CAPACITY,count)). RscN:ADD(rsc:NAME,count).}}}}}}}}
        Rscl2:ADD(RSCL[count][1]).
    SET count TO count+1.
  }
  RETURN LIST(rscl,RscN,RscL2).
}
FUNCTION loadbar{
SET LOADING TO LOADING+loadperstep.
FOR st IN range(1,loading) PRINT "#" AT (st,16).
    IF LOADING > widthlim-3 {PRINTLINE("",0,16). SET LOADING TO 0.}
}
//#endregion
//#region Auto Functions
FUNCTION SetAutoTriggers{ 
  IF DbgLog > 0 log2file("SET AUTO TRIGGERS:" ).
  LOCAL PARAMETER op IS 1.
  GLOBAL AutoItemLst TO LIST(0). 
  GLOBAL AutotagLstUP TO LIST(0). 
  GLOBAL AutotagLstDN TO LIST(0).  
  GLOBAL AutotagLstNAUP TO LIST(0).
  GLOBAL AutotagLstNADN TO LIST(0).     
  GLOBAL AutoLst TO LIST(0).
  LOCAL loadp TO 21.  IF colorprint > 0{ SET loadp TO loadp+9. PRINT " " AT (80,LNstp-1).}
  FOR j IN range(1,MODESHRT:LENGTH){AutoLst:ADD(LIST(0)). AutoItemLst:ADD(LIST(0)).
  IF op = 2 {SET loadp TO loadp+1. PRINT "." AT (loadp,LNstp-1).}
  IF dbglog > 1 log2file("    "+MODELONG[j]). 
  FOR k IN range (1,5){AutoItemLst[J]:ADD(LIST(0)). AutoLst[J]:ADD(LIST(0)).}
    FOR u IN range(1,3){
      IF u = 3 BREAK.
      FOR i IN range (1,itemlist[0]+1){AutoLst[J][u]:ADD(LIST(0)). AutoLst[J][u+2]:ADD(LIST(0)).
        FOR t IN range (1,prtTAGList[I][0]+1){IF t = 1 AND U = 1 AND j = 1{AutotagLstUP:ADD(LIST(0)). AutotagLstDN:ADD(LIST(0)). AutotagLstNAUP:ADD(LIST(0)). AutotagLstNADN:ADD(LIST(0)).}
          IF AutovalList[I][T] <> 0 AND abs(AutoDspList[I][T]) = j{
            IF U = 1 {
              IF AutovalList[I][T] > 0 {
                IF AutoDspList[I][T] > 1 {
                  AutoLst[J][U][I]:ADD(ABS(AutovalList[I][T])).
                  IF NOT AutotagLstUP[I]:contains(t) AutotagLstUP[I]:ADD(t).
                  IF NOT AutoItemLst[J][U]:contains(i) AutoItemLst[J][U]:ADD(i).
                }ELSE{
                    AutoLst[J][U+2][I]:ADD(ABS(AutovalList[I][T])).
                    IF NOT AutotagLstNAUP[I]:contains(t) AutotagLstNAUP[I]:ADD(t).
                    IF NOT AutoItemLst[J][U+2]:contains(i) AutoItemLst[J][U+2]:ADD(i). 
                }
              }
            }ELSE{
              IF U = 2 {
                IF AutovalList[I][T] < 0 {
                  IF AutoDspList[I][T] > 1 {
                    AutoLst[J][U][I]:ADD(ABS(AutovalList[I][T])).
                    IF NOT AutotagLstDN[I]:contains(t) AutotagLstDN[I]:ADD(t).
                    IF NOT AutoItemLst[J][U]:contains(i) AutoItemLst[J][U]:ADD(i). 
                  }ELSE{
                    AutoLst[J][U+2][I]:ADD(ABS(AutovalList[I][T])).
                    IF NOT AutotagLstNADN[I]:contains(t) AutotagLstNADN[I]:ADD(t).
                    IF NOT AutoItemLst[J][U+2]:contains(i) AutoItemLst[J][U+2]:ADD(i). 
                  }
                }
              }
            }     
          }
      }
    }
  }
}
setAutoMinMax().
}
FUNCTION UpdateAutoTriggers{
  LOCAL PARAMETER Updnnum, ModeNum, ItmNum, TgNum, opt IS 0.
              IF dbglog > 0{
                log2file("UPDATEAUTOTRIGGERS:"+Removespecial(MODELONG[modenum])).
                log2file("   Updnnum:"+Updnnum+"-ModeNum:"+ModeNum+"-ItmNum:"+ItmNum+"-TgNum:"+TgNum+"-opt:"+opt ).
                IF dbglog > 1{
                  log2file("   UpdateAutoTriggers (autoRstList[ItmNum][TgNum]("+autoRstList[ItmNum][TgNum]+"),AutoDspList[ItmNum][TgNum]("+AutoDspList[ItmNum][TgNum]+"),ItmNum("+ItmNum+"),TgNum("+TgNum+"))." ).
                  log2file("   IF AutovalList[ItmNum][TgNum] > 0:"+ AutovalList[ItmNum][TgNum] ).
                  log2file("   if AutoDspList[ItmNum][TgNum] > 1 and AutoDspList[ItmNum][TgNum] = ModeNum " ).
                  log2file("   if "+AutoDspList[ItmNum][TgNum]+" > 1 and "+AutoDspList[ItmNum][TgNum]+" = "+ModeNum ).
                  log2file("   AutoLst["+ModeNum+"][1]["+ItmNum+"]:"+LISTTOSTRING(AutoLst[ModeNum][1][ItmNum]) ).
                  log2file("   AutoLst["+ModeNum+"][2]["+ItmNum+"]:"+LISTTOSTRING(AutoLst[ModeNum][2][ItmNum]) ).
                  log2file("   AutoLst["+ModeNum+"][3]["+ItmNum+"]:"+LISTTOSTRING(AutoLst[ModeNum][3][ItmNum]) ).
                  log2file("   AutoLst["+ModeNum+"][4]["+ItmNum+"]:"+LISTTOSTRING(AutoLst[ModeNum][4][ItmNum]) ).
                  IF AutotagLstUP[ItmNum]:length > 1 log2file("    AutotagLstUP["+ItmNum+"]:"+LISTTOSTRING(AutotagLstUP[ItmNum]) ).
                  IF AutotagLstDN[ItmNum]:length > 1 log2file("    AutotagLstDN["+ItmNum+"]:"+LISTTOSTRING(AutotagLstDN[ItmNum]) ).
                  IF  AutotagLstNAup[ItmNum]:length > 1 log2file("   AutotagLstNAup["+ItmNum+"]:"+LISTTOSTRING(AutotagLstNAup[ItmNum]) ).
                  IF  AutotagLstNADN[ItmNum]:length > 1 log2file("   AutotagLstNADN["+ItmNum+"]:"+LISTTOSTRING(AutotagLstNADN[ItmNum]) ).
                }
              }
            IF AutoDspList[ItmNum][TgNum] > 1 AND AutoDspList[ItmNum][TgNum] = ModeNum AND AutovalList[ItmNum][TgNum] <> 0{
              IF NOT AutoLst[ModeNum][Updnnum][ItmNum]:contains(ABS(AutovalList[ItmNum][TgNum])) AutoLst[ModeNum][Updnnum][ItmNum]:ADD(ABS(AutovalList[ItmNum][TgNum])).
              IF NOT AutoItemLst[ModeNum][Updnnum]:contains(ItmNum) AutoItemLst[ModeNum][Updnnum]:ADD(ItmNum).
              IF AutovalList[ItmNum][TgNum] > 0 {
                IF NOT AutotagLstUP[ItmNum]:contains(TgNum) AutotagLstUP[ItmNum]:ADD(TgNum).
                IF AutotagLstDN[ItmNum]:contains(TgNum) AutotagLstDN[ItmNum]:REMOVE(AutotagLstDN[ItmNum]:find(TgNum)).
              }
              IF  AutovalList[ItmNum][TgNum] < 0 {
                IF NOT AutotagLstDN[ItmNum]:contains(TgNum) AutotagLstDN[ItmNum]:ADD(TgNum).
                IF AutotagLstUP[ItmNum]:contains(TgNum) AutotagLstUP[ItmNum]:REMOVE(AutotagLstUP[ItmNum]:find(TgNum)).
              }
              IF AutotagLstNADN[ItmNum]:contains(TgNum) AutotagLstNADN[ItmNum]:REMOVE(AutotagLstNADN[ItmNum]:find(TgNum)).
              IF AutotagLstNAup[ItmNum]:contains(TgNum) AutotagLstNAup[ItmNum]:REMOVE(AutotagLstNAup[ItmNum]:find(TgNum)).
            }
                IF DbgLog > 1{
                  log2file("  post update triggers").
                  IF AutotagLstUP[ItmNum]:length > 1 log2file("    AutotagLstUP["+ItmNum+"]:"+LISTTOSTRING(AutotagLstUP[ItmNum]) ).
                  IF AutotagLstDN[ItmNum]:length > 1 log2file("    AutotagLstDN["+ItmNum+"]:"+LISTTOSTRING(AutotagLstDN[ItmNum]) ).
                  IF  AutotagLstNAup[ItmNum]:length > 1 log2file("   AutotagLstNAup["+ItmNum+"]:"+LISTTOSTRING(AutotagLstNAup[ItmNum]) ).
                  IF  AutotagLstNADN[ItmNum]:length > 1 log2file("   AutotagLstNADN["+ItmNum+"]:"+LISTTOSTRING(AutotagLstNADN[ItmNum]) ).
                }

      IF opt = 0 UpdateAutoMinMax(ModeNum). ELSE setAutoMinMax(). //maybe check length to to fulll update on values with values using autotaglist lengths..
}
FUNCTION checkautotrigger{
  LOCAL PARAMETER inlist.
  FOR itm IN inlist IF itm <> 0 RETURN 1.
  RETURN 0.
}
FUNCTION setAutoMinMax{
  IF dbglog > 0 log2file("SET AUTO MIN MAX"). 
        SET SpdTrgsUP TO  minmax(AutoLst[2][1],"SpdTrgsUP").  SET SpdTrgsDN TO  minmax(AutoLst[2][2],"SpdTrgsDN"). 
        SET AltTrgsUP TO  minmax(AutoLst[3][1],"AltTrgsUP").  SET AltTrgsDN TO  minmax(AutoLst[3][2],"AltTrgsDN"). 
        SET AGLTrgsUP TO  minmax(AutoLst[4][1],"AGLTrgsUP").  SET AGLTrgsDN TO  minmax(AutoLst[4][2],"AGLTrgsDN"). 
        SET ECTrgsUP TO   minmax(AutoLst[5][1],"ECTrgsUP").  SET ECTrgsDN TO   minmax(AutoLst[5][2],"ECTrgsDN"). 
        SET RSCTrgsUP TO  minmax(AutoLst[6][1],"RSCTrgsUP").  SET RSCTrgsDN TO  minmax(AutoLst[6][2],"RSCTrgsDN"). 
        SET ThrtTrgsUP TO minmax(AutoLst[7][1],"ThrtTrgsUP").  SET ThrtTrgsDN TO minmax(AutoLst[7][2],"ThrtTrgsDN").    
        SET PresTrgsUP TO minmax(AutoLst[8][1],"PresTrgsUP").  SET PresTrgsDN TO minmax(AutoLst[8][2],"PresTrgsDN").  
        SET SunTrgsUP  TO minmax(AutoLst[9][1],"SunTrgsUP").  SET SunTrgsDN  TO minmax(AutoLst[9][2],"SunTrgsDN").  
        SET TempTrgsUP TO minmax(AutoLst[10][1],"TempTrgsUP"). SET TempTrgsDN TO minmax(AutoLst[10][2],"TempTrgsDN"). 
        SET GravTrgsUP TO minmax(AutoLst[11][1],"GravTrgsUP"). SET GravTrgsDN TO minmax(AutoLst[11][2],"GravTrgsDN"). 
        SET AccTrgsUP  TO minmax(AutoLst[12][1],"AccTrgsUP"). SET AccTrgsDN  TO minmax(AutoLst[12][2],"AccTrgsDN"). 
        SET TWRTrgsUP  TO minmax(AutoLst[13][1],"TWRTrgsUP"). SET TWRTrgsDN  TO minmax(AutoLst[13][2],"TWRTrgsDN"). 
        SET StsTrgsUP  TO minmax(AutoLst[14][1],"StsTrgsUP"). SET StsTrgsDN  TO minmax(AutoLst[14][2],"StsTrgsDN"). SET StsTrgs TO GetSTSList(AutoLst[14][1]). 
        SET FuelTrgsUP TO minmax(AutoLst[15][1],"FuelTrgsUP"). SET FuelTrgsDN TO minmax(AutoLst[15][2],"FuelTrgsDN").
        logtrgs().
}
FUNCTION UpdateAutoMinMax{
  LOCAL PARAMETER mdnm. 
                IF DbgLog > 0 log2file("       UPDATE AUTO MIN MAX - "+ MODELONG[mdnm] ).               
  IF mdnm = 2 { SET SpdTrgsUP TO  minmax(AutoLst[2][1],"SpdTrgsUP").  SET SpdTrgsDN TO  minmax(AutoLst[2][2],"SpdTrgsDN").}ELSE{
  IF mdnm = 3 { SET AltTrgsUP TO  minmax(AutoLst[3][1],"AltTrgsUP").  SET AltTrgsDN TO  minmax(AutoLst[3][2],"AltTrgsDN").}ELSE{
  IF mdnm = 4 { SET AGLTrgsUP TO  minmax(AutoLst[4][1],"AGLTrgsUP").  SET AGLTrgsDN TO  minmax(AutoLst[4][2],"AGLTrgsDN").}ELSE{
  IF mdnm = 5 { SET ECTrgsUP TO   minmax(AutoLst[5][1],"ECTrgsUP").  SET ECTrgsDN TO   minmax(AutoLst[5][2],"ECTrgsDN").}ELSE{
  IF mdnm = 6 { SET RSCTrgsUP TO  minmax(AutoLst[6][1],"RSCTrgsUP").  SET RSCTrgsDN TO  minmax(AutoLst[6][2],"RSCTrgsDN").}ELSE{
  IF mdnm = 7 { SET ThrtTrgsUP TO minmax(AutoLst[7][1],"ThrtTrgsUP").  SET ThrtTrgsDN TO minmax(AutoLst[7][2],"ThrtTrgsDN").}ELSE{
  IF mdnm = 8 { SET PresTrgsUP TO minmax(AutoLst[8][1],"PresTrgsUP").  SET PresTrgsDN TO minmax(AutoLst[8][2],"PresTrgsDN").}ELSE{
  IF mdnm = 9 { SET SunTrgsUP  TO minmax(AutoLst[9][1],"SunTrgsUP").  SET SunTrgsDN  TO minmax(AutoLst[9][2],"SunTrgsDN").}ELSE{
  IF mdnm = 10{ SET TempTrgsUP TO minmax(AutoLst[10][1],"TempTrgsUP"). SET TempTrgsDN TO minmax(AutoLst[10][2],"TempTrgsDN").}ELSE{
  IF mdnm = 11{ SET GravTrgsUP TO minmax(AutoLst[11][1],"GravTrgsUP"). SET GravTrgsDN TO minmax(AutoLst[11][2],"GravTrgsDN").}ELSE{
  IF mdnm = 12{ SET AccTrgsUP  TO minmax(AutoLst[12][1],"AccTrgsUP"). SET AccTrgsDN  TO minmax(AutoLst[12][2],"AccTrgsDN").}ELSE{
  IF mdnm = 13{ SET TWRTrgsUP  TO minmax(AutoLst[13][1],"TWRTrgsUP"). SET TWRTrgsDN  TO minmax(AutoLst[13][2],"TWRTrgsDN").}ELSE{
  IF mdnm = 14{ SET StsTrgsUP  TO minmax(AutoLst[14][1],"StsTrgsUP"). SET StsTrgsDN  TO minmax(AutoLst[14][2],"StsTrgsDN"). SET StsTrgs TO GetSTSList(AutoLst[14][1]).}ELSE{
  IF mdnm = 15{ SET FuelTrgsUP TO minmax(AutoLst[15][1],"FuelTrgsUP"). SET FuelTrgsDN TO minmax(AutoLst[15][2],"FuelTrgsDN").}}}}}}}}}}}}}}
  logtrgs().
}
FUNCTION logtrgs{
        IF dbglog > 1{
          log2file("        SpdTrgsUP:"+LISTTOSTRING(SpdTrgsUP) +" SpdTrgsDN:"+LISTTOSTRING(SpdTrgsDN) ). 
          log2file("        AltTrgsUP:"+LISTTOSTRING(AltTrgsUP) +" AltTrgsDN:"+LISTTOSTRING(AltTrgsDN) ). 
          log2file("        AGLTrgsUP:"+LISTTOSTRING(AGLTrgsUP) +" AGLTrgsDN:"+LISTTOSTRING(AGLTrgsDN) ). 
          log2file("        ECTrgsUP:"+LISTTOSTRING(ECTrgsUP) +" ECTrgsDN:"+LISTTOSTRING(ECTrgsDN) ). 
          log2file("        RSCTrgsUP:"+LISTTOSTRING(RSCTrgsUP) +" RSCTrgsDN:"+LISTTOSTRING(RSCTrgsDN) ). 
          log2file("        ThrtTrgsUP:"+LISTTOSTRING(ThrtTrgsUP) +" ThrtTrgsDN:"+LISTTOSTRING(ThrtTrgsDN) ).
          log2file("        PresTrgsUP:"+LISTTOSTRING(PresTrgsUP) +" PresTrgsDN:"+LISTTOSTRING(PresTrgsDN) ).
          log2file("        SunTrgsUP:"+LISTTOSTRING(SunTrgsUP)  +" SunTrgsDN:"+LISTTOSTRING(SunTrgsDN)  ).
          log2file("        TempTrgsUP:"+LISTTOSTRING(TempTrgsUP) +" TempTrgsDN:"+LISTTOSTRING(TempTrgsDN) ). 
          log2file("        GravTrgsUP:"+LISTTOSTRING(GravTrgsUP) +" GravTrgsDN:"+LISTTOSTRING(GravTrgsDN) ). 
          log2file("        AccTrgsUP:"+LISTTOSTRING(AccTrgsUP)  +" AccTrgsDN:"+LISTTOSTRING(AccTrgsDN)  ). 
          log2file("        TWRTrgsUP:"+LISTTOSTRING(TWRTrgsUP)  +" TWRTrgsDN:"+LISTTOSTRING(TWRTrgsDN)  ). 
          log2file("        StsTrgsUP:"+LISTTOSTRING(StsTrgsUP)  +" StsTrgsDN:"+LISTTOSTRING(StsTrgsDN)  ). 
          log2file("        FuelTrgsUP:"+LISTTOSTRING(FuelTrgsUP) +" FuelTrgsDN:"+LISTTOSTRING(FuelTrgsDN) ).
        }
}
FUNCTION minmax {
  LOCAL PARAMETER listL, MD IS "".
  LOCAL Lmin TO 9999999.
  LOCAL Lmax TO 0.
  LOCAL FND TO 0.
  FOR i IN range (1,itemlist[0]+1){ 
    LOCAL ML TO 0.
    FOR item IN listL[I]{
      IF item<> 0 {
        IF dbglog > 2{
          IF ML = 0 log2file("           MIN MAX:"+MD).
          log2file("              "+ITEMLIST[I]+":"+ITEM).
          SET ML TO 1.
          SET FND TO 1.
        }
        IF item < Lmin SET Lmin TO item.
        IF item > Lmax SET Lmax TO item.
      }
    }
  }
  IF lmin = 9999999 SET lmin TO 0.
  IF lmin = LMAX SET lmin TO 0. 
  IF dbglog > 2 AND FND > 0 log2file("                  MIN:MAX "+Lmin+":"+Lmax).
  RETURN LIST(Lmin, Lmax).  
}
FUNCTION GetSTSList {
  PARAMETER listL.
  LOCAL LST IS LIST(0).
  FOR i IN range (1,itemlist[0]+1){FOR item IN listL[I]{IF item<> 0 {IF NOT LST:CONTAINS(ITEM) LST:ADD(item).}}}
  RETURN lst.  
}
FUNCTION loadAutoSettings{
  IF dbglog > 0 log2file("    LOAD AUTO SETTINGS").
  PARAMETER opt IS 0.
  LOCAL loadp TO 22.  IF colorprint > 0{ SET loadp TO loadp+9. PRINT " " AT (80,LNstp-1).}
    LOCAL refreshTimer TO TIME:SECONDS.
    LOCAL isdone TO 0.
          LOCAL line TO 2.
          LOCAL rchhk TO 0.
    IF loadbkp = 2 {IF file_exists(autofileBAK) SET LISTIN TO READJSON(SubDirSV + autofileBAK). SET line TO 1.}
      GLOBAL AutoDspListTMP TO  listin[0]:COPY.
      GLOBAL  autovallistTMP TO listin[1]:COPY.
      GLOBAL  itemlistTMP TO    listin[2]:COPY.
      GLOBAL  prttaglistTMP TO  listin[3]:COPY.
      GLOBAL  prtlistTMP TO     listin[4]:COPY.
      GLOBAL autoRstListTMP TO  listin[5]:COPY.
      GLOBAL AutoRscListTMP TO  listin[6]:COPY.
      GLOBAL AutoTRGListTMP TO  listin[7]:COPY.
          LOCAL lstoff TO 0.
          FOR i IN range (1,itemlistTMP[0]+1){
            //if dbglog > 2 log2file("      ITEM:"+I).
            FOR T IN range (1,prtTAGListTMP[I][0]+1){IF t = prtTAGListTMP[I][0]+1 BREAK.
            //if dbglog > 2 log2file("         TAG:"+T).
              LOCAL tmplist TO SHIP:partstagged(prttaglistTMP[I][T]).
                FOR P IN RANGE (1,prtListTMP[I][T][0]+1){IF p = prtListTMP[I][T][0]+1 BREAK.
                //if dbglog > 2 log2file("          PART:"+p).
                  LOCAL tmplist2 TO tmplist:COPY.
                  LOCAL i1 TO itemlist:find(itemlistTMP[I]).
                  //if dbglog > 2 log2file("          ITEM1:"+I1).
                  IF i1 > 0 {
                  LOCAL t1 TO prttagList[I1]:find(prttagListTMP[I][T]).
                    //if dbglog > 2 log2file("              tag1:"+T1).
                      IF t1 > 0 {
                        IF prtlist[I1][T1][0]+1 > p{
                          IF prtlisttmp[I][T][P]:tostring = core:part:tostring AND prtlist[I1][T1][P]:tostring <> core:part:tostring 
                            SET prtlisttmp[I][T][P] TO prtlist[I1][T1][P].
                        }
                      }
                  }
                  IF tmplist2:tostring:contains(prtlisttmp[I][T][P]:tostring){
                    FOR itm IN tmplist2{
                      IF itm:tostring = prtlisttmp[I][T][P]:tostring{
                        SET prtlisttmp[I][T][P] TO itm.
                        tmplist:REMOVE(tmplist:find(itm)).
                        BREAK.
                      }
                    }
                  }
                }
              }
          }
      IF itemlistTMP[0] > itemlist[0] SET lstoff TO 1. 
      ELSE IF itemlistTMP[0] < itemlist[0] SET lstoff TO 2.
      IF lstoff = 0 {IF dbglog > 2 log2file("    ITEMLIST LENGTH:"+itemlist[0]+"="+itemlisttmp[0]).
        FOR i2 IN range(1,itemlist[0]+1){
          IF prtTagListTMP[i2][0]      > prtTagList[i2][0] SET lstoff TO 1. 
          ELSE IF prtTagListTMP[i2][0] < prtTagList[i2][0] SET lstoff TO 2.
          IF autotrglisttmp[0][i2]:length      > autotrglist[0][i2]:length SET lstoff TO 1. 
          ELSE IF autotrglisttmp[0][i2]:length < autotrglist[0][i2]:length SET lstoff TO 2.
          IF lstoff = 0 {IF dbglog > 2 log2file("      TAGLIST LENGTH:"+itemlist[i2]+"("+i2+"):"+prtTagList[i2][0]+"="+prtTagListTMP[i2][0]).
            FOR t2 IN range(1,prtTagList[i2][0]+1){
              IF dbglog > 2 log2file("        TAG:"+T2+":"+prtTagList[i2][T2]+"="+prtTagListTMP[i2][T2]).
              IF prtlistTMP[i2][t2][0]      > prtlist[i2][t2][0] SET lstoff TO 1. 
              ELSE IF prtlistTMP[i2][t2][0] < prtlist[i2][t2][0] SET lstoff TO 2.
              IF lstoff <> 0 BREAK. ELSE IF dbglog > 2 log2file("         PARTLIST LENGTH:"+prtTagList[i2][t2]+"("+t2+"):"+prtlist[i2][t2][0]+"="+prtlistTMP[i2][t2][0]).
            }
          }
          IF lstoff <> 0 BREAK.
        }
      }

      IF lstoff > 0 evenlist(lstoff).
      IF loadattempts > 0 SET autovallisttmp[0][0][0] TO autovallisttmp[0][0][0]+loadattempts.
      LOCAL imin TO MIN(itemlistTMP[0], itemlist[0]).
      LOCAL tmin IS MIN(prttaglistTMP[1][0], prttaglist[1][0]).
      LOCAL pmin IS MIN(prtlistTMP[1][1][0], prtlist[1][1][0]).
      LOCAL ioff TO 0. LOCAL toff TO 0. LOCAL poff TO 0. 
      IF imin < MAX(itemlistTMP[0], itemlist[0]) SET ioff TO 1.
      IF tmin < MAX(prttaglistTMP[1][0], prttaglist[1][0]) SET toff TO 1.
      IF pmin < MAX(prtlistTMP[1][1][0], prtlist[1][1][0]) SET poff TO 1.
        IF LOADBKP<>2{
        FOR i IN range(1,imin){
          IF opt = 1 SET loadp TO loadp+1. PRINT "." AT (loadp,LNstp-1).
          IF itemlist[I] <> itemlistTMP[I]{
            SET ioff TO ioff+1. 
            SET ioff TO ioff+1. 
            IF dbglog > 2 log2file("      Item OFF:"+itemlistTMP[I]+"("+I+")"+"/"+itemlist[I]+"("+itemlist[0]+")").
          }
          FOR t IN range(1,MIN(prttaglistTMP[I][0], prttaglist[I][0])){
            IF t < tmin  IF prttaglist[I][T] <> prttaglistTMP[I][T]{
              SET toff TO toff+1. 
              SET toff TO ioff+1.
              IF dbglog > 2 log2file("       Tag OFF:"+itemlistTMP[I]+"("+I+")"+"-"+prttaglistTMP[I][t]+"("+i+")"+"/"+itemlist[I]+"("+I+")"+"-"+prttaglist[I][t]+"("+t+")").
              }
            FOR p IN range(1,MIN(prtlistTMP[I][T][0], prtlist[I][T][0])){
              IF p < pmin IF prtlist[I][T][P]:TOSTRING <> prtlistTMP[I][T][P]:TOSTRING{
                IF NOT prtlist[I][T][P]:HASMODULE("ModuleCommand"){
                  SET poff TO poff+1. SET poff TO ioff+1.
                   IF dbglog > 2 log2file("      Part OFF:"+itemlistTMP[I]+"("+I+")"+"-"+prttaglistTMP[I][t]+"("+T+")"+"-"+prtlistTMP[I][T][p]+"("+P+")"+"/"+itemlist[I]+"("+I+")"+"-"+prttaglist[I][t]+"("+t+")"+"-"+prtlist[I][T][p]+"("+p+")").
                }
              }
            }
          }
        }
        }ELSE {SET ioff TO 0. SET toff TO 0. SET poff TO 0.}
      IF autovallistTMP[0][0][0] > 1000 AND ioff = 0 AND toff = 0 AND poff = 0 {SET line TO LNstp. SET LNstp TO LNstp+1.
       IF autovallistTMP[0][0][0] > 1000 button7(). //else if autovallistTMP[0][0][0] = 1002 button11().
       }ELSE{DESKTOP(). 
        IF ioff = 0 {PRINT "itemlist match" AT (1,line). SET line TO line+1.}ELSE{PRINT "itemlist mismatch" AT (1,line).SET line TO line+1.}
        IF toff = 0 {PRINT "Taglist match"  AT (1,line). SET line TO line+1.}ELSE{PRINT  "Taglist mismatch" AT (1,line).SET line TO line+1.}
        IF poff = 0 {PRINT "Partlist match" AT (1,line). SET line TO line+1.}ELSE{PRINT "Partlist mismatch" AT (1,line).SET line TO line+1.}
        PRINT "load settings?" AT (1,line). SET line TO line+1.
        PRINT "|    YES   |    NO    | AUTO LOAD|" AT (0,heightlim).
        IF loadbkp <> 2 IF file_exists(autofileBAK) PRINT "| lOAD BKP  |          |" AT (33,heightlim).
        }     
      //#region buttons 
      SET v0:wave TO "sawtooth".
      FUNCTION button7{ALOAD(rchhk,lstoff).
       SET isDone TO 1.   SET refreshTimer TO TIME:SECONDS+1000000.
       //SET LOADBKP TO 0.
      }buttons:setdelegate(7,button7@).
      
      FUNCTION button8{
        SET LOADBKP TO 0.
        SET refreshTimer TO TIME:SECONDS+1000000.
        PRINT GetColor("Settings discarded.","ORN",0)AT (1,line).
        SET line TO line+1.
         IF file_exists(autofile) DELETEPATH(SubDirSV +autofile). 
         SET isDone TO 1.
        }buttons:setdelegate(8,button8@).
      FUNCTION button9{
         SET refreshTimer TO TIME:SECONDS+1000000.
        PRINT "Settings will be loaded automatically on match."AT (1,line). 
        SET autovallisttmp[0][0][0] TO 1001. SET line TO line+1. SET LNstp TO line+1. ALOAD(rchhk,lstoff).
        SET isDone TO 1.
        
        }buttons:setdelegate(9,button9@).
      FUNCTION button10{
        SET LOADBKP TO 2.
        SET isDone TO 1.
        SET rchhk TO 1.
        SET refreshTimer TO TIME:SECONDS+1000000.
        }buttons:setdelegate(10,button10@).
      //function button11{
        // set refreshTimer to TIME:seconds+1000000.
        //print "Backup will be loaded automatically on match."AT (1,line). 
        //set autovallisttmp[0][0][0] to 1002. set line to line+1. 
        //SET LOADBKP TO 2.
        //SET isDone to 1.
        //set rchhk to 1.
        //set refreshTimer to TIME:seconds+1000000.
        //}buttons:setdelegate(11,button11@).
      //#endregion buttons
      LOCAL tmebk TO 0.
      UNTIL isDone > 0 {
        LOCAL tme TO ROUND((10- (TIME:SECONDS - refreshTimer)),0).
        IF tmebk <> tme {PRINTLINE("Auto Selecting Yes in " + tme + " SECONDS      ",0,17). SET tmebk TO tme.}
        IF tme < 1 {button7().}
      }
      //if loadbkp = 2 {set LNstp to 1. set line to 1. DESKTOP(). loadship(0). HudFuction().}
      
        FUNCTION evenlist{
          LOCAL lINSERTED TO LIST().
          LOCAL PARAMETER OPIN.
          IF dbglog > 1 log2file("    evenlist:"+opin).
          IF dbglog > 2{log2file("      ITEMLIST   :"++LISTTOSTRING(itemlist)).
                         log2file("      ITEMLISTTMP:"+LISTTOSTRING(itemlistTMP)).
                         }
          LOCAL itl TO LIST(0).
          IF OPIN = 1{
                FOR k IN range (1,itemlistTMP[0]+1){
                  IF NOT prtListTMP[k][0][0]:tostring:contains("/") SET prtListTMP[k][0][0] TO "temp"+"/"+0.
                  IF DBGLOG > 2 log2file(prtListTMP[k][0][0]).
                  itl:ADD(prtListTMP[k][0][0]:split("/")[0]).
                }
            FOR i IN range (1,itemlistTMP[0]+1){
              IF dbglog > 2 log2file("      ITEM:"+I).
              IF i < itemlistTMP[0]+1 {
                //if i = itemlistTMP[0]+1 break.
                IF prtList:length = i prtList:ADD(LIST(LIST("temp"+"/"+0))).
                IF AutoDspList[0]:length = i AutoDspList[0]:ADD(LIST(0)).
                IF prtList[I][0][0]:tostring <> prtlistTMP[I][0][0]:tostring OR prtList:length = i{
                  LOCAL pl0 TO prtList[I][0][0]:split("/").
                  LOCAL plT TO prtListTMP[I][0][0]:split("/").
                  IF dbglog > 2{log2file("      ITEM:"+I). log2file("      "+prtList[I][0][0]+":"+prtListTMP[I][0][0]).}
                  IF plt[0] <> pl0[0] {
                    IF pl0[1]:tonumber < itl:find(pl0[0]) OR itl:find(pl0[0]) = -1{
                      lINSERTED:ADD(I).
                      LOCAL ADout TO LIST(LIST(0)).
                      LOCAL AD0ut TO LIST(LIST(0)).
                      LOCAL AVout TO LIST(LIST(0)).
                      LOCAL itmout TO "na".
                      LOCAL tgout TO LIST(1,"NONE").
                      LOCAL ptout TO LIST(LIST(0)).
                      LOCAL arout TO LIST(LIST(0)).
                      LOCAL acout TO LIST(LIST(0)).
                      LOCAL ac0ut TO LIST(LIST(0)).
                      LOCAL atout TO LIST(LIST(0)).
                      LOCAL a0out TO LIST(LIST(0)).
                      IF itl:find(pl0[0])-1 = pl0[1]:tonumber {
                        SET ADout TO AutoDspListTMP[I].
                        SET AD0ut TO AutoDspListTMP[0][I].
                        SET AVout TO autovallistTMP[I].
                        SET itmout TO itemlistTMP[I].
                        SET tgout TO prttaglistTMP[I].
                        SET ptout TO prtlistTMP[I].
                        SET arout TO autoRstListTMP[I].
                        SET acout TO AutoRscListTMP[I].
                        SET ac0ut TO AutoRscListTMP[0][I].
                        SET atout TO AutoTRGListTMP[I].
                        SET a0out TO AutoTRGListTMP[0][I].
                      }
                      IF dbglog > 2{
                        log2file("AutoDspList:insert(" + i + "):" + listtostring(ADout:COPY) + ")") .
                        log2file("AutoDspList[0]:insert(" + i + "):" + listtostring(AD0ut:COPY) + ")") .
                        log2file("autovalList:insert(" + i + "):" + listtostring(AVout:COPY) + ")") .
                        log2file("itemList:insert(" + i + "):" + itmout + ")") .
                        log2file("prttagList:insert(" + i + "):" + listtostring(tgout:COPY) + ")") .
                        log2file("prtList:insert(" + i + "):" + listtostring(listtostring(ptout:COPY)) + ")") .
                        log2file("autoRstList:insert(" + i + "):" + listtostring(arout:COPY) + ")") .
                        log2file("AutoRscList:insert(" + i + "):" + listtostring(acout:COPY) + ")") .
                        log2file("AutoRscList[0]:insert(" + i + "):" + ac0ut + ")") .
                        log2file("AutoTRGList:insert(" + i + "):" + listtostring(atout:COPY) + ")") .
                        log2file("AutoTRGList[0]:insert(" + i + "):" + listtostring(a0out:COPY) + ")") .
                      }
                      AutoDspList:insert(i,ADout:COPY).
                      AutoDspList[0]:insert(i,AD0ut:COPY).
                      autovallist:insert(i,AVout:COPY) .
                      itemlist:insert(i,itmout).
                      prttaglist:insert(i,tgout:COPY).
                      prtlist:insert(i,ptout:COPY).
                      autoRstList:insert(i,arout:COPY).
                      AutoRscList:insert(i,acout:COPY).
                      AutoRscList[0]:insert(i,ac0ut).
                      AutoTRGList:insert(i,atout:COPY). 
                      AutoTRGList[0]:insert(i,a0out:COPY). 
                      IF plt[1]:tonumber = i {
                        SET prtList[I] TO prtListtmp[I].
                        SET prtList[I][0][0] TO plt[0]+"/"+plt[1].
                        tagfix(plt[0],plt[1]).
                      }
                    }
                  }ELSE{
                    IF prttaglist[i][0] > prttaglisttmp[i][0] prtfix(i).
                    IF plt[1]:tonumber = i {
                      ToTMP(i,plt).
                      tagfix(plt[0],plt[1]).
                    }
                  }
                  WAIT 0.01.
                }//ELSE{if prttaglist[i][0] > prttaglisttmp[i][0] prtfix(i).}
              }
            }
          }
          IF OPIN = 2{
                FOR k IN range (1,itemlist[0]+1){
                  IF NOT prtList[k][0][0]:tostring:contains("/") SET prtList[k][0][0] TO "temp"+"/"+0.
                  IF dbglog > 1 log2file("      "+prtList[k][0][0]).
                  itl:ADD(prtList[k][0][0]:split("/")[0]).
                }
            FOR i IN range (1,itemlist[0]+1){
              IF dbglog > 2 log2file("      ITEM:"+I).
              IF i < itemlist[0]+1 {
                IF prtListTMP:length = i prtListTMP:ADD(LIST(LIST("temp"+"/"+0))).
                IF AutoDspListTMP[0]:length = i AutoDspListTMP[0]:ADD(LIST(0)).
                IF prtListTMP[I][0][0]:tostring <> prtlist[I][0][0]:tostring OR prtListTMP:length = i{
                  LOCAL plt TO prtListTMP[I][0][0]:split("/").
                  LOCAL pl0 TO prtList[I][0][0]:split("/").
                  IF dbglog > 2{log2file("      ITEM:"+I). log2file("      "+prtList[I][0][0]+":"+prtListTMP[I][0][0]).}
                  IF pl0[0] <> plt[0] {
                    IF plt[1]:tonumber < itl:find(plt[0]) OR itl:find(plt[0]) = -1{
                      lINSERTED:ADD(I).
                      LOCAL ADout TO LIST(LIST(0)).
                      LOCAL AD0ut TO LIST(LIST(0)).
                      LOCAL AVout TO LIST(LIST(0)).
                      LOCAL itmout TO "na".
                      LOCAL tgout TO LIST(1,"NONE").
                      LOCAL ptout TO LIST(LIST(0)).
                      LOCAL arout TO LIST(LIST(0)).
                      LOCAL acout TO LIST(LIST(0)).
                      LOCAL ac0ut TO LIST(LIST(0)).
                      LOCAL atout TO LIST(LIST(0)).
                      LOCAL a0out TO LIST(LIST(0)).
                      IF itl:find(plt[0])-1 = plt[1]:tonumber OR NOT prttaglistTMP:contains(pl0[0]){
                        SET ADout TO AutoDspList[I].
                        SET AD0ut TO AutoDspList[0][I].
                        SET AVout TO autovallist[I].
                        SET itmout TO itemlist[I].
                        SET tgout TO prttaglist[I].
                        SET ptout TO prtlist[I].
                        SET arout TO autoRstList[I].
                        SET acout TO AutoRscList[I].
                        SET ac0ut TO AutoRscList[0][I].
                        SET atout TO AutoTRGList[I].
                        SET a0out TO AutoTRGList[0][I].
                      }
                      IF dbglog > 2{
                        log2file("          AutoDspListTMP:insert(" + i + "):" + listtostring(ADout:COPY) + ")") .
                        log2file("          AutoDspListTMP[0]:insert(" + i + "):" + listtostring(AD0ut:COPY) + ")") .
                        log2file("          autovallistTMP:insert(" + i + "):" + listtostring(AVout:COPY) + ")") .
                        log2file("          itemlistTMP:insert(" + i + "):" + itmout + ")") .
                        log2file("          prttaglistTMP:insert(" + i + "):" + listtostring(tgout:COPY) + ")") .
                        log2file("          prtListTMP:insert(" + i + "):" + listtostring(ptout:COPY) + ")") .
                        log2file("          autoRstListTMP:insert(" + i + "):" + listtostring(arout:COPY) + ")") .
                        log2file("          AutoRscListTMP:insert(" + i + "):" + listtostring(acout:COPY) + ")") .
                        log2file("          AutoRscListTMP[0]:insert(" + i + "):" + ac0ut + ")") .
                        log2file("          AutoTRGListTMP:insert(" + i + "):" + listtostring(atout:COPY) + ")") .
                        log2file("          AutoTRGListTMP[0]:insert(" + i + "):" + listtostring(a0out:COPY) + ")") .
                      }
                      
                      AutoDspListTMP:insert(i,ADout:COPY) .
                      AutoDspListTMP[0]:insert(i,AD0ut:COPY) .
                      autovallistTMP:insert(i,AVout:COPY) .
                      itemlistTMP:insert(i,itmout).
                      prttaglistTMP:insert(i,tgout:COPY).
                      prtListTMP:insert(i,ptout:COPY).
                      autoRstListTMP:insert(i,arout:COPY) .
                      AutoRscListTMP:insert(i,acout:COPY) .
                      AutoRscListTMP[0]:insert(i,ac0ut) .
                      AutoTRGListTMP:insert(i,atout:COPY) . 
                      AutoTRGListTMP[0]:insert(i,a0out:COPY).
                      IF pl0[1]:tonumber = i {
                        SET prtListTMP[I] TO prtList[I].
                        SET prtListTMP[I][0][0] TO pl0[0]+"/"+pl0[1].
                        tagfix(pl0[0],pl0[1]).
                      }
                    }
                  }
                  ELSE{
                    IF dbglog > 2 log2file("            TAGS-LENGTH:"+prtTagList[I][0]+ " TMP-LENGTH:"+prtTagListTMP[I][0]).
                      IF prttaglist[i][0] > prttaglisttmp[i][0] prtfix(i).
                      IF pl0[1]:tonumber = i {
                        ToTMP(i,pl0).
                        tagfix(pl0[0],pl0[1]).
                      }
                  }
                    //IF lINSERTED:LENGTH> 0{CheckLink(I).}
                  WAIT 0.01.
                }ELSE{IF prttaglist[i][0] > prttaglisttmp[i][0] prtfix(i).}
              }
            }
            IF lINSERTED:LENGTH> 0{
              FOR i IN range (1,itemlist[0]+1){CheckLink(I).}
            
            }
          }
          SET itemlist[0] TO itemlist:length-1.
          SET itemlistTMP[0] TO itemlistTMP:length-1.
          IF dbglog > 2{log2file("      ITEMLIST   :"++LISTTOSTRING(itemlist)).
                        log2file("      ITEMLISTTMP:"+LISTTOSTRING(itemlistTMP)).
                        }
          SET LFX TO 1.
          FUNCTION CheckLink{
            LOCAL PARAMETER CLI.
            IF cli > itemlist:length-1 RETURN.
            IF dbglog > 2 log2file("          CHECK LINK("+CLI+"):"+ITEMLIST[CLI]).
            FOR T IN RANGE(1,prtTagListtmp[CLI][0]+1){           IF T = prtTagListtmp[CLI][0]+1          BREAK. IF dbglog > 2 log2file("            CHECK TAG("+T+"):"+prtTagList[CLI][T]).
              FOR J IN RANGE(0,AutoDspListTMP[0][CLI][T]:LENGTH){IF J = AutoDspListTMP[0][CLI][T]:LENGTH BREAK. IF dbglog > 2 log2file("             LINK:("+J+"):"+AutoDspListTMP[0][CLI][T][J]).
                LOCAL itm1 TO AutoDspListTMP[0][CLI][T][J].
                IF itm1:TOSTRING:CONTAINS("-"){
                  LOCAL splt TO itm1:split("-").
                    IF SPLT:LENGTH > 2 {
                    LOCAL NmIn TO (SPLT[0]:TONUMBER).
                    LOCAL addmore TO 0.
                    FOR k IN lINSERTED IF nmin > k-1 SET addmore TO addmore+1.
                    LOCAL NmMore TO NmIn+addmore.
                      IF addmore > 0 {IF dbglog > 2 log2file("                  CHANGING "+SPLT[0]+" TO "+NmMore).
                        SET SPLT[0] TO NmMore:TOSTRING.
                        IF SPLT:LENGTH = 4 SET AutoDspListTMP[0][CLI][T][J] TO splt[0]+"-"+splt[1]+"-"+splt[2]+"-"+splt[3].
                        IF SPLT:LENGTH = 3 SET AutoDspListTMP[0][CLI][T][J] TO splt[0]+"-"+splt[1]+"-"+splt[2].
                        IF dbglog > 2 log2file("                    LINKout:("+J+"):"+AutoDspListTMP[0][CLI][T][J]).
                      }
                    }
                  }
                }
              }
          }
          FUNCTION ToTMP{
            LOCAL PARAMETER TTI, ttplt.
                          SET prtList[TTI] TO prtListtmp[TTI].
                          SET AutoDspList[TTI] TO AutoDspListtmp[TTI].
                          SET autovallist[TTI] TO autovallisttmp[TTI].
                          SET itemlist[TTI] TO itemlisttmp[TTI].
                          SET prttaglist[TTI] TO prttaglisttmp[TTI].
                          SET prtlist[TTI] TO prtlisttmp[TTI].
                          SET autoRstList[TTI] TO autoRstListtmp[TTI].
                          SET AutoRscList[TTI] TO AutoRscListtmp[TTI].
                          SET AutoRscList[0][TTI] TO AutoRscListtmp[0][TTI].
                          SET AutoTRGList[TTI] TO AutoTRGListtmp[TTI].
                          SET AutoTRGList[0][TTI] TO AutoTRGListtmp[0][TTI].
                          SET prtList[TTI][0][0] TO ttplt[0]+"/"+ttplt[1].
                          IF dbglog > 2{
                            log2file("          set prtList:"+ prtList[TTI]+" to "+prtListTMP[TTI]).
                            log2file("          set AutoDspList:"+ AutoDspList[TTI]+" to "+AutoDspListTMP[TTI]).
                            log2file("          set autovallist:"+ autovallist[TTI]+" to "+autovallistTMP[TTI]).
                            log2file("          set itemlist:"+ itemlist[TTI]+" to "+itemlistTMP[TTI]).
                            log2file("          set prttaglist:"+ prttaglist[TTI]+" to "+prttaglistTMP[TTI]).
                            log2file("          set prtlist:"+ prtlist[TTI]+" to "+prtListTMP[TTI]).
                            log2file("          set autoRstList:"+ autoRstList[TTI]+" to "+autoRstListTMP[TTI]).
                            log2file("          set AutoRscList:"+ AutoRscList[TTI]+" to "+AutoRscListTMP[TTI]).
                            log2file("          set AutoRscList:"+ AutoRscList[TTI][0]+" to "+AutoRscListTMP[TTI][0]).
                            log2file("          set AutoTRGList:"+ AutoTRGList[TTI]+" to "+AutoTRGListTMP[TTI]).
                            log2file("          set AutoTRGList:"+ AutoTRGList[0][TTI]+" to "+AutoTRGListTMP[0][TTI]).
                            log2file("          set prtList:"+ prtList[TTI][0][0]+" to "+ttplt[0]+"/"+ttplt[1]).
                          }
          }
          FUNCTION prtfix{
          LOCAL PARAMETER i.              
          IF dbglog > 2 log2file("      PRTFIX:"+I).
          IF i > itemlist:length-1 RETURN.
                  FOR t IN range (1,prttaglist[i]:length){
                    IF dbglog > 2 log2file("          TAG:"+T).
                    IF NOT prttaglistTMP[i]:contains(prttaglist[i][t]) {
                        IF dbglog > 2{
                        log2file("          INSERTED prtListTMP:"+listtostring(prtList[I][t])).
                        log2file("          INSERTED AutoDspListTMP:"+AutoDspList[I][t]).
                        log2file("          INSERTED AutoDspListTMP[0]:"+AutoDspList[0][I][t]).
                        log2file("          INSERTED autovallistTMP:"+autovallist[I][t]).
                        log2file("          INSERTED prttaglistTMP:"+prttaglist[I][t]).
                        log2file("          INSERTED autoRstListTMP:"+autoRstList[I][t]).
                        log2file("          INSERTED AutoRscListTMP:"+AutoRscList[I][t]).
                        log2file("          INSERTED AutoTRGListTMP:"+AutoTRGList[I][t]).
                        log2file("          INSERTED AutoTRGListTMP[0]:"+AutoTRGList[0][I][t]).
                        }
                      AutoDspListTMP[i]:insert(t,AutoDspList[i][t]) .
                      AutoDspListTMP[0][i]:insert(t,AutoDspList[0][i][t]) .
                      autovallistTMP[i]:insert(t,autovallist[i][t]) .
                      prttaglistTMP[i]:insert(t,prttaglist[i][t]).
                      prtListTMP[i]:insert(t,prtList[i][t]:COPY).
                      autoRstListTMP[i]:insert(t,autoRstList[i][t]) .
                      AutoRscListTMP[i]:insert(t,AutoRscList[i][t]) .
                      AutoTRGListTMP[i]:insert(t,AutoTRGList[i][t]) .  
                      AutoTRGListTMP[0][i]:insert(t,AutoTRGList[0][i][t]) .                     
                    }
                  }
                SET prttaglistTMP[i][0] TO prttaglistTMP[i]:length-1. 
                SET prttaglist[i][0] TO prttaglist[i]:length-1.      
        }
        }
        FUNCTION tagfix{
          LOCAL PARAMETER tagin, namein.
          SET tagin TO tagin:tostring.
          IF namein:typename="string" SET namein TO namein:tonumber.
          IF dbglog > 2 log2file("        TagFix:"+TAGIN+"-"+namein).
          IF tagin = "lighttag"{SET lighttag TO namein.}ELSE{
          IF tagin = "AGTag"{SET AGTag TO namein.}ELSE{
          IF tagin = "FlyTag"{SET FlyTag TO namein.}ELSE{
          IF tagin = "CMDTag"{SET CMDTag TO namein.}ELSE{
          IF tagin = "CntrlTag"{SET CntrlTag TO namein.}ELSE{
          IF tagin = "engtag"{SET engtag TO namein.}ELSE{
          IF tagin = "Inttag"{SET Inttag TO namein.}ELSE{
          IF tagin = "dcptag"{SET dcptag TO namein.}ELSE{
          IF tagin = "geartag"{SET geartag TO namein.}ELSE{
          IF tagin = "chutetag"{SET chutetag TO namein.}ELSE{
          IF tagin = "ladtag"{SET ladtag TO namein.}ELSE{
          IF tagin = "baytag"{SET baytag TO namein.}ELSE{
          IF tagin = "Docktag"{SET Docktag TO namein.}ELSE{
          IF tagin = "RWtag"{SET RWtag TO namein.}ELSE{
          IF tagin = "slrtag"{SET slrtag TO namein.}ELSE{
          IF tagin = "RCStag"{SET RCStag TO namein.}ELSE{
          IF tagin = "drilltag"{SET drilltag TO namein.}ELSE{
          IF tagin = "radtag"{SET radtag TO namein.}ELSE{
          IF tagin = "scitag"{SET scitag TO namein.}ELSE{
          IF tagin = "anttag"{SET anttag TO namein.}ELSE{
          IF tagin = "FWtag"{SET FWtag TO namein.}ELSE{
          IF tagin = "ISRUTag"{SET ISRUTag TO namein.}ELSE{
          IF tagin = "Labtag"{SET Labtag TO namein.}ELSE{
          IF tagin = "RBTTag"{SET RBTTag TO namein.}ELSE{
          IF tagin = "SMRTtag"{SET SMRTtag TO namein.}ELSE{
          //MKS MOD
          IF tagin = "MksDrlTag"{SET MksDrlTag TO namein.}ELSE{
          IF tagin = "PWRTag"{SET PWRTag TO namein.}ELSE{
          IF tagin = "DEPOTag"{SET DEPOTag TO namein.}ELSE{
          IF tagin = "habTag"{SET habTag TO namein.}ELSE{
          IF tagin = "CnstTag"{SET CnstTag TO namein.}ELSE{
          IF tagin = "DcnstTag"{SET DcnstTag TO namein.}ELSE{
          IF tagin = "ACDTag"{SET ACDTag TO namein.}ELSE{
          //OTHER MODS
          IF tagin = "CapTag"{SET CapTag TO namein.}ELSE{
          //BDA MOD (KEEP LAST TO MAAKE WMGR QUICKLY ACCESSABLE)
          IF tagin = "BDPtag"{SET BDPtag TO namein.}ELSE{
          IF tagin = "CMtag"{SET CMtag TO namein.}ELSE{
          IF tagin = "Radartag"{SET Radartag TO namein.}ELSE{
          IF tagin = "FRNGtag"{SET FRNGtag TO namein.}ELSE{
          IF tagin = "WMGRtag"{SET WMGRtag TO namein.}ELSE{ IF dbglog > 2 log2file("        FAILED:").
          }}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}
        }
        FUNCTION ALOAD{
        LOCAL PARAMETER rcheck IS 0, loff IS 0.
        IF dbglog > 1 log2file("      ALOAD:Recheck="+rcheck).
        SET autovallist TO autovallistTMP:COPY. SET isDone TO 1.
        SET AutoDspList TO AutoDspListTMP:COPY. 
        SET autoRstList TO autoRstListTMP:COPY.
        SET AutoRscList TO AutoRscListTMP:COPY.
        SET AutoTRGList TO AutoTRGListTMP:COPY.
        IF loff <> 0{
          SET itemlist TO itemlistTMP:COPY.
          SET prtlist TO prtlistTMP:COPY.
          SET prttaglist TO prttaglistTMP:COPY.
        }
        IF AutoDspList[0]:length < itemlist:length OR AutoValList[0][0]:length < 5 addlist().
        SET HdngSet TO autovallist[0][0][1].
        SET HEIGHT TO autovallist[0][0][2].
        SET refreshRateSlow TO autovallist[0][0][4][0].
        SET refreshRateFast TO autovallist[0][0][4][1].
        IF debug = 0 SET debug TO autovallist[0][0][4][2].
        //if dbglog = 0 set dbglog to autovallist[0][0][4][3]. 
        SET HLon TO autovallist[0][0][4][4].
        SET SPEEDSET[0] TO SFL(autovallist[0][0][4],5,SPEEDSET[0]).
        SET SPEEDSET[1] TO SFL(autovallist[0][0][4],6,SPEEDSET[1]).
        SET SPEEDSET[2] TO SFL(autovallist[0][0][4],7,SPEEDSET[2]).
        SET SPEEDSET[3] TO SFL(autovallist[0][0][4],8,SPEEDSET[3]).
        SaveAutoSettings().
        IF rcheck = 1 LoadShip(0).
        FUNCTION SFL{
          LOCAL PARAMETER VALIN, LNIN, VALST.
          IF VALIN:LENGTH-1 < LNIN RETURN VALST. ELSE SET valin TO valin[lnin].
          IF VALIN < 1 RETURN VALST.
          RETURN VALIN.
        }
      }
    }
//#endregion
FUNCTION HudFuction{
  initialset().
  HudFuctionMain().
  FUNCTION initialset{
    SET CPUSPD TO SPEEDSET[0].
    GLOBAL DispInfo TO 0.
    GLOBAL HDXT TO "     ".
    GLOBAL ploc TO 13.
    GLOBAL pwdt TO 14.
    GLOBAL pwdt2 TO 28.
    GLOBAL pwdt3 TO 14.
    GLOBAL ploc2 TO ploc+1+pwdt. //ploc+14
    GLOBAL ploc3 TO ploc2+1+pwdt2. //ploc+44.
    GLOBAL axsel TO 1.
    GLOBAL fo TO 0.
    GLOBAL foblink TO 0.
    IF IsPayload[0] = 1 {SET RunAuto TO 0. SET refreshRateSlow TO 10. SET refreshRateFast TO 10. SET RFSBAak TO refreshRateSlow.}
    IF SHIP:STATUS = "PRELAUNCH" SET RunAuto TO 2.
    GLOBAL runautobak TO RunAuto.
    GLOBAL APaxis TO LIST(9,"pitch","yaw","roll","speed","alt","V-SPD","Pitch Lim","Roll Lim","AOA Lim").    
    GLOBAL HudRstMdLst TO LIST(4," DISABLE  ","CHANGE DIR"," RESET UP "," RESET DN ").
    GLOBAL ShipStatPREV TO " ".
    GLOBAL ShipStatPREV2 TO "NONE".
    GLOBAL FlState TO " ".
    GLOBAL RscSelection TO 0.
    GLOBAL Trim TO 0.
    GLOBAL partnumprv TO 1.
    GLOBAL anttrgsel TO 1.
    GLOBAL scipart TO 1.
    GLOBAL EnabSel TO 1.
    GLOBAL ModeSel TO 1.
    GLOBAL ConvRSC TO 1.
    GLOBAL BayLst TO LIST(0).
    GLOBAL BayTrg TO LIST(0).
    GLOBAL BaySel TO 1.
    GLOBAL SciDsp TO "".
    IF refreshRateFast < 1 SET refreshRateFast TO 1.
    IF refreshRateSlow < 1 SET refreshRateSlow TO 1.
    GLOBAL MtrPrtSel TO LIST(0,0,0,0,0,0,0,0,0).
    GLOBAL enghud TO LIST().
    FOR i IN range(1, prtTagList[engtag][0]*2+2) enghud:insert(0,0).
    GLOBAL AUTOHUD TO LIST(0,1,"  OVER ").
    GLOBAL EmptyHud TO "          ".
    GLOBAL fuelmon TO 0.
    GLOBAL hudstart TO 17.
    GLOBAL RowSel TO 1.
    GLOBAL HSel TO LIST(0).
    GLOBAL HUDOP TO 1.
    GLOBAL HUDOPPREV TO 1.
    GLOBAL AutoAdjByLst TO LIST(7,1,5,10,100,1000,10000,100000).
    GLOBAL fieldlist TO LIST("").
    GLOBAL AUTOHUDBK TO AUTOHUD.
    GLOBAL HudOptsL TO LIST(0).
    GLOBAL HudOptsR TO LIST(0). 
    HudOptsL:ADD(LIST(0,"PREV    "   ,"PREV    "   ,"THRUST  "   ,"        "   ,"        "   ,"PREV    "   ,"PREV    "   ,"PREV    "   ,"PREV    "   ,"        "   )).
    HudOptsL:ADD(LIST(0,"GROUP       ","PART      ","LIM DN     ","           ","AUTO DIR   ","ACTION     ","TARGET     ","AXIS       ","WEAPON     ","LIM DN  "  )).
    HudOptsL:ADD(LIST(0,"NEXT       ","NEXT       ","THRUST     ","           ","AUTO ADJ BY","NEXT       ","NEXT       ","NEXT       ","NEXT       ","        ")).
    HudOptsL:ADD(LIST(0,"GROUP   "   ,"PART  "     ,"LIM UP "    ,"       "    ,"       "    ,"ACTION "    ,"TARGET "    ,"AXIS    "   ,"WEAPON  "   ,"LIM UP "    )).
    HudOptsL:ADD(LIST(0,"      "     ,"      "     ,"       "    ,"      "     ,"      "     ,"      "     ,"      "     ,"      "     ,"      "     ,"       "    )).
    HudOptsL:ADD(LIST(0,"      "     ,"      "     ,"       "    ,"      "     ,"      "     ,"      "     ,"      "     ,"      "     ,"      "     ,"       "    )).
    HudOptsL:ADD(LIST(0,"      "     ,"      "     ,"       "    ,"      "     ,"      "     ,"      "     ,"      "     ,"      "     ,"      "     ,"       "    )).
    HudOptsL:ADD(LIST(0,"      "     ,"      "     ,"       "    ,"      "     ,"      "     ,"      "     ,"      "     ,"      "     ,"      "     ,"       "    )).
    HudOptsR:ADD(LIST(0,"       LIST","       LIST","       LIST","       LIST","       AUTO","       LIST","       LIST","       LIST","       LIST","       LIST")).
    HudOptsR:ADD(LIST(0,  "   UP "   ,  "   UP "   ,  "   UP "   ,  "   UP "   ,  "   UP "   ,  "   UP "   ,  "   UP "   ,  "   UP "   ,  "   UP "   ,  "   UP "   )).
    HudOptsR:ADD(LIST(0,"    LIST"   ,"    LIST"   ,"    LIST"   ,"    LIST"   ,"    AUTO"   ,"    LIST"   ,"    LIST"   ,"    LIST"   ,"    LIST"   ,"    LIST"   )).
    HudOptsR:ADD(LIST(0,"    DOWN"   ,"    DOWN"   ,"    DOWN"   ,"    DOWN"   ,"    DOWN"   ,"    DOWN"   ,"    DOWN"   ,"    DOWN"   ,"    DOWN"   ,"    DOWN"   )).
    HudOptsR:ADD("AUTO").
    HudOptsR:ADD("      ").
    HudOptsR:ADD(LIST(0,"   SET AUTO"    ,"   SET AUTO"    ,"   SET AUTO"    ,"   SET AUTO"    ,"     CANCEL"     ,"           "    ,"           "    ,"           "    ,"           "    ,"           "    )).
    HudOptsR:ADD(LIST(0,"    "       ,"    "       ,"    "       ,"    "       ,"      "     ,"EXP "       ,"    "       ,"    "       ,"    "       ,"    "       )).
    LOCAL hdspot TO 0.
    LOCAL ins TO 0.
    LOCAL findtags TO LIST("rotor","prop","Nuclear").
    FOR eg IN RANGE(1, prtTagList[engtag][0]+1) {
        IF hdspot > enghud:length BREAK.
        IF dbglog > 2 log2file("        ENG:"+eg+"  SPOT:"+hdspot+" ins:"+ins).
        LOCAL md2 TO 0.
        LOCAL p1 TO prtTagList[engtag][eg].
        LOCAL p2 TO prtList[engtag][eg][1].
        IF p2:HASSUFFIX("modes") IF P2:modes:length > 1     SET md2 TO 102.
        IF p2:HASMODULE("FSengineBladed")                   SET md2 TO 102.
        IF p2:HASMODULE("FSswitchEngineThrustTransform")    SET md2 TO 102.
        IF dbglog > 2 log2file("        PART:"+p2+"  TAG:"+p1+" md2:"+md2).
        SET enghud[hdspot] TO eg.
        IF md2 > 0 SET enghud[hdspot+1] TO md2.
        IF p1:CONTAINS("Main") {
            enghud:REMOVE(hdspot). enghud:insert(0,eg).
            IF md2 > 1 {enghud:REMOVE(hdspot+1). enghud:insert(1,md2).SET ins TO ins+1.}
            SET ins TO ins+1.
        }ELSE{
            FOR fndt IN findtags{
                IF p1:CONTAINS(fndt){
                    enghud:REMOVE(hdspot). enghud:insert(ins,eg).
                    IF md2 > 1 {enghud:REMOVE(hdspot+1). enghud:insert(ins+1,md2).SET ins TO ins+1.}
                    SET ins TO ins+1.
                    BREAK.
                }
            }
        }
        SET hdspot TO hdspot+1.
        IF md2 > 0 SET hdspot TO hdspot+1.
    }
    FOR I IN RANGE(1, 10) {hsel:ADD(LIST(0,1,1,1)). }
    FOR i IN RANGE(0, 10) {hudopts:ADD(LIST(" "," "," "," ")).}
    FOR i IN RANGE(2, 10,2) {
      SET HudOpts[I][1] TO itemlist.
      SET HudOpts[I][2] TO prttaglist[1].
      SET HSEL[I][1] TO 1.
    }
    SET eng TO LIST(EMPTYHUD,EMPTYHUD,EMPTYHUD,EMPTYHUD,EMPTYHUD,EMPTYHUD,EMPTYHUD,EMPTYHUD).
    SET PrvITM TO EmptyHud.
    SET ItmTrg TO EmptyHud.
    SET nxtITM TO EmptyHud.
    SET BTHD10 TO EmptyHud.
    SET BTHD11 TO EmptyHud.
    SET BTHD12 TO EmptyHud.
    GLOBAL trglst TO getRTVesselTargets().
    GLOBAL ItemNumPrv TO 0.
    GLOBAL tagNumPrv TO 0.
    IF loadattempts < 3 {
        IF AutoDspList[0][0][0] > 0 SET hsel[2][1] TO AutoDspList[0][0][0].
        IF AutoDspList[0][0][1] > 0 SET hsel[2][2] TO AutoDspList[0][0][1].
    }
      IF hsel[2][2] >  HudOpts[2][2]:length SET hsel[2][2] TO 1.
      IF hsel[2][1] >  HudOpts[2][1]:length SET hsel[2][1] TO 1.
      SET checktime TO TIME:SECONDS.
  }
  FUNCTION HudFuctionMain{
    //#region update screen
    SET LastInput TO TIME:SECONDS.
    CLEARSCREEN.
    speedboost("off").
    LOCAL isDone TO 0.
    LOCAL refreshTimer TO TIME:SECONDS.
    LOCAL refreshTimer2 TO TIME:SECONDS.
    LOCAL buttonRefresh TO 1.
    UPDATEHUDOPTS().
    SET tagnumprv TO 0.
    SET ItemNumPrv TO 0.
    updatehudFast().
    updatehudSlow().
    SET RowSel TO 2.
    UPDATEHUDOPTS().
   FUNCTION updatehudSlow{
    IF LastIn(-5) speedboost().
    IF dbglog > 2 log2file("UPDATEHUDSLOW").
      IF hudop = 5{
        LOCAL enb TO "".
        printline("",0,1).
        IF AutoRscList[0][EnabSel]       = 1 SET enb  TO " VISIBLE  ". ELSE SET enb  TO "SKIP OVER ".  
        IF AutoValList[0][0][3][modesel] = 2 SET enb2 TO "SKIP OVER ".
        IF AutoValList[0][0][3][modesel] = 1 SET enb2 TO " VISIBLE  ".
        IF AutoValList[0][0][3][modesel] = 3 SET enb2 TO "SNSR ONLY ".
        SET enb3 TO MODElong[modesel].
        IF modesel = 1 SET enb2 TO "          ".
        SET eng[0] TO EMPTYHUD. 
        SET eng[1] TO "AUTO MODE ".
        SET eng[2] TO " MODE VIS ".
        SET eng[3] TO "   MODE   ". 
        IF h5mode <> 1 SET eng[4] TO "  DELAY   ". ELSE SET eng[4] TO "**DELAY** ".
        SET eng[5] TO "VISIBILITY".
        SET eng[7] TO "   ITEM   ".
        LOCAL dctprint TO "  NORMAL  ".
        IF dctnmode > 0 {
          SET dctprint TO "WAIT 4 OTH".
          IF dctnmode = 2 SET dctprint TO "LOCK 2 OTH".
          SET eng[2]   TO "   ITEM   ".
          SET eng[3]   TO "    TAG   ".
          SET enb2 TO ItemListHUD[HdItm].
          SET enb3 TO Prttaglist[HdItm][hdtag].
          SET enb3 TO makehud(enb3).
        }
        PRINT " |"+dctprint+"|"+enb2+"|"+enb3+"|" AT (0,1).
        PRINT "|"+enb+"|"+HudOpts[2][1][EnabSel] AT (45,1).
        PRINT setdelay AT (39,1).}
      ELSE{
      SET eng[0] TO EmptyHud.
      SET eng[1] TO EmptyHud.
      SET eng[2] TO EmptyHud.
      SET eng[3] TO EmptyHud.
      SET eng[4] TO EmptyHud.
      SET eng[5] TO EmptyHud.
      SET eng[7] TO EmptyHud.
      LOCAL k TO 0.
        FOR i IN range(1,prtTagList[engtag][0]*2){
          LOCAL EngCur TO enghud[i-1].
            IF EngCur < 100 AND EngCur > 0 {
                SET k TO k+1.
            LOCAL TG TO prtTagList[engtag][EngCur].
            LOCAL PT TO prtlist[engtag][EngCur][1].
            LOCAL j TO i+1.//*2.
            SET engsfx TO makehud(Prttaglist[engtag][EngCur],5).
            IF TG:CONTAINS("Main")     SET engsfx TO " MAIN ". ELSE{
            IF TG:CONTAINS("Scramjet") SET engsfx TO "SCRMJT". ELSE{
            IF TG:CONTAINS("Booster")  SET engsfx TO "BOOSTR". ELSE{
            IF TG:CONTAINS("Nuclear" ) SET engsfx TO "NUKENG". ELSE{
            IF TG:CONTAINS("rotor" )   SET engsfx TO " ROTOR". ELSE{
            IF TG:CONTAINS("prop" )    SET engsfx TO " PROP ". ELSE{
            IF TG:CONTAINS("vtol" )    SET engsfx TO " VTOL ". ELSE{
            }}}}}}}
            LOCAL engact TO 0.
            IF pt:HASMODULE("FSengineBladed"){IF getEvAct(pt,"FSengineBladed","Status",30,-1,2):contains("inactive") SET engact TO 2. ELSE SET engact TO 1.}
            ELSE{
              IF pt:HASSUFFIX("ignition"){IF pt:ignition = FALSE SET engact TO 2. ELSE SET engact TO 1.}
              ELSE{
                  LOCAL lon TO LIST("on", "activate").
                  LOCAL loff TO LIST("off","shutdown").
                  LOCAL Elst TO engmods.
                  //if Pt:hassuffix("modes") IF Pt:modes:length > 1 IF NOT Pt:primarymode SET Elst TO LIST("MultiModeEngine").
                  SET engact TO getactions("OnOff",Elst,engtag, EngCur,1,1,lon,loff,3).
              }
            }
            IF PT <> CORE:part {
            IF engact = 1{SET eng[j-1] TO engsfx+" ON ".}ELSE{IF engact = 2{SET eng[j-1] TO engsfx+" OFF".}ELSE{SET eng[j-1] TO EmptyHud.}}
            IF PT:HASMODULE("MultiModeEngine"){
                LOCAL Md TO PT:getmodule("MultiModeEngine"):getfield("mode").
                IF md = "Wet" SET md TO " AFTERBRN ". ELSE IF md = "ClosedCycle" SET md TO "CLOSED CYC". 
                IF Pt:HASSUFFIX("modes") IF Pt:modes:length > 1 IF PT:primarymode {SET eng[J] TO "  NORMAL  ".} ELSE  {SET eng[J] TO md.}
            }ELSE{
                IF pt:HASMODULE("FSengineBladed") SET eng[J] TO " HOVER TGL".
                IF pt:HASMODULE("FSswitchEngineThrustTransform"){
                    LOCAL ccc TO  getactions("OnOff",LIST("FSswitchEngineThrustTransform"),engtag, EngCur,1,1,LIST("reverse"), LIST("normal"),3).
                    IF ccc > 0{
                    IF ccc= 1 SET eng[J] TO " FWD THRST".
                    IF ccc= 2 SET eng[J] TO "RVRS THRST". 
                    }ELSE{SET eng[j] TO EmptyHud.}
                }
            }
            }ELSE{SET eng[j] TO EmptyHud.}
            }
            IF rowval = 0 {IF INTAKES {SET Eng[7] TO "INTAKES ON".} ELSE  {SET Eng[7] TO "INTAKE OFF".} }
             ELSE{IF MtrOps[hsel[2][1]][0] = 0 {SET Eng[7] TO "MTR ON BOT".} ELSE {SET Eng[7] TO "MTR ON ALL".}}
        }
    }
      PRINT "|"+Eng[1]+"|"+Eng[2]+"|"+Eng[3]+"|"+Eng[4]+"|"+Eng[5]+"|"+Eng[7]+"|LEAVE PRGM|" AT (0,0).
      IF hudop <> 5 {IF FuelUpdRate = "Slow" UpdateFuel().}
      IF SHIP:HASSUFFIX("CREWCAPACITY"){
        IF SHIP:crewcapacity > 0{
          SET crewcap TO SHIP:crewcapacity.
          IF SHIP:HASSUFFIX("CREW") IF SHIP:crew:length > 0 SET CrewAct TO SHIP:crew.}
      }
      SpeedBoost("off").
    }
   FUNCTION updatehudFast {// top lists and warnings 
      IF LastIn(-5) {SpeedBoost().}
      IF hudop <> 5{
        SET HUDTOP TO GetHudTop().
        ListToSpace(HUDTOP[1],ploc2,4).
        ListToSpace(HUDTOP[0],ploc ,2).
        ListToSpace(HUDTOP[2],ploc3,3).
        IF GrpDspList3[FLYTAG][1] = 6 AND LinkLock = 0{
          LOCAL PR TO "                   ".
          IF FlState = "Flight" {SET  ss TO "      SIDESLIP:"+ROUND(bearing_between(SHIP,srfprograde,SHIP:FACING),1). IF colorprint = 1 {SET pr TO "    ".}}
          ELSE{ SET ss TO "                ". IF colorprint = 1 {SET ss TO "    ". SET pr TO "                ".}}
          PRINTLINE(pr+"HEADING:"+ ROUND(compass_and_pitch_for()[0],0)+"         PITCH:"  + ROUND(compass_and_pitch_for()[1],0)+"         ROLL:"   + ROUND(roll_for(),0)+ss,"WHT",13).
          SET ln14 TO 2.
        }
        IF FuelUpdRate = "Fast" AND BtnActn = 0 UpdateFuel().
        SpeedBoost("off").
      }
      FUNCTION ListToSpace{
        LOCAL PARAMETER lin, loc, SKP IS 1.
        LOCAL st TO 0.
        LOCAL SK IS 0.
        IF hudop=5 SET st TO 1.
        FOR i IN range(st,lin:length){
          PRINT lin[I] AT (loc,I+1). 
          IF lin[I]:contains("            ") SET SK TO SK+1.
          IF SK = SKP BREAK.
         }
      }
      FUNCTION GetHudTop {
        SET listout1 TO LIST().
        SET listout2 TO LIST().
        SET listout3 TO LIST().
        LOCAL thrst IS 0.
        LIST ENGINES IN eng_list.
        FOR engs IN eng_list {
          IF engs:flameout = FALSE AND engs:ignition = TRUE {
            SET thrst TO thrst + engs:thrust.
          }
        }
        LOCAL gravity IS SHIP:BODY:MU / (SHIP:ALTITUDE + SHIP:BODY:RADIUS)^2.
        SET twr TO ROUND(thrst / (SHIP:MASS * gravity),2).
        SET thrst TO ROUND(thrst, 0).
        IF SHIP:HASSUFFIX("deltav") listout1:ADD("|DltV:"+ROUND(SHIP:DELTAV:CURRENT,0)+"      ").
        listout1:ADD("|THR: "+thrst+"      ").
        listout1:ADD("|TWR: "+TWR+"      ").
        IF FlState <> "Land"{ 
          listout1:ADD( "|PER: "+formatTime(ETA:PERIAPSIS)+"  ").
          LOCAL AP TO formatTime(ETA:APOAPSIS).
          IF AP <> "passed" AND AP <> 0 listout1:ADD( "|APO: "+AP+"  ").
        }
        IF steeringmanager:enabled = TRUE{
          IF HdngSet[3][4] > 0 AND HdngSet[0][4] > 0{listout1:ADD("|SPDLOCK:"+HdngSet[0][4]+"("+ROUND(SHIP:VELOCITY:SURFACE:MAG,0)+")"+glt(HdngSet[0][4],ROUND(SHIP:VELOCITY:SURFACE:MAG,0))+"  ").}
          IF HdngSet[3][5] > 0 AND HdngSet[0][5] > 0{listout1:ADD("|ALTLOCK:"+HdngSet[0][5]+"("+ROUND(SHIP:ALTITUDE,0)+")"+glt(HdngSet[0][5],ROUND(SHIP:ALTITUDE,0))+"  ").}
          IF HdngSet[3][6] > 0 AND HdngSet[0][6] > 0{listout1:ADD("|VSPDLOK:"+HdngSet[0][6]+"("+ROUND(SHIP:VERTICALSPEED,0)+")"+glt(HdngSet[0][6],ROUND(SHIP:VERTICALSPEED,0))+"  ").}
        }
      //hudtop middle
       listout2:ADD(PADMID(SHIP:STATUS,pwdt2)).
       listout2:ADD(PADMID(ItemList[hsel[2][1]]+":"+prtTagList[hsel[2][1]][hsel[2][2]],pwdt2)).
          IF senselist[5] = 1{
            SET biomecur TO BSensor:getmodule("ModuleGPS" ):getfield("biome").
            IF biomecur = "???" SET biomecur TO "UNKNOWN".
            listout2:ADD(PADMID(BODY:NAME+":"+BiomeCur,pwdt2)).
          }
      IF BODY:ATM:exists {
        SET HdngSet[1][5] TO BODY:ATM:HEIGHT.
        IF FlState = "SpaceATM"  {listout2:ADD(PADMID("ATM HEIGHT:"+BODY:ATM:HEIGHT+" M",pwdt2)).} 
      }
        SET foblink TO foblink+1.
        IF runauto = 3 {
          IF foblink = 1      {listout2:ADD(PADMID("***AUTO ACTNS DISABLED***",pwdt2)). listout2:ADD(PADMID("******SET IN AG1******",pwdt2)). }ELSE{listout2:ADD(PADMID("    ",pwdt2)). listout2:ADD(PADMID("******SET IN AG1******",pwdt2)).}
        }
      IF fo = 1{IF foblink = 1{listout2:ADD(PADMID("FLAMEOUT!",pwdt2)).}ELSE{listout2:ADD(PADMID("    ",pwdt2)).}}
        IF foblink = 2 SET foblink TO 0. 
        IF BRAKES = TRUE        listout2:ADD(PADMID("**BRAKE**",pwdt2)).
      IF Radartag > 0 {IF prtlist[radartag][1][1]:HASMODULE("ModuleRadar"){
          LOCAL rdrmod TO GetMultiModule(prtlist[radartag][1][1],"lock","ModuleRadar")[1].
          IF wordcheck(rdrmod[0],"current locks") = 1 AND rdrmod[1] > 0{listout2:ADD(PADMID("**LOCK**",pwdt2)).}
      }}
      IF BDPtag > 0 {
        IF getEvAct(prtlist[BDPtag][1][1],"BDModulePilotAI","deactivate pilot",1,3) = TRUE {
            LOCAL ptmp TO CheckTrue(30,prtlist[BDPtag][1][1],"BDModulePilotAI","standby mode","** AI PILOT STDBY **","** AI PILOT ON **",0,3).
            listout2:ADD(PADMID(ptmp,pwdt2)).
        }
      }
      IF steeringmanager:enabled = FALSE {IF MJB > 1{
        IF MJB = 2 listout2:ADD(PADMID("SAS: MECHJEB",pwdt2)).
        IF MJB = 3 listout2:ADD(PADMID("SAS: LANDING",pwdt2)).
        IF MJB = 4 listout2:ADD(PADMID("SAS: TRANSLATRON",pwdt2)).
        IF MJB = 5 listout2:ADD(PADMID("SAS: ASCENT",pwdt2)).
        }ELSE{IF SAS = TRUE listout2:ADD(PADMID("SAS:"+SASMODE,pwdt2)). ELSE listout2:ADD(PADMID("SAS OFF",pwdt2)).}}
      ELSE{
        IF HdngSet[3][4]+HdngSet[3][5]+HdngSet[3][6] = 0 listout2:ADD(PADMID("HEADING LOCK"+"-HD:"+HdngSet[0][1]+"("+ROUND(compass_and_pitch_for()[0],0)+")"+glt(HdngSet[0][1],ROUND(compass_and_pitch_for()[0],0),1),pwdt2)).
         ELSE {listout2:ADD(PADMID("AUTOPILOT"+"-HD:"+HdngSet[0][1]+"("+ROUND(compass_and_pitch_for()[0],0)+")"+glt(HdngSet[0][1],ROUND(compass_and_pitch_for()[0],0),1),pwdt2)).
         IF steeringmanager:enabled = TRUE IF abs(SteeringManager:ANGLEERROR) < 5 listout2:ADD(PADMID("MOVING TO HEADING")).
         }
        }
        IF MtrOps[hsel[2][1]][0] = 1 listout2:ADD(PADMID("***METER DISPLAY LOCKED***",pwdt2)).
        IF HLON = 1 listout2:ADD(PADMID("***HIGHLIGHTING ENABLED***",pwdt2)).
      //hudtop right
      //listout3:add("|THR"+SetGauge(ROUND(THROTTLE*100,0), 1, pwdt3-1)).
      LOCAL ECC TO ROUND(SHIP:ELECTRICCHARGE/ecmax*100,0).
      listout3:ADD("|ECG("+ECC+")"+SetGauge(ECC, 1, pwdt3-6)). 
      IF FlState = "Flight" listout3:ADD("|AOA: "+ROUND(vertical_aoa(),1)+"   ").
      listout3:ADD("|Speed: "+ROUND(SHIP:VELOCITY:SURFACE:MAG,0)+" M/S   ").
      LOCAL VSP TO ROUND(SHIP:VERTICALSPEED  ,0).
      IF VSP > 0 SET VSP TO " "+VSP.
      IF STATUSFLY:CONTAINS(SHIP:STATUS) listout3:ADD("|V-SPD:"+VSP+" M/S   ").
      listout3:ADD("|RDALT: "+ROUND(ALT:RADAR-HEIGHT,0)+"  ").
      LOCAL lng TO listout2:length+1.
      UNTIL listout2:length > 7 listout2:ADD("                          ").
      UNTIL listout3:length > 7 listout3:ADD("             ").
      UNTIL listout1:length > 7 listout1:ADD("             ").   
      RETURN LIST(LISTOUT1,listout2,listout3).
    }
  }
   FUNCTION UPDATEHUDOPTS{//options, sidelist and bototm buttons
    IF LastIn(-5) SpeedBoost().
    IF dbglog > 1 log2file("UPDATEHUDOPTS").
        IF SHIP:RESOURCES:tostring:contains("liquidfuel"){IF ROUND(SHIP:RESOURCES[RscNum["liquidfuel"]]:AMOUNT/SHIP:RESOURCES[RscNum["liquidfuel"]]:CAPACITY*100,0) < 10 SET forcerefresh TO 1.}
        IF SHIP:RESOURCES:tostring:contains("ELECTRICCHARGE"){IF ROUND(SHIP:RESOURCES[RscNum["ELECTRICCHARGE"]]:AMOUNT/SHIP:RESOURCES[RscNum["ELECTRICCHARGE"]]:CAPACITY*100,0) < 10 SET forcerefresh TO 1.}
      //#region set hud vars
      IF buttonRefresh > 0 AND forcerefresh = 0 SET forcerefresh TO 1. 
      GLOBAL itemnumcur TO hsel[2][1].
      IF itemnumcur <> ItemNumPrv AND GrpDspList[itemnumcur][0] < prttaglist[itemnumcur][0]+1 {SET hsel[2][2] TO GrpDspList[itemnumcur][0].}
      GLOBAL TagNumCur TO hsel[2][2].
      LOCAL AutoCurMode TO abs(AutoDspList[itemnumcur][TagNumCur]).
      SET Curdelay TO AutoTRGList[0][itemnumcur][TagNumCur].
      GLOBAL tagnamecur TO prttaglist[itemnumcur][TagNumCur].
      LOCAL npskp TO 1.
      IF itemnumcur <> AGTag AND itemnumcur <> flytag AND (itemnumcur <>CMDTag AND TagNumCur < cmdln+1) SET NpSkp TO 0.
      SET rowval TO 0.
      IF RowSel=1 SET rowval TO 1.
      IF NEWHUD = 1 SET newhud TO 0.
      IF itemnumcur <> ItemNumPrv OR TagNumCur <> tagNumPrv {SET newhud TO 1. IF dbglog > 1 log2file("   NEWHUD").}
      IF NEWHUD = 1 OR forcerefresh > 0 OR (hudop <> 5 AND HUDOPPREV = 5) {
        SET WarnLst TO "".
        IF forcerefresh > 0 {SET BOTPREV TO "zz". SET STPREV TO "zz".}
        SET hsel[2][3] TO MAX(getgoodpart(itemnumcur,TagNumCur,1),1).
        GLOBAL partnumcur TO hsel[2][3].
        GLOBAL currentPart TO prtlist[itemnumcur][TagNumCur][partnumcur].
        IF HlOn = 1 AND hlparts <> 0 {IF HLPARTS:enabled SET hlParts:enabled TO FALSE.}
        IF NpSkp = 0 {
        GLOBAL CleanParts TO CleanList(prtList[itemnumcur][TagNumCur], tagnamecur).
          IF CleanParts:length > 0 {
            SET hlParts TO HIGHLIGHT(CleanParts, rgb(0,0,1)).
            IF hlparts <> 0 {
              IF HlOn = 1 SET hlParts:enabled TO TRUE. ELSE SET hlParts:enabled TO FALSE. 
            }
          }
        }
        SET DCPRes TO 0.
      GLOBAL alttag TO 0.
        IF hudop <> 5 AND HUDOPPREV = 5 { PRINTLINE("",0,1).  PRINTLINE("",0,14).}
          SET ItmTrg TO grpopslist[itemnumcur][TagNumCur][GrpDspList[itemnumcur][TagNumCur]]. 
          SET BTHD10 TO grpopslist[itemnumcur][TagNumCur][GrpDspList2[itemnumcur][TagNumCur]]. 
          SET BTHD11 TO grpopslist[itemnumcur][TagNumCur][GrpDspList3[itemnumcur][TagNumCur]].
          SET PrvITM TO CHECKOPT(ITEMLIST[0],itemnumcur,"-",6,1,1).
          SET nxtITM TO CHECKOPT(ITEMLIST[0],itemnumcur,"+",6,1,1).
          IF newhud = 1 printbothud().
      }

      IF BtnActn = 1 {updatehudSlow(). RETURN.}
          IF BtnActn = 0 {
            IF ROWVAL = 0 {
              SET PrvGRP TO CHECKOPT(prtTagList[itemnumcur][0], TagNumCur,"-",7,1,1).
              SET nxtGRP TO CHECKOPT(prtTagList[itemnumcur][0], TagNumCur,"+",7,1,1).
              PRINT "                               " AT (0,3).
              PRINT "                               " AT (0,7).
              PRINT PrvGRP AT (0,3).
              PRINT nxtGRP AT (0,7).
            }ELSE{
              SET PrvGRP TO "                               ".
              SET nxtGRP TO "                               ".
            }
          }
      IF AutoCurMode = 14 SET StsSelection TO abs(AutoValList[itemnumcur][TagNumCur]).
      IF StsSelection > STATUSOPTS[0] SET StsSelection TO STATUSOPTS[0]. 
      IF StsSelection = 0 SET StsSelection TO 1.
      IF hudop =5 AND HUDOPPREV <> 5 {
        SET EnabSel TO itemnumcur.
      }
      IF hudop < 6 SET HudOptsR[6] TO AutoValList[itemnumcur][TagNumCur].
      //#endregion
      //#region check missing part
      SET  missingpart TO 0.
      IF alltagged:length <> SHIP:ALLTAGGEDPARTS():length partcheck().
      LOCAL pl TO prtList[itemnumcur][TagNumCur].
      SET pl TO pl:sublist(1, pl:length).
      IF NpSkp = 0{FOR p IN pl{IF NOT PrtListcur:contains(p) OR BadPart(p , tagnamecur) SET MissingPart TO MissingPart+1.}}
      LOCAL dcpg TO 0.
      IF itemnumcur = dcptag{FOR p IN pl{IF p <> "" {IF p <> CORE:PART{SET dcpg TO 0.}}}}
      //#endregion
      //#region run on change
      IF missingpart < prtlist[itemnumcur][TagNumCur]:length-1 AND dcpg <> 1{
        IF NEWHUD > 0 OR forcerefresh > 0 {
        IF MeterList[2][itemnumcur][0] <> 0 AND hsel[2][3] <> partnumprv SetCurrentMeter().
        SET partnumprv TO partnumcur.
          IF NEWHUD = 1 {
            SET AutoSetAct TO AutoTRGList[itemnumcur][TagNumCur].
            SET autosetmode TO autocurmode.
            SET setdelay TO curdelay.
            SET AutoRstMode TO autoRstList[itemnumcur][TagNumCur].
            IF itemnumcur <> dcptag SET AutoValList[0][0][3][15] TO 0.
            SET LOADBKP TO 0. SET SAVEBKP TO 0. 
            LOCAL CLSKP TO 0.
            IF (itemnumcur = flytag AND TagNumCur = 1) OR itemnumcur = agtag SET CLSKP TO 1.
            IF (GrpDspList3[FLYTAG][1] <> 6 AND RunAuto = 1 AND itemnumcur <> scitag AND CLSKP = 0) OR (forcerefresh > 0 AND clskp = 0) PRINTLINE("",0,13).
            SET botrow TO bigempty2. 
            SET BaySel TO 1. 
            SET fuelmon TO 0. 
            IF itemnumcur = FlyTag SET AUTOHUD[1] TO 1. 
            SET axsel TO 1. 
            SET scipart TO 1.
            IF TagNumCur <> tagNumPrv {SET GrpDspList[itemnumcur][0] TO TagNumCur.}
            IF AutoCurMode = 6 AND autoRscList[itemnumcur][TagNumCur]:istype("string") SET RscSelection TO safekey(RscNum,autoRscList[itemnumcur][TagNumCur]). 
            SET meterpart TO 0.
          SET hudopts[1][1] TO "".
          SET hudopts[1][2] TO "".
          SET hudopts[1][3] TO "".
          }
          SET MtrCur[5] TO ActiveMeter[itemnumcur].
          IF MeterList[2][itemnumcur][0] <> 0 {SET DispInfo TO 11. SetCurrentMeter().}ELSE{
            SET DispInfo TO 1.
            SET MtrCur[0] TO 0.
            SET MtrCur[1] TO 100.
            SET MtrCur[2] TO 5.
            IF MtrCur[5] < MtrCur[3] SET MtrCur[5] TO MtrCur[3].
            IF MtrCur[5] > MtrCur[4] SET MtrCur[5] TO MtrCur[4].
          }
          SET rowT1 TO "".
          SET rowT2 TO "".
          SET statusdispnum TO GrpDspList[itemnumcur][TagNumCur].
          IF GrpDspList[itemnumcur][TagNumCur]= 1 SET statusdispnum TO 3.
          IF GrpDspList[itemnumcur][TagNumCur]= 5 SET statusdispnum TO 7.
          IF HUDOP <> 5{
          SET ln14 TO 0.
          IF itemnumcur = lighttag { 
          IF getactions("OnOff",MeterList[0][1],itemnumcur, TagNumCur,2,6,LIST("blink"),LIST("blink")) = 0 SET bthd10 TO EmptyHud.
          IF currentPart:HASMODULE("ModuleNavLight") AND rowval = 1{
            SET BTHD10 TO SetButtonContent(meterlist[0][1],"activate flash","dectivate flash"," FLASH OFF"," FLASH ON ").
            SET BTHD11 TO SetButtonContent(meterlist[0][1],"activate double flash","dectivate double flash","DBFLSH OFF","DBFLSH ON ").
          }
          IF TagNumCur = 1 AND ROWVAL = 0 {SET BTHD11 TO " SAVE BKP ". IF file_exists(autofileBAK) SET BTHD10 TO " LOAD BKP ". ELSE SET BTHD10 TO EmptyHud. }
          }
          ELSE{
          IF itemnumcur = AGtag {
            SET DispInfo TO 1.
           IF TagNumCur = 11 AND THROTTLE > 0 {SET GrpDspList[itemnumcur][TagNumCur] TO 2. SET ItmTrg TO " TURN OFF ".}ELSE{ SET GrpDspList[itemnumcur][TagNumCur] TO 1. SET ItmTrg TO " TURN ON  ".}
            IF TagNumCur = 1{
              IF RunAuto = 1 SET BTHD10 TO " AUTO ON  ". ELSE IF RUNAUTO = 3 SET BTHD10 TO " AUTO OFF ". ELSE IF RunAuto = 2 OR RunAuto = 0 SET BTHD10 TO " AUTO WAIT".
              SET bthd11 TO " LIST AUTO".
            }
                IF TagNumCur = 2 {SET BTHD11 TO " SAVE BKP ". IF file_exists(autofileBAK) SET BTHD10 TO " LOAD BKP ". }
                IF tagNumcur = 3 {
                IF HLon = 1 SET BTHD10 TO "HGHLGT ON ". ELSE SET BTHD10 TO "HGHLGT OFF".
              }
                IF tagNumcur = 4 {
                  LOCAL PLC TO 35.
                  IF ROWVAL = 0{
                    PRINTLINE(" Processing Speed: "+Removespecial(speeds[0][SPEEDSET[0]],"  ")+":EST EC per Second:"+ROUND((speeds[1][SPEEDSET[0]]*0.000004*25),2),mtrcolor((SPEEDSET[0]/(speeds[0]:length-1))*100),13).
                    PRINTLINE(" BOOST Speed     : "+Removespecial(speeds[0][SPEEDSET[1]],"  ")+":EST EC per Second:"+ROUND((speeds[1][SPEEDSET[1]]*0.000004*25),2),mtrcolor((SPEEDSET[1]/(speeds[0]:length-1))*100),14).
                    SET ln14 TO 2.
                    SET BTHD10 TO speeds[0][SPEEDSET[0]].
                    SET BTHD11 TO speeds[0][SPEEDSET[1]].
                    PRINT "                       " AT (35,heightlim-3).
                  }
                  ELSE{
                    PRINTLINE(" Power save Processing Speed: "+Removespecial(speeds[0][SPEEDSET[2]],"  ")+":EST EC per Second:"+ROUND((speeds[1][SPEEDSET[2]]*0.000004*25),2),mtrcolor((SPEEDSET[2]/(speeds[0]:length-1))*100),13).
                    PRINTLINE(" Power save BOOST Speed     : "+Removespecial(speeds[0][SPEEDSET[3]],"  ")+":EST EC per Second:"+ROUND((speeds[1][SPEEDSET[3]]*0.000004*25),2),mtrcolor((SPEEDSET[3]/(speeds[0]:length-1))*100),14).
                    SET ln14 TO 2.
                    SET BTHD10 TO speeds[0][SPEEDSET[2]].
                    SET BTHD11 TO speeds[0][SPEEDSET[3]].
                    PRINT "| PWR SAVE |          |" AT (35,heightlim-3).
                  }
                  IF printpause = 0 {
                    PRINT "|PROCESSING|   BOOST  |" AT (34,heightlim-2).
                    PRINT "|   SPEED  |   SPEED  |" AT (34,heightlim-1).
                  }
              }
            IF rowsel = 1{
              //if tagNumcur = 2{
             //   set BTHD10 to "RFRSH HUD ". SET BTHD11 TO "RFRSH INFO".
            //        PRINTLINE(" HUD refreshRate: "+refreshRateSlow+" SECONDS"+" INFO refreshRate: "+refreshRateFast+" SECONDS","WHT",14).  SET ln14 TO 1.
             // }
              IF tagNumcur = 10{
                IF dbglog = 0 SET BTHD10 TO "  LOG OFF ". ELSE IF dbglog = 1 SET BTHD10 TO "  LOG ON  ".IF dbglog = 2 SET BTHD10 TO "LOG VRBOSE".  IF dbglog = 3 SET BTHD10 TO "LOG OVRKLL".
                IF debug  = 0 SET BTHD11 TO " DEBUG OFF". ELSE SET BTHD11 TO " DEBUG ON ".
                PRINTLINE(" ONLY ENABLE LOGGING IF YOU ARE HAVING A PROBLEM","RED",14).
                SET ln14 TO 1.
              }
              }
          }
          ELSE{
          IF itemnumcur = Flytag {
            SET DispInfo TO 52.
            IF TagNumCur = 1 {
              SET ln14 TO 2.
               SET trglst TO getRTVesselTargets(2).
              IF rowval = 1 {
                SET BTHD11 TO "NEXT OPTN ". 
                IF apsel = 3 SET zop TO 2. 
                IF zop = 1 SET BTHD10 TO "ONE 2 CRNT". ELSE SET BTHD10 TO "ONE 2 ZERO".
              IF hdngset[3][axsel] = 1 SET ItmTrg TO " MODE ON  ". ELSE SET ItmTrg TO " MODE OFF ".
              IF apsel = 1 OR axsel = 7 OR axsel = 9 IF AUTOHUD[1] > 3 SET AUTOHUD[1] TO 3.
               }
              ELSE{SET BTHD10 TO "ALL 2 CRNT".}
            }
            ELSE{
              SET BTHD10 TO EmptyHud.
              SET BTHD11 TO emptyhud.
            }
          }
          ELSE{ 
          IF itemnumcur = CMDtag {
            IF getactions("OnOff",LIST("ModuleScienceContainer"),itemnumcur, TagNumCur,2,6,LIST("collect all"),LIST("collect all")) = 0 SET bthd10 TO EmptyHud.
            IF TagNumCur > cmdln {SET ItmTrg TO "  TOGGLE  ". SET bthd10 TO "DSBL MCHJB".}
          }
          ELSE{
          IF itemnumcur = geartag  {
            IF AutoBrake = 0 SET BTHD10 TO " BRAKE OFF". ELSE
            IF AutoBrake = 1 SET BTHD10 TO " BRAKE ON ". ELSE
            IF AutoBrake = 2 SET BTHD10 TO "AUTO BRAKE". 
              IF rowval = 1 {
                IF CurrentPart:HASMODULE("ModuleWheelSuspension") SET ItmTrg TO CheckTrue(3,currentPart, "ModuleWheelSuspension","spring strength"  ,"SPRNG MAN ","SPRNG AUTO"). ELSE{SET ItmTrg TO EmptyHud.}
                IF CurrentPart:HASMODULE("ModuleWheelBase")       SET BTHD10 TO CheckTrue(3,currentPart, "ModuleWheelBase"      ,"friction control" ,"FRCTN MAN ","FRCTN AUTO"). ELSE{SET BTHD10 TO EmptyHud.}
                IF CurrentPart:HASMODULE("ModuleWheelSteering")   SET BTHD11 TO CheckTrue(3,currentPart, "ModuleWheelSteering"  ,"steering response","STEER MAN ","STEER AUTO"). ELSE{SET BTHD11 TO EmptyHud.}
              }
          }
          ELSE{
          IF itemnumcur = baytag{SET DISPINFO TO 33.}
          ELSE{
          IF itemnumcur = FRNGtag {SET ItmTrg TO CheckTrue(3,currentPart, "ModuleProceduralFairing","deploy"  ,"  DEPLOY  "," DEPLOYED ").}
          ELSE{
          IF itemnumcur = anttag {
            SET DispInfo TO 21. 
          IF rtech <> 0{
            SET ln14 TO 1.
            SET trglst TO getRTVesselTargets().
            IF rowval=1 AND meterlist[0][0]:contains("target"){
              SET PrvGRP TO CHECKOPT(trglst[0], anttrgsel,"-",trglst,1,1).
              SET nxtGRP TO CHECKOPT(trglst[0], anttrgsel,"+",trglst,1,1).
              IF trglst[anttrgsel] = getEvAct(CurrentPart,"ModuleRTAntenna","target",30) SET ItmTrg TO " CRNT TRG ". ELSE SET ItmTrg TO "SET TARGET".}
            }
               IF GetActions("ONOFF",MeterList[1][itemnumcur],itemnumcur, TagNumCur,1,6,LIST("extend","deploy","Activate"),LIST("retract","close")) = 0 SET itmtrg TO EmptyHud.
               IF GetActions("ONOFF",MeterList[1][itemnumcur],itemnumcur, TagNumCur,3,6,LIST("transmit")) = 0 SET BTHD11 TO EmptyHud.
              }
          ELSE{
          IF itemnumcur = Docktag {
            SET dispinfo TO 21.
          IF getactions("OnOff",LIST("ModuleToggleCrossfeed"),itemnumcur, TagNumCur,1,6,LIST("enable"),LIST("disable")) = 0 SET bthd11 TO EmptyHud.
          IF getactions("OnOff",MeterList[1][itemnumcur] ,itemnumcur, TagNumCur,1,6,LIST("OPEN","TOGGLE","CLOSE")) = 0 SET bthd10 TO EmptyHud.
          IF currentPart:HASSUFFIX("HASPARTNER") IF currentPart:HASPARTNER = TRUE  SET GrpDspList[itemnumcur][TagNumCur] TO 2. ELSE SET GrpDspList[itemnumcur][TagNumCur] TO 1.
          IF currentPart:HASSUFFIX("STATE") IF currentPart:STATE ="DISABLED" SET GrpDspList2[itemnumcur][TagNumCur] TO 3.
          IF rowval = 1{IF getEvAct(CurrentPart,"ModuleDockingNode","control from here",3) SET ItmTrg TO "CNTRL FROM".}
          }
          ELSE{
            IF itemnumcur = CntrlTag {
            LOCAL cnt TO 0.
              FOR Cfld IN CntrlFldList{
                LOCAL Ctag TO MeterList[0][2][0]:find(Cfld).
                IF Ctag > -1 SET MeterList[0][2][1][Ctag] TO 0-CNTRLLimLst[TagNumCur][cnt]+"/"+CNTRLLimLst[TagNumCur][cnt]+"/1".
                SET cnt TO cnt+1.
                SET REMETER TO 1.
              }
            }
          ELSE{
          IF itemnumcur = ISRUTag {SET DispInfo TO 41.SET HDXT TO "RSRC".}
          ELSE{
          IF itemnumcur = RBTTag {
            IF currentPart:HASMODULE("ModuleRoboticController"){
              FOR i IN RANGE(1,10,3){
                SET modulelist[0][itemnumcur][i] TO "ModuleRoboticController". 
              }
              SET ItmTrg TO "PLAY/PAUSE".
              SET BTHD10 TO "LOOP MODE ".
              SET BTHD11 TO "DIRECTION ".
              IF ROWVAL = 1 SET BTHD11 TO "ENAB/DISAB".
            }
              ELSE{ 
              IF autoRstList[0][0][tagnumcur] = 0 SET BTHD11 TO "  NO LOCK ".       
              ELSE IF autoRstList[0][0][tagnumcur] > 0 SET BTHD11 TO "AUTO:"+autoRstList[0][0][tagnumcur]+" SEC".
              LOCAL count TO 0.
              FOR MD IN MeterList[0][1]{
                IF CurrentPart:modules:contains(MD){
                  FOR i IN RANGE(1,11,3){
                    SET modulelist[0][RBTTag][i] TO MD. 
                  }
                  IF MD = "ModuleRoboticServoPiston" AND fieldlist[1] = "target extension"{                               
                    IF CurrentPart:title:contains("1p2") SET mtrcur[7][1] TO "0.8".
                    IF CurrentPart:title:contains("1p4") SET mtrcur[7][1] TO "2.4".
                    IF CurrentPart:title:contains("3p6") SET mtrcur[7][1] TO "1.6".
                    IF CurrentPart:title:contains("3pt") SET mtrcur[7][1] TO "4.8".
                  }
                  IF MD = "ModuleRoboticServoHinge" AND fieldlist[1] = "target angle"{
                    IF CurrentPart:title:contains("G-00") {SET mtrcur[7][0] TO "-90". SET mtrcur[7][1] TO "90".}
                    IF CurrentPart:title:contains("G-11") {SET mtrcur[7][0] TO "-90". SET mtrcur[7][1] TO "90".}
                  }                            
                  BREAK.
                }SET count TO count+1.
              }
            }
          }
          ELSE{
          IF itemnumcur = SMRTtag {
                IF currentpart:HASMODULE("Timer"){
                    LOCAL ccc TO  getactions("OnOff",LIST("Timer"),itemnumcur, TagNumCur,1,1,LIST("use minutes"), LIST("use seconds")).
                    IF ccc > 0{
                    IF ccc= 1 SET BTHD10 TO "  SECONDS ".
                    IF ccc= 2 SET BTHD10 TO "  MINUTES ". 
                    }
                    SET ItmTrg TO SetButtonContent(LIST("Timer"),"Start countdown","","   START  ","  RUNNING ").
                }
                SET BTHD11 TO SetButtonContent(MeterList[0][1],"Reset","Reset","   RESET  ","   RESET  ").
                IF currentpart:HASMODULE("smartsrb") SET ItmTrg TO EmptyHud.
          }ELSE{
          IF itemnumcur = scitag {
            SET STPREV TO "zzz".
            SET meterpart TO 0.
            SET scanlist TO LIST().
            IF currentpart:HASMODULE("ModuleResourceScanner"){
              FOR i IN range (0,currentpart:modules:length-1){
                IF currentpart:modules[i] = "ModuleResourceScanner" scanlist:ADD(currentpart:getmodulebyindex(i):allfieldnames[0]+":"+currentpart:getmodulebyindex(i):getfield(currentpart:getmodulebyindex(i):allfieldnames[0]):tostring).
              }
              LOCAL scl TO MAX(0,scanlist:length-1).
              SET Lscroll TO LIST(MIN(Lscroll[0],scl),scl).
            }
            SET DispInfo TO 12.
            LOCAL ccc TO  getactions("OnOff",LIST("scansat"),itemnumcur, TagNumCur,2,1,LIST("start"), LIST("stop")).
            IF ccc > 0{
              IF ccc= 1 SET bthd11 TO "START SCAN".
              IF ccc= 2 SET bthd11 TO "STOP  SCAN". 
            }
              FOR md IN sciModData{
              IF currentpart:HASMODULE(md){
                LOCAL PM TO currentpart:GetModule(md).
                IF pm:HASSUFFIX("data"){
                  IF pm:Hasdata {
                    LOCAL test TO Removespecial(pm:data[0]:title," while").
                    SET test TO Removespecial(test," just").
                    LOCAL Xdata TO ROUND(pm:data[0]:transmitvalue,2).
                    LOCAL Sdata TO ROUND(pm:data[0]:sciencevalue,2).
                    LOCAL lmt TO 13+Sdata:tostring:length+Xdata:tostring:length.
                    IF test:tostring:length > WidthLim-lmt SET test TO test:substring(0,WidthLim-lmt).
                    LOCAL brp TO test+"-(RTN:"+Sdata+" XMIT:"+Xdata+")".
                    LOCAL brpc TO "GRN".
                    IF colorprint = 1 AND brp:length < widthlim-8 SET brpc TO "WHT".
                    SET botrow TO GetColor(test+"-(RTN:"+Sdata+" XMIT:"+Xdata+")",brpc).
                    SET BTHD10 TO " TRANSMIT ".
                  }
                }
                IF currentpart:HASMODULE("scansat"){
                  LOCAL mdl TO currentpart:getmodule("scansat").
                  SET SciDsp TO mdl:allfieldnames.
                  IF SciDsp:contains("scan altitude"){
                    LOCAL scalt TO mdl:getfield("scan altitude").
                    SET scalt TO scalt:split(">").
                    LOCAL IdealAlt TO scalt[1].
                    SET scalt TO scalt[0]:split("-").
                    SET scalt[0] TO scalt[0]+"000".
                    SET scalt[1] TO scalt[1]:REPLACE("km", "000"). 
                    SET IdealAlt TO IdealAlt:REPLACE("km Ideal", "000"). 
                    SET scalt[0] TO removeletters(SCALT[0],", :").
                    SET scalt[1] TO removeletters(SCALT[1],", :").
                    SET IdealAlt TO removeletters(IdealAlt,", :").
                    LOCAL altmin TO scalt[0]:tonumber.
                    LOCAL altmax TO scalt[1]:tonumber.
                    LOCAL altidl TO idealalt:tonumber.
                    LOCAL po TO bigempty2.
                    IF SHIP:ALTITUDE < altmin SET po TO " TOO LOW! INCREASE ALT BY "+ (ALTMIN-ROUND(SHIP:ALTITUDE,0))+"M TO RUN. MIN:("+ALTMIN+")             ".
                    IF SHIP:ALTITUDE > altmax SET po TO " TOO HIGH! DECREASE ALT BY "+((ROUND(SHIP:ALTITUDE,0))-altmax)+"M TO RUN. MAX("+ALTMAX+")             ".
                    IF SHIP:ALTITUDE > altmin      AND SHIP:ALTITUDE < altmax      { SET po TO " WITHIN SCAN ALT.".
                      IF SHIP:ALTITUDE < altidl*.9 SET po TO PO+"INCREASE BY "+ (altidl*.9-ROUND(SHIP:ALTITUDE,0)) +"M TO REACH IDEAL RANGE:("+altidl*.9+"-"+altidl*1.1+")             ".
                      IF SHIP:ALTITUDE > altidl*1.1 SET po TO PO+"DECREASE BY "+(ROUND(SHIP:ALTITUDE,0)-altidl*1.1)+"M TO REACH IDEAL RANGE:("+altidl*1.1+"-"+altidl*.9+")             ".
                    }
                    IF SHIP:ALTITUDE > altidl*.9 AND SHIP:ALTITUDE < altidl*1.1 SET po TO " WITHIN IDEAL RANGE:("+altidl*.9+"-"+altidl*1.1+")                            ".
                    LOCAL PO3 TO "                     ".
                    IF bthd11 = "STOP  SCAN" SET po3 TO " SCANNER DEPLOYED                      ". ELSE SET PO3 TO " SCANNER RETRACTED                      ".
                    IF SciDsp:contains("scan type") SET PO3 TO " SCAN:"+mdl:getfield("scan type")+":"+po3.
                    IF po3:length > WidthLim SET po3 TO po3:substring(0,(WidthLim-2)).
                    printline(po3,0,13). 
                    printline(po,0,14).
                    SET ln14 TO 2.
                  }
                  IF SciDsp:length > 0{
                  SET hudopts[1][1] TO "Scan Info:"+scipart.  
                  SET hudopts[1][2] TO ":"+SciDsp[scipart-1].
                  SET hudopts[1][3] TO ":"+mdl:getfield(SciDsp[scipart-1]).
                }ELSE{SET hudopts[1][1] TO "No scan info".}
                SET ln14 TO 2.
                }ELSE{
                   PRINTLINE("",0,14). IF GrpDspList3[FLYTAG][1] <> 6 PRINTLINE("",0,13).
                  SET SciDsp TO pm:alleventnames.
                  IF SciDsp:length = 0 SET SciDsp TO pm:allactionnames.
                  IF SciDsp:length > 0{
                  SET hudopts[1][2] TO scipart.  
                  SET hudopts[1][3] TO ":"+SciDsp[scipart-1].
                  SET hudopts[1][1] TO "Experiment:".
                }ELSE{SET hudopts[1][1] TO "No experiment or data full".}
                BREAK.
              }}
            }
          IF getactions("OnOff",SciModAlt,itemnumcur, TagNumCur,1,6,LIST("review")) <> 0 SET itmtrg TO "  DELETE  ".
          IF getactions("OnOff",LIST("SCANexperiment"),itemnumcur, TagNumCur,0,6,LIST("analyze")) <> 0 SET itmtrg TO "  ANALYZE ".
          IF getactions("OnOff",SciModAlt,itemnumcur, TagNumCur,3,6,LIST("transmit")) = 0 AND BTHD10 <> " TRANSMIT "{
            LOCAL actn TO GetActions(1,AnimModAlt,itemnumcur, TagNumCur,2,1,LIST("deploy","extend"),LIST("retract","close")).
            IF actn = 0 {SET BTHD10 TO EmptyHud.} ELSE{ IF actn = 3 SET actn TO 1.
              IF actn < 3 {
                SET GrpDspList2[itemnumcur][TagNumCur] TO actn+2. 
                SET BTHD10 TO grpopslist[itemnumcur][TagNumCur][GrpDspList2[itemnumcur][TagNumCur]]. 
              }
            }
          }
          IF getactions("OnOff",LIST("ModuleScienceContainer"),itemnumcur, TagNumCur,3,6,LIST("collect")) <> 0 {
            LOCAL amt TO LIST(0,0,0).
            SET cnt TO 0.
            LOCAL spc TO "     ".
            IF colorprint = 1 SET spc TO "   ".
            IF  currentpart:HASMODULE("ModuleScienceContainer"){
            SET BTHD11 TO " CLCT SCI ".
              FOR dt IN currentpart:getmodule("ModuleScienceContainer"):data {
                SET cnt TO cnt+1.
                SET amt[0] TO ROUND(amt[0]+dt:sciencevalue,2).
                SET amt[1] TO ROUND(amt[1]+dt:transmitvalue,2).
                SET amt[2] TO ROUND(amt[2]+dt:DATAAMOUNT,2).
              }
            SET botrow TO GetColor(cnt+" Experiments"+SPC+"Data:"+amt[2]+spc+"Science Val:"+amt[0]+spc+"Xmit Val:"+amt[1]+spc,"WHT").
            }
          }ELSE{
            IF GetActions(1,SciModAlt,itemnumcur, TagNumCur,3,6,LIST("reset"), LIST("reset")) <> 0 {SET BTHD11 TO "  RESET   ".}
          }
            }
          ELSE{
          IF itemnumcur = EngTag  {
            getEvAct(CurrentPart,"ModuleGimbal","show actuation toggles",10).
            IF currentpart:HASSUFFIX("ignition"){IF currentpart:ignition = FALSE SET GrpDspList[itemnumcur][TagNumCur] TO 1. ELSE SET GrpDspList[itemnumcur][TagNumCur] TO 2.}
            IF currentpart:HASMODULE("MultiModeEngine"){}ELSE{
                SET BTHD10 TO emptyhud.
                IF currentpart:HASMODULE("FSengineBladed"){
                    IF rowval = 1 {
                        SET HDXT TO "OPTN".
                        SET BTHD10 TO CheckTrue(30, currentpart, "FSengineBladed","thr keys" ,"*THR KEYS*"," THR KEYS ").
                        SET BTHD11 TO CheckTrue(30, currentpart, "FSengineBladed","thr state","*THR STAT*"," THR STAT ").
                    }ELSE{
                        SET BTHD10 TO " HOVER TGL".
                        SET BTHD11 TO CheckTrue(30, currentpart, "FSengineBladed","steering" ," STEER ON "," STEER OFF").
                    }
                }
                IF currentpart:HASMODULE("FSswitchEngineThrustTransform"){
                    LOCAL ccc TO  getactions("OnOff",LIST("FSswitchEngineThrustTransform"),itemnumcur, TagNumCur,1,1,LIST("reverse"), LIST("normal")).
                    IF ccc > 0{
                    IF ccc= 1 SET BTHD10 TO " FWD THRST".
                    IF ccc= 2 SET BTHD10 TO "RVRS THRST". 
                    }
                }
                
            }
          }
          ELSE{
          IF itemnumcur = Inttag {
            //local ccc to  getactions("OnOff",LIST("ModuleResourceIntake"),itemnumcur, TagNumCur,1,1,LIST("open"), LIST("close")).
            //if ccc > 0  set GrpDspList[itemnumcur][TagNumCur] to ccc.
          }
          ELSE{
          IF itemnumcur = labtag {
            IF getactions("OnOff",LIST("ModuleScienceContainer"),itemnumcur, TagNumCur,3,6,LIST("collect")) <> 0 SET BTHD11 TO " CLCT SCI ".
          }
          ELSE{
          IF itemnumcur = slrtag {
            IF getactions("OnOff",LIST("ModuleAnimateGeneric"),itemnumcur, TagNumCur,1,6,LIST("extend","toggle"),LIST("retract","toggle")) = 0 SET bthd10 TO EmptyHud.
          }
          ELSE{
          IF itemnumcur = WMGRtag   {IF rowval = 0 {SET BTHD11 TO "NEXT TEAM ".} IF rowval = 1 AND Radartag > 0{ SET BTHD10 TO "NEXT TRGT ".}}
          ELSE{
          IF itemnumcur = BDPtag   {
            SET ItmTrg TO CheckTrue(1,currentPart,"BDModulePilotAI","deactivate pilot"," TURN OFF "," TURN ON  ").
          }
          ELSE{
          IF itemnumcur = dcptag   {
            SET AutoValList[0][0][3][15] TO 1.
          IF DcpPrtList[TagNumCur][1]:HASSUFFIX("resources") {
          IF DcpPrtList[TagNumCur][1]:typename = "string" {SET fuelmon TO 0.}
            ELSE{
              IF DCPRes = 0 {
                LOCAL rscl TO getRSCList(DcpPrtList[TagNumCur][1]:RESOURCES).
                SET prsclist TO rscl[0].
                SET prsclist2 TO rscl[2].
                SET pRscNum TO rscl[1].
                SET DCPRes TO 1.
              }
              IF newhud = 1 {
                IF autoRscList[itemnumcur][TagNumCur]:istype("string") {
                      SET RscSelection TO safekey(pRscNum,autoRscList[itemnumcur][TagNumCur]). } 
                ELSE {SET RscSelection TO autoRscList[itemnumcur][TagNumCur].}
              }
              IF HudOpts[2][2][TagNumCur]:contains("Payload") OR prsclist:length=0 {SET fuelmon TO 0.}ELSE{SET fuelmon TO 1.}
              IF rowval=1{SET HDXT TO " RSC".
              IF prsclist2:length > 0 {
                IF prsclist2[0] <> "" AND fuelmon = 1 AND rowval = 1{
                  SET PrvGRP TO CHECKOPT(prsclist2:length-1, RscSelection,"-",prsclist2,0,1).
                  SET nxtGRP TO CHECKOPT(prsclist2:length-1, RscSelection,"+",prsclist2,0,1).
                }}
              }
            }
          }ELSE SET fuelmon TO 0.
            SET dispinfo TO 0.
            IF getactions("OnOff",LIST("ModuleToggleCrossfeed"),itemnumcur, TagNumCur,1,6,LIST("enable"),LIST("disable")) = 0 SET bthd10 TO EmptyHud.
            IF currentpart:HASMODULE("ModuleAnimateGeneric"){
              LOCAL pm TO currentpart:getmodule("ModuleAnimateGeneric"):allactionnames.
              SET pm2 TO currentpart:getmodule("ModuleAnimateGeneric"):ALLEVENTNAMES.
              SET pm3 TO LIST().
              FOR itm IN pm pm3:ADD(itm).
              FOR itm IN pm2 pm3:ADD(itm).
              FOR k IN range (0,pm3:length){
                  SET BTHD11 TO EmptyHud.
                  IF pm3[k]:contains("inflate") SET BTHD11 TO " INFLATE  ".
                  IF pm3[k]:contains("deflate") SET BTHD11 TO " DEFLATE  ".
                  IF pm3[k]:contains("deploy")  SET BTHD11 TO "  DEPLOY  ".
              }
            }   
          }
          ELSE{
          IF mks = 1 {
            IF itemnumcur = DEPOtag   {SET DispInfo TO 21.}
            ELSE{
            IF itemnumcur = PWRTag {SET DispInfo TO 41.
            IF currentPart:HASMODULE("USI_InertialDampener"){
              LOCAL OnOff TO CurrentPart:Getmodule("USI_InertialDampener"):alleventnames[0].
              IF OnOff = "ground tether: off" SET BTHD11 TO " TETHR OFF".
              IF OnOff = "ground tether: on" SET BTHD11 TO  " TETHR ON ".
            }
            SET HDXT TO "    ".
            SET BayLst TO GetMultiModule(CurrentPart,"recipe").
            IF currentpart:HASMODULE("USI_Converter"){ SET BayTrg TO GetMultiModule(CurrentPart,"","USI_Converter").}
            }
            ELSE{
            IF itemnumcur = MksDrlTag {
              SET DispInfo TO 41.
              }
              ELSE{
              IF itemnumcur = CnstTag {}
              ELSE{
              IF itemnumcur = DcnstTag {}
              ELSE{
              IF itemnumcur = habTag {
                IF currentpart:HASMODULE("USI_BasicDeployableModule"){
                IF currentpart:getmodule("USI_BasicDeployableModule"):hasfield("paid"){ 
                  SET PaidMeter TO currentpart:getmodule("USI_BasicDeployableModule"):getfield("paid")*100.
                  SET DispInfo TO 61. SET alttag TO 1.
                  SET hudopts[1][2] TO ":".
                  SET hudopts[1][1] TO "Paid".
                  SET hudopts[1][3] TO SetGauge(PaidMeter/100*100,1,widthlim-7).
                }}
              }
              ELSE{}}}}}}
          }
          ELSE{}}}}}}}}}}}}}}}}}}}}}}
           IF DispInfo = 11 AND REMETER = 1 SetCurrentMeter().
            IF MtrCur[5] < MtrCur[3] SET MtrCur[5] TO MtrCur[3].
            IF MtrCur[5] > MtrCur[4] SET MtrCur[5] TO MtrCur[4].
          IF hudop <> 5 SET actnlist TO LIST(1,ItmTrg,BTHD10,BTHD11,EmptyHud).
          }
          IF HUDOP = 5{ //set auto section
            SET HudOptsR[5] TO"AUTO"+MODESHRT[AutoSetMode].
            SET PrvITM TO actnlist[AutoSetAct].
            SET ItmTrg TO MODELONG[AutoSetMode].
            LOCAL topprint TO bigempty.
            SET BTHD10 TO HudRstMdLst[AutoRstMode].
            SET BTHD11 TO "   CLEAR  ".
            IF h5mode <> 1 SET eng[4] TO "  DELAY   ". ELSE SET eng[4] TO "**DELAY** ".
            PRINTLINE("|  ACTION  |   MODE   |").
            PRINT " AFTER TRIGGER" AT (32,17).
            PRINT HudOpts[2][1][itemnumcur]+ ":" + HudOpts[2][2][TagNumCur] + ":" + HudOpts[2][3] AT (2,hudstart-2).
            LOCAL MODEPRINT TO Removespecial(ItmTrg,"   ").
            SET   MODEPRINT TO Removespecial(MODEPRINT,"  ").
            IF MODEPRINT = "ALTAGL" SET MODEPRINT TO "ALT AGL".
            IF AutoSetAct > actnlist:length-1 SET AutoSetAct TO 1.
            LOCAL ActionPrint TO actnlist[AutoSetAct].
            IF ActionPrint:LENGTH > 0 {IF ActionPrint[ActionPrint:LENGTH-1] <> " " SET ActionPrint TO ActionPrint+" ".}
            IF ActionPrint[0] <> " " SET ActionPrint TO " "+ActionPrint.
            LOCAL AftTrgPrint TO "".
            LOCAL ValuePrint TO "".
            LOCAL DelayPrint TO "".
            LOCAL infoprint TO bigempty2.
            PRINT "                              " AT (50,10).
            IF AutoSetMode = 6 {
              SET nxtITM TO "  SEl RSC ".
              LOCAL RscNme TO RscList[RscSelection][0].
              LOCAL RSNM TO RscList[RscNum[RscNme]][1].
              PRINT  RSNM AT (WidthLim-RSNM:length,10).
              IF SHIP:RESOURCES:tostring:contains(RscNum[RscNme]:tostring){ 
                LOCAL RESPCT TO ROUND(SHIP:RESOURCES[RscNum[RscNme]]:AMOUNT/SHIP:RESOURCES[RscNum[RscNme]]:CAPACITY*100,0).
                  LOCAL lm TO 66-RSNM:length-ClrMin. 
                  LOCAL lcl TO MtrColor(RESPCT).
                  LOCAL prf TO RSNM+"("+RESPCT+"%)".
                  SET InfoPrint TO prf+GETCOLOR(SetGauge(RESPCT,0,widthlim-prf:length-9),lcl).
                }
                  SET ValuePrint TO AUTOHUD[0]+" %".
            }
            ELSE{
                SET nxtITM TO EmptyHud.   
                IF AutoSetMode = 2{ SET ValuePrint TO  AUTOHUD[0]+      " M/S".  SET infoprint TO "CURRENT SPEED:"+ROUND(SHIP:VELOCITY:SURFACE:MAG,0)+" M/S".}ELSE{
                IF AutoSetMode = 3{ SET ValuePrint TO  AUTOHUD[0]+      " M".    SET infoprint TO "CURRENT ALTITUDE:"+ROUND(SHIP:ALTITUDE,0)+" M".
                IF BODY:ATM:exists  SET topprint TO " ATMOSPHERE HEIGHT:"+BODY:ATM:HEIGHT+" M".   
                }ELSE{
                IF AutoSetMode = 4{ SET ValuePrint TO  AUTOHUD[0]+      " M AGL".SET infoprint TO "CURRENT RADAR ALTITUDE:"+ROUND(ALT:RADAR-HEIGHT,0)+" M AGL".
                IF BODY:ATM:exists  SET topprint TO " ATMOSPHERE HEIGHT:"+BODY:ATM:HEIGHT+" M". 
                }ELSE{
                IF AutoSetMode = 5{ SET ValuePrint TO  AUTOHUD[0]+      " %".    SET infoprint TO "CURRENT ELECTRIC CHARGE:"+ROUND(SHIP:ELECTRICCHARGE/ecmax*100,0)+" %".}ELSE{
                IF AutoSetMode = 7{ SET ValuePrint TO  AUTOHUD[0]+      " %".    SET infoprint TO "CURRENT THROTTLE:"+ROUND(THROTTLE,0)+" THRTL".}ELSE{
                IF AutoSetMode = 8{ SET ValuePrint TO  AUTOHUD[0]+      " kPa".  SET infoprint TO "CURRENT PRESSURE:"+ROUND(SHIP:SENSORS:PRES,0)+" kPa".}ELSE{
                IF AutoSetMode = 9{ SET ValuePrint TO  AUTOHUD[0]*0.01+ " EXP".  SET infoprint TO "CURRENT SUN EXPOSURE:"+ROUND(SHIP:SENSORS:LIGHT,0)+" EXP".}ELSE{
                IF AutoSetMode = 10{SET ValuePrint TO  AUTOHUD[0]+      " K".    SET infoprint TO "CURRENT TEMPERATURE:"+ROUND(SHIP:SENSORS:TEMP,1)+" K".}ELSE{
                IF AutoSetMode = 11{SET ValuePrint TO  AUTOHUD[0]*0.01+ " M/S2". SET infoprint TO "CURRENT GRAVITY:"+ROUND(SHIP:sensors:grav:MAG,1)+" M/S2".}ELSE{
                IF AutoSetMode = 12{SET ValuePrint TO  AUTOHUD[0]*0.01+ " G".    SET infoprint TO "CURRENT ACCELERATION:"+ROUND(SHIP:sensors:acc:MAG,1)+" G".}ELSE{
                IF AutoSetMode = 13{SET ValuePrint TO  AUTOHUD[0]*0.01      .    SET infoprint TO "CURRENT THRUST TO WEIGHT:"+TWR.}ELSE{
                IF AutoSetMode = 14 {
                  SET nxtITM TO " SEL MODE ".
                  IF StsSelection = 0 SET StsSelection TO 1. 
                  IF StsSelection > STATUSOPTS[0] SET StsSelection TO STATUSOPTS[0]. 

                  PRINT STATUSOPTS[StsSelection] AT (WidthLim-STATUSOPTS[StsSelection]:length,10).
                  SET ValuePrint TO  AUTOHUD[0].    
                  SET infoprint TO "TRIGGER ON STATUS:"+STATUSOPTS[StsSelection]+"             CURRENT STATUS:"+SHIP:STATUS. 
                  IF AutoRstMode = 2 OR AutoRstMode = 3 SET AutoRstMode TO 4.  
                }
                ELSE{
                IF AutoSetMode = 15{
                  SET nxtITM TO "  SEl RSC ".
                  LOCAL RSNM TO prsclist[RscSelection][1].
                  PRINT  RSNM AT (WidthLim-RSNM:length,10).
                  LOCAL lm TO 56-ClrMin-RSNM:length.
                  LOCAL fmtr TO GetFuelLeft(DcpPrtList[TagNumCur],3,0,RscSelection).
                  LOCAL lcl TO MtrColor(fmtr).
                  SET ValuePrint TO  AUTOHUD[0]+      " FUEL". SET infoprint TO "CURRENT "+RSNM+" IN PART:"+ "("+fmtr+"%)"+GETCOLOR(SetGauge(fmtr,0,lm),lcl).
                }
                }}}}}}}}}}}
              }
            }
            IF  AutoRstMode = 1 SET AftTrgPrint TO "DISABLE".
            IF  AutoRstMode = 2 IF AUTOHUD[2] = " UNDER " { SET AftTrgPrint TO "SWITCH TO OVER".}ELSE{SET AftTrgPrint TO "SWITCH TO UNDER".}.
            IF AUTOHUD[2] = " UNDER " { SET ValuePrint TO "UNDER "+ValuePrint.
              IF AutoRstMode = 4 {SET AftTrgPrint TO "WAIT FOR UNDER".}
              IF AutoRstMode = 3 {SET ActionPrint TO "RESET ". SET AftTrgPrint TO "WAIT FOR OVER".}
            }
            IF AUTOHUD[2] = "  OVER " {SET ValuePrint TO "OVER "+ValuePrint.
              IF AutoRstMode = 3 {SET AftTrgPrint TO "WAIT FOR OVER".}
              IF AutoRstMode = 4 {SET ActionPrint TO "RESET ".  SET AftTrgPrint TO "WAIT FOR UNDER".}
            }
            IF setdelay > 0{SET DelayPrint TO "WAIT "+setdelay+" SEC".} ELSE SET DelayPrint TO "".
            LOCAL LCL TO "WHT".
            IF dctnmode = 1 {      
              SET topprint TO "WONT START DETECTION UNTIL AFTER "+REMOVESPECIAL(ItemListHUD[HdItm]," ")+":"+Prttaglist[HdItm][hdtag]+" IS TRIGGERED".
              SET LCL TO "ORN".
            }
            IF dctnmode = 2 {      
              SET topprint TO "WILL TRIGGER WHEN "+REMOVESPECIAL(ItemListHUD[HdItm]," ")+":"+Prttaglist[HdItm][hdtag]+" IS TRIGGERED.".
              SET LCL TO "YLW".
            }
            IF h5mode = 1 {      
              SET topprint TO "CURRENTLY SETTING DELAY TIME. PRESS DELAY TO SET".
              SET LCL TO "YLW".
            }
            PRINTLINE(" "+topprint,LCL,13).
            PRINTLINE(" "+InfoPrint,0,14). 
            SET ln14 TO 2.
            PRINTLINE("",0,16). 
            IF AutoSetMode <> 1{
              IF AutoSetMode = 14 { SET valueprint TO STATUSOPTS[StsSelection]. IF AUTOHUD[0] = 0 SET autohud[0] TO 1.}
                IF AUTOHUD[0] <> 0 {
                  PRINTLINE( DelayPrint+ActionPrint+"when "+MODEPRINT+" is "+ValuePrint+" then "+AftTrgPrint,0,16).
                   PRINT ActionPrint AT (WidthLim-ActionPrint:length,ACP).
                  }
                ELSE{PRINT "VALUE NOT SET" AT (1,16).}
            }ELSE{    PRINT "MODE NOT SET" AT (1,16). PRINT "               " AT (widthlim-15,ACP).}
          }
          ELSE{ //hudop <> 5
           SET HudOptsR[5] TO"AUTO"+MODESHRT[AutoCurMode].
              SETHUD().
              IF DispInfo = 1 AND NEWHUD = 0{
                LOCAL lcl TO "GRN".
                IF GrpDspList[itemnumcur][TagNumCur] = 1 SET lcl TO "RED".
                IF GrpDspList[itemnumcur][TagNumCur] = 2 SET lcl TO "CYN".
                SET HudOpts[1][1] TO getcolor(modulelist[2][itemnumcur][statusdispnum],lcl).
                printline(" "+HudOpts[1][1]+ HudOpts[1][2]+ HudOpts[1][3],0,hudstart-1).
              }
              IF DispInfo > 1{UPDATESTATUSROW().}
                //#region hudset high
                  PRINTLINE(" "+HudOpts[2][1][itemnumcur]+ ":" + HudOpts[2][2][TagNumCur] + ":" + HudOpts[2][3],0,hudstart-2).
                  printbothud().
                //#endregion
            IF HudOptsR[6] = 0 {SET OVUN TO "     ".}ELSE{
              IF HudOptsR[6] < 0 {IF AutoRstMode = 3 SET ovun TO "RESET ". ELSE SET OVUN TO "UNDER ". SET AUTOHUD[2] TO " UNDER ". }
              IF HudOptsR[6] > 0 {IF AutoRstMode = 4 SET ovun TO "RESET ". ELSE SET OVUN TO " OVER ". SET AUTOHUD[2] TO "  OVER ". } 
            }
            IF h5mode = 1  SET ovun TO "DELAY ".
            SET numloc1 TO widthlim-6-HudOptsR[6]:tostring:length.
            LOCAL valprint TO HudOptsR[6].
            IF AutoCurMode = 9 OR AutoCurMode = 11 OR AutoCurMode = 12  OR AutoCurMode = 13 {SET valprint TO valprint*.01. SET NUMLOC1 TO NUMLOC1-2.}
            PRINT "                         " AT (55,acp+2).
            IF AutoCurMode <> 1 PRINT OVUN+ABS(valprint) AT (NUMLOC1,acp+2).
            SET TrgLim TO 1.
            IF bthd10 <> emptyhud SET TrgLim TO 2.
            IF bthd11 <> emptyhud SET TrgLim TO 3.
            SET actnlist[0] TO TrgLim.
            IF AutoTRGList[itemnumcur][TagNumCur] > trglim SET AutoTRGList[itemnumcur][TagNumCur] TO trglim.
            
          }
        }
      }
      ELSE{//if no part
      IF dbglog > 1 log2file("    NO PART"+ItemList[itemnumcur]+":"+prtTagList[itemnumcur][TagNumCur]).
            SET hudopts[1][1] TO "NO PART".
            SET hudopts[1][2] TO "".
            SET hudopts[1][3] TO "".
            SET DispInfo TO 10.
            SET BTHD10 TO EmptyHud. 
            SET BTHD11 TO EmptyHud.
            SET ITMTRG TO EmptyHud.
            PRINTLINE().
            PRINTLINE(HudOpts[2][1][itemnumcur]+ ":" + HudOpts[2][2][TagNumCur] + ":" + HudOpts[2][3],0,hudstart-2). 
            PRINTLINE(HudOpts[1][1]+ HudOpts[1][2]+ HudOpts[1][3],0,hudstart-3).
            SET autoTRGList[0][itemnumcur][tagnumcur] TO 0-abs(AutoCurMode)-1.
      }
            SET ItemNumPrv TO itemnumcur.
            SET tagNumPrv TO TagNumCur.
      //#endregion
      //#region MainPrint
          //#region print if change
          LOCAL acpadd TO 0.
          IF HUDOP <> HUDOPPREV OR forcerefresh > 0{
          PRINT HudOptsR[5] AT (widthlim-8,acp+1).
              PRINT "            " AT (0,3).
              PRINT "            " AT (0,7).
            PRINT "                         " AT (55,acp+3).
             IF HUDOP <> 5 PRINT HudOptsL[1][HUDOP] AT (0,1). PRINT HudOptsR[1][HUDOP] AT (widthlim-11,1).
              PRINT HudOptsL[2][HUDOP] AT (0,2). PRINT HudOptsR[2][HUDOP] AT (widthlim-6,2).
              PRINT HudOptsL[3][HUDOP] AT (0,5). PRINT HudOptsR[3][HUDOP] AT (widthlim-8,5).
              PRINT HudOptsL[4][HUDOP] AT (0,6). PRINT HudOptsR[4][HUDOP] AT (widthlim-8,6).
               IF hudop < 6 {                    PRINT HudOptsR[7][HUDOP] AT (widthlim-11,12).
                                                 PRINT HudOptsR[8][HUDOP] AT (widthlim-4,13).}
              IF hudop=5 {
                LOCAL numloc1 TO widthlim-12-AUTOHUD[0]:tostring:length.
                LOCAL valprint TO AUTOHUD[0].
                LOCAL adjprint TO AutoAdjByLst[AUTOHUD[1]].
                IF AutoSetMode = 9 OR AutoSetMode = 11 OR AutoSetMode = 12 OR AutoSetMode = 13 {SET valprint TO valprint*.01. SET NUMLOC1 TO NUMLOC1-2. SET adjprint TO adjprint*.01.}
                PRINT "NOT SAVED" AT (61,acp+1).
                ///print "          " AT (70,acp+2).
                PRINT "              "+AUTOHUD[2]+ABS(valprint) AT (NUMLOC1-9,acp+2).
                IF AutoSetMode = 14 PRINT "   ON STATUS" AT (widthlim-12,acp+2).
                PRINT adjprint AT (0,6).
                PRINT AUTOHUD[2] AT (0,3).}
              ELSE{//hudop <> 5
              PRINT PrvGRP AT (0,3).
              PRINT nxtGRP AT (0,7).
                IF hudop < 6 AND AutoCurMode <> 1{
                  IF AutoSetAct > actnlist:length-1 SET AutoSetAct TO 1.  
                    PRINT actnlist[AutoSetAct] AT (WidthLim-actnlist[AutoSetAct]:length,ACP).
                    IF AutoCurMode = 14 AND AutoValList[itemnumcur][TagNumCur] > 0 {PRINT STATUSOPTS[StsSelection] AT (WidthLim-STATUSOPTS[StsSelection]:length,acp+3). SET acpadd TO 1.}
                    ELSE{
                      IF AutoCurMode = 6 {
                        LOCAL rscnm TO autoRscList[itemnumcur][TagNumCur].
                        IF rscnm:istype("string") SET rscnm TO RscNum[rscnm].
                        LOCAL arsc TO RscList[rscnm].
                        PRINT  arsc[1]+"("+ROUND(SHIP:RESOURCES[arsc[3]]:AMOUNT/arsc[2]*100,0)+"%)" AT (widthlim-5-arsc[1]:length,acp+3). SET acpadd TO 1.}
                      ELSE{
                        IF AutoCurMode = 15 AND PRscList:LENGTH > 0 AND prsclist[0] <> ""{
                          LOCAL ARSC TO PRscList[autoRscList[itemnumcur][TagNumCur]][0].
                          IF itemnumcur = dcptag {PRINT  arsc AT (widthlim-arsc:length,acp+3). SET acpadd TO 1.}
                        }
                      }
                    }
                }ELSE{PRINT "               " AT (65,acp).PRINT "                    " AT (60,9).PRINT "                    " AT (60,10).PRINT "                    " AT (60,11).}// print "                         " AT (55,acp+2). PRINT "                         " AT (55,acp+3).}
              }
              
          IF HUDOP > 6 {
            PRINT "       Set" AT (widthlim-10,8).
            PRINT "           "+HDXT AT (65,9). 
            IF ROWVAL = 1 AND meterpart = 2 AND MtrCur[4] > 0{ //HDXT = "OPTN" AND
              LOCAL po1 TO meterlist[0][0].
              LOCAL po2 TO MtrCur[5]+" OF "+MtrCur[4].
              LOCAL po3 TO "        ".
              IF meterlist[0][0] = "Option Not Available" {
                IF MtrCur[5] < MtrCur[4]{LOCAL cnt TO 0. 
                  UNTIL meterlist[0][0] <> "Option Not Available" OR (MtrCur[5] = MtrCur[4] AND cnt > MtrCur[4]) {
                    SET MtrCur[5] TO CHANGESEL(MtrCur[4],MtrCur[5],"+",MtrCur[3]). 
                    SET ActiveMeter[itemnumcur] TO MtrCur[5]. 
                    SetCurrentMeter().
                    SET cnt TO cnt+1.
                  }
                }SET forcerefresh TO 2. SET newhud TO 2.
              }ELSE{IF adjmode = "num" SET po3 TO "Adj By: "+mtrcur[2].}
              PRINT "          "+po1 AT (WIDTHLIM-po1:LENGTH-10,10).
              PRINT "          "+po2  AT (WIDTHLIM-po2:LENGTH -10,11).
              PRINT "          "+po3 AT (WIDTHLIM-po3:LENGTH-10,12).
            }
            IF itemnumcur = FlyTag{
               PRINT "   "+AutoAdjByLst[AUTOHUD[1]] AT (widthlim-AutoAdjByLst[AUTOHUD[1]]:TOSTRING:length-3,10).
               PRINT " NXT ROW" AT (widthlim-8,12).
            }
          }ELSE{ IF AutoCurMode <> 1 {
            IF AutoCurMode = 14 PRINT "   ON STATUS" AT (widthlim-12,acp+2).
            IF autoTRGList[0][itemnumcur][TagNumCur] > 0{PRINT "DELAY "+autoTRGList[0][itemnumcur][TagNumCur] AT (widthlim-6-autoTRGList[0][itemnumcur][TagNumCur]:tostring:length,acp+4).}ELSE{PRINT "            " AT (widthlim-12,acp+4).}
          }
            IF hudop = 6{
              PRINT "       RUN" AT (widthlim-10,8).
              PRINT "     EXPERIMENT" AT (widthlim-15,9).
            }
          }
          printbothud().
          }
          SET HUDOPPREV TO HUDOP.
          IF forcerefresh = 1 SET forcerefresh TO 0.
          //#endregion
          //#region alwaysprint
          //#region warnings and notiifications
          SET LinkLock TO 0.
          IF AutoDspList[0][itemnumcur][TagNumCur][0] <> 0 {
            IF AutoDspList[0][itemnumcur][TagNumCur][0]:tostring <> "0" {
              SET ln14 TO 2.
              LOCAL TrgPrint TO "".
              LOCAL splt TO AutoDspList[0][itemnumcur][TagNumCur][0]:split("-").
              IF splt:length = 3 {PRINTLINE("WONT START DETECTION UNTIL AFTER "+REMOVESPECIAL(ItemListHUD[splt[0]:tonumber]," ")+":"+Prttaglist[splt[0]:tonumber][splt[1]:tonumber]+" IS TRIGGERED","ORN",13). SET TrgPrint TO "WAIT 4 OTHER".SET LinkLock TO 1.}
              IF splt:length = 4 {PRINTLINE("WILL TRIGGER WHEN "+REMOVESPECIAL(ItemListHUD[splt[0]:tonumber]," ")+":"+Prttaglist[splt[0]:tonumber][splt[1]:tonumber]+" IS TRIGGERED","YLW",13). SET TrgPrint TO "LOCK 2 OTHER". SET LinkLock TO 2.}
              PRINT  TrgPrint AT (widthlim-TrgPrint:length,acp+4-linklock+acpadd).
            }
          }
          IF loadbkp = 2 {SET line TO 1. SET isdone TO 1.}
          IF SAVEbkp = 2 {SaveAutoSettings(2). printline(" BACKUP FILE SAVED","CYN").  PRINTLINE("",0,13).  PRINTLINE("",0,14).  SET SAVEBKP TO 0. }
          IF SHIP:STATUS <> ShipStatPREV{
            IF STATUSSPACE:CONTAINS(SHIP:STATUS){SET FlState TO "Space". IF BODY:ATM:exists SET FlState TO "SpaceATM".}
            IF STATUSLAND:CONTAINS(SHIP:STATUS) SET FlState TO "Land".
            IF SHIP:STATUS = "FLYING" SET FlState TO "Flight".
            SET ShipStatPREV TO SHIP:STATUS.
          }
          FOR i IN range(1,prtTagList[engtag][0]+1){
            SET fo TO 0.
            IF prtlist[engtag][I][1]:HASSUFFIX("FLAMEOUT"){
              IF prtlist[engtag][I][1]:FLAMEOUT AND PrtListcur:contains(prtlist[engtag][I][1]){SET fo TO 1. BREAK.}
            }
          }

          LOCAL PRLCL TO 14.
          IF RUNAUTO <> 1 SET PRLCL TO 13.
          IF (itemnumcur = LIGHTTAG AND TagNumCur = 1) OR (itemnumcur = AGTAG AND TagNumCur = 2 AND rowval <> 1){
            IF loadbkp = 1  {IF file_exists(autofileBAK) PRINT " CLICK ONE MORE TIME TO LOAD FROM BACKUP " AT (1,PRLCL). ELSE PRINT " NO BACKUP FILE TO LOAD FROM " AT (1,PRLCL).}
            IF SAVEbkp = 1  {PRINT " CLICK ONE MORE TIME TO SAVE TO BACKUP " AT (1,PRLCL).}
          }
          IF LastIn(60) AND pscnt < 3{SET pscnt TO pscnt+1.
             PRINTQ:PUSH(" POWER SAVE MODE ACTIVATED NON-BOOST CPU SPEED REDUCED"+"<sp>"+"WHT"). 
             SET CPUSPD TO SPEEDSET[2].
          }
          //#endregion
          FOR clearPips IN RANGE(0, 4){PRINT " " AT (0,hudstart-clearPips).}
          PRINT ">" AT (0,hudstart-RowSel).
          //#endregion
          //#endregion
            FUNCTION SetCurrentMeter{
              LOCAL PARAMETER Nin IS 4, mtrmin IS 1.
              SET ActionWait TO 1.
            LOCAL Modulesin  TO MeterList[1][itemnumcur]:COPY.
            LOCAL InfoListin TO MeterList[2][itemnumcur]:COPY.
            LOCAL infolistOUT TO infolistIN:COPY.
            SET LCP TO prtlist[itemnumcur][TagNumCur][partnumcur].
            LOCAL po1 TO "Option Not Available".
            IF ModulesIn:LENGTH = 1 SET modulesin TO splitlist(ModulesIn[0]).
            SET Nin TO (Nin*3)-2.
            LOCAL mdmax TO 0.
            LOCAL mdout TO 0.
            LOCAL mtrskp TO 0.
            LOCAL CT TO 1-NEWHUD.
            IF REMETER = 1 SET CT TO 0.
            IF MtrCur[5] < MtrCur[3] SET MtrCur[5] TO MtrCur[3].
            IF MtrCur[5] > MtrCur[4] SET MtrCur[5] TO MtrCur[4].
            IF InfoListin[0]:typename = "Scalar" SET mdmax TO InfoListin:length-1.
            IF dbglog > 2 log2file("    SetCurrentMeter:"+LISTTOSTRING(Modulesin)+" NumIn:"+Nin+" mdmax:"+mdmax+" NEWHUD:"+NEWHUD).  
            LOCAL cnt1 TO 0.
            FOR MD IN Modulesin{
              IF LCP:HASMODULE(MD){SET cnt1 TO cnt1+1.
                IF mdmax > 0 AND cnt1 = 1{
                  FOR mdcur IN range(1,mdmax+1){IF mdcur = mdmax+1 BREAK.
                  SET mdtmp TO splitlist(infolistin[mdcur][0][0],1)[0].
                    IF dbglog > 2 log2file("      SetListCur:("+mdcur+"):"+LISTTOSTRING(mdtmp)).
                      IF mdtmp:contains(MD) {SET infolistOUT TO infolistin[mdcur]. SET  MeterList[2][itemnumcur][0] TO mdcur. SET mdout TO mdcur. BREAK.}
                    }
                  }
                  IF CT = 0 SET FieldList TO SplitDisplayList(Modulesin:COPY, infolistOUT:COPY,1, 2):COPY.
                  SET CT TO CT+1.
                  IF FieldList[3]:length > 1 SET mtrcur[7] TO FieldList[3][MtrCur[5]]:split("/").
                  IF FieldList[4]:length > 1 SET mtrcur[8] TO FieldList[4][MtrCur[5]]:split("/").
                  IF mtrcur[7]:length > 0{
                  LOCAL mtrlast TO mtrcur[7][mtrcur[7]:length-1].
                    IF mtrcur[7]:length = 3{//set min max normal mode
                    SET dbgtrk TO "1a".
                      SET MtrCur[0] TO BoolNum(mtrcur[7][0]).
                      SET MtrCur[1] TO BoolNum(mtrcur[7][1]). 
                      IF newhud > 0 OR mtrcur[7][2] = 0 {SET MtrCur[2] TO BoolNum(mtrcur[7][2]). SET newhud TO 0.}
                    }ELSE{
                      IF mtrlast = -1{//match # to name in next row mode
                        SET MtrCur[0] TO 1.
                        SET MtrCur[1] TO mtrcur[7]:length-1.
                        SET MtrCur[2] TO 1.
                      }
                      IF mtrlast = -2{.//Dont use meter mode. 
                        SET MtrCur[0] TO 0.
                        SET MtrCur[1] TO 0.
                        SET MtrCur[2] TO 0.
                        SET mtrskp TO 1.
                      }
                    }
                    IF mtrlast = -1 { 
                      SET NextGoodField TO 0.
                      IF mtrcur[8]:length > 0 AND mtrcur[6]> -1{
                        IF mtrcur[8][mtrcur[6]] = "NoAct"{
                          IF lastdir = "+"    {FOR I IN RANGE (mtrcur[6],MTRCUR[1]+1)  IF mtrcur[8][i] <> "NoAct" {SET NextGoodField TO i. BREAK.}
                          IF NextGoodField = 0 FOR I IN RANGE (0,MTRCUR[1]+1)    IF mtrcur[8][i] <> "NoAct" {SET NextGoodField TO i. BREAK.}
                        }
                        ELSE{                  FOR I IN RANGE (mtrcur[6],-1)          IF mtrcur[8][i] <> "NoAct" {SET NextGoodField TO i. BREAK.}
                          IF NextGoodField = 0 FOR I IN RANGE (MTRCUR[1],-1)    IF mtrcur[8][i] <> "NoAct" {SET NextGoodField TO i. BREAK.}}
                                          log2file("                  NOACT:"+MTRCUR[5]+" NextGood:"+NextGoodField+" dir ="+lastdir).
                        }
                      }
                    }
                  }
                  SET modulelist[0][itemnumcur][Nin] TO "". 
                  SET modulelist[2][itemnumcur][Nin] TO "".
                  IF getEvAct(LCP,MD,MeterList[0][2][0][MtrCur[5]],3,0,3) OR mtrskp = 1{
                    SET modulelist[0][itemnumcur][Nin] TO MD.
                    SET modulelist[2][itemnumcur][Nin] TO MeterList[0][2][0][MtrCur[5]].
                    IF dbglog > 2 log2file("                Option set to:"+modulelist[2][itemnumcur][Nin]).
                    SET po1 TO MeterList[0][2][0][MtrCur[5]].
                    SET mtrcur[6] TO mtrcur[7]:find(FieldList[2][MtrCur[5]]:TOSTRING).
                    BREAK.
                  }
              }
            }

            IF fieldlist[2]:length > 0 IF METERPART = 0 SET MeterPart TO 1.
            SET MeterList[0][0] TO po1. 
            SET MeterList[0][1] TO Modulesin:COPY. 
              IF MtrCur[5] < MtrCur[3] SET MtrCur[5] TO MtrCur[3].
              IF MtrCur[5] > MtrCur[4] SET MtrCur[5] TO MtrCur[4].
            IF dbglog > 2 log2file("                MTROUT:"+LISTTOSTRING(MeterList[0][1])+"  optout:"+MeterList[0][0]).
            SET actionwait TO 0.            
            RETURN LIST(InfoListin,mdout).
          }
            FUNCTION SetButtonContent{
                LOCAL PARAMETER MDL IS meterlist[0][1], fldon IS "zz", fldoff IS "zz", RtnOn IS " TURN ON  ", RtnOff IS " TURN OFF ".
                LOCAL rtn TO EmptyHud.
                IF NOT MDL:typename:contains("list")  SET MDL TO LIST(MDL).
                    LOCAL ccc TO  getactions("OnOff",mdl,itemnumcur, TagNumCur,1,1,LIST(FldOn), LIST(fldoff)).
                    IF ccc > 0{
                    IF ccc= 1 SET rtn TO RtnOn.
                    IF ccc= 2 SET rtn TO RtnOff. 
                    }
                    RETURN rtn.
              }
            FUNCTION printbothud{
            LOCAL PARAMETER 
            ItemNum IS hsel[2][1],
            TAGNUM IS HSEL[2][2].
              IF colorprint > 0{
                LOCAL itmtrg2 TO itmtrg.
                LOCAL PrvITM2 TO PrvITM.
                PRINT "|          |          |          |          |          |" AT (17,heightlim).
                IF hudop <> 5{
                  IF findcl2:HASKEY(itmtrg){SET itmtrg2 TO  getcolor(itmtrg,FindCl2[itmtrg]).}
                  ELSE{
                    IF GrpDspList[ItemNum][TAGNUM]  = 1 SET itmtrg2 TO "[#00FFFF]"+itmtrg+"{COLOR}".
                    IF GrpDspList[ItemNum][TAGNUM]  = 2 SET itmtrg2 TO "[#ff0000]"+itmtrg+"{COLOR}".
                  }
                }
                ELSE{
                  IF GrpDspList[itemnumcur][TagNumCur] = 1 SET PrvITM2 TO "[#00FFFF]"+PrvITM+"{COLOR}".
                  IF GrpDspList[itemnumcur][TagNumCur] = 2 SET PrvITM2 TO "[#ff0000]"+PrvITM+"{COLOR}".
                }
                PRINT " |"+PrvITM2+"|"+ItmTrg2+"|"+nxtITM+"|"+BTHD10+"|" AT (0,heightlim). 
                PRINT BTHD11+"|" AT (62,heightlim).
              }ELSE{PRINT " |"+PrvITM+"|"+ItmTrg+"|"+nxtITM+"|"+BTHD10+"|"+BTHD11+"|"+BTHD12+"|          |" AT (0,heightlim).}
            }
          SpeedBoost("off").
   }
   FUNCTION UPDATESTATUSROW{//bottom row
    LOCAL br TO 0.
    LOCAL lcl TO 0.
    IF dbglog > 2 log2file("UPDATESTATUSROW:"+newhud+" DispINfo:"+DispInfo).
                LOCAL LF TO 0.
                IF newhud = 1 AND DispInfo > 1 PRINTLINE("",0,14). 
                IF SHIP:RESOURCES:tostring:contains("liquidfuel"){//if ship resources has resource
                  LOCAL FuelLeft TO ROUND(SHIP:RESOURCES[RscNum["liquidfuel"]]:AMOUNT/SHIP:RESOURCES[RscNum["liquidfuel"]]:CAPACITY*100,0).
                  IF FuelLeft < 1                                                         {SET WarnOut TO " WARNING FUEL EMPTY                                                   ". SET lcl TO "RED".}.ELSE
                  IF FuelLeft < 5                                                         {SET WarnOut TO " WARNING FUEL CRITICALLY LOW                                          ". SET lcl TO "ORN".}.ELSE
                  IF FuelLeft < 10                                                        {SET WarnOut TO " WARNING FUEL LOW                                                     ". SET lcl TO "YLW".}
                  IF FuelLeft < 10 {SET LF TO 1.}
                }
                IF LF <> 1 AND itemnumcur <> SCITAG{
                  IF runauto = 2 {
                    IF SHIP:STATUS = "PRELAUNCH" {                                        SET WarnOut TO " PRELAUNCH. AUTO TRIGGERS DISABLED UNTIL AFTER LAUNCH.                 ". SET lcl TO "YLW".}
                      ELSE {IF IsPayload[0] = 1 {SET RunAuto TO 0. SET refreshRateSlow TO 10. SET refreshRateFast TO 10. SET RFSBAak TO refreshRateSlow.}ELSE SET runauto TO 1. 
                                                                                          SET WarnOut TO "".}}
                    ELSE{
                      IF runauto = 3                               {                      SET WarnOut TO " AUTO TRIGGERS DISABLED. CHANGE SETTING IN ACTION GROUP ITEM.          ". SET lcl TO "ORN".}
                    ELSE{
                      IF runauto = 0                               {                      SET WarnOut TO " PAYLOAD PART. AUTO TRIGGERS DISABLED UNTIL 10 SECONDS AFTER DECOUPLE.". SET lcl TO "YLW".}
                    ELSE{
                      IF AutoDspList[itemnumcur][TagNumCur] > 0 AND runauto <> runautobak{SET WarnOut TO "".}
                    }}}
                    IF SHIP:ELECTRICCHARGE < 10                                          {SET WarnOut TO " WARNING LOW ELECTRIC CHARGE. CPU SPEEDBOOST DISABLED                ". SET lcl TO "RED".}
                }
                IF WarnLst <> WarnOut {
                  IF WarnOut <> "" SET ln14 TO 1.
                  printline(WarnOut,lcl,14).
                }
                  SET WarnLst TO WarnOut.
                SET runautobak TO runauto.
              IF hudop = 5 OR itemnumcur = dcptag RETURN.
              IF newhud = 0{
              //set ActionWait to 1.
              IF LastIn(-5) SpeedBoost().
              SET lcl TO 0.
                LOCAL HudItem TO hsel[2][1].
                LOCAL hudtag TO hsel[2][2].
                LOCAL HudPrt TO hsel[2][3].//getgoodpart(HudItem,hudtag,1).
                 LOCAL fl TO "".
                 LOCAL halfmtr TO "". 
                 SET br TO rowsel.
                  IF  HudItem <> sciTag AND printpause = 0 SET botrow TO bigempty2.
                 IF DispInfo > 10 {
                    LOCAL pl TO prtList[HudItem][hudtag].
                    SET pl TO pl:sublist(1, pl:length).
                    LOCAL p TO prtList[HudItem][hudtag][HudPrt].
                      IF HudItem = SMRTTAG{ //update rate override section
                              IF p:HASMODULE("Timer") {
                                LOCAL j TO getEvAct(P,"Timer","remaining time",30).
                                IF NOT j:istype("boolean") AND j <> 0 lastin().
                              }
                      }
                  IF DispInfo = 11 {IF meterpart > 0 {Multimeter().}ELSE{QuickField(p).}}
                  ELSE{
                  IF DispInfo <30 {
                    IF DispInfo = 21 {
                      IF HudItem = anttag {
                        quickfield(p).
                        IF rtech <> 0 {
                          IF rtech:hasKSCconnection(SHIP) = TRUE {printline("CONNECTED TO KSC WITH DELAY OF:"+rtech:kscdelay(SHIP)+"          ","WHT",14). SET ln14 TO 1.}
                          IF getEvAct(P,"ModuleRTAntenna","target",3)  AND meterlist[0][0]:contains("target"){
                            LOCAL ct TO getEvAct(P,"ModuleRTAntenna","target",30).
                            IF ct:contains("VESSEL(") SET ct TO ct:substring(8,ct:length-10).
                            IF ct:contains("BODY(") SET ct TO ct:substring(5,ct:length-7).
                            IF BR=1{
                            LOCAL lcl2 TO "orn".
                            IF trglst[anttrgsel] <> ct {SET HudOpts[1][1] TO getcolor("set target to:"+trglst[anttrgsel],"ORN").}ELSE{SET HudOpts[1][1] TO getcolor("current target:"+trglst[anttrgsel],"WHT").}
                            //printline(" "+HudOpts[1][1]+ HudOpts[1][2]+ HudOpts[1][3],0,hudstart-1).
                            }
                          }
                        }
                      }
                      IF HudItem = DOCKTAG{
                        IF P:HASSUFFIX("STATE") SET HudOpts[1][1] TO P:STATE.
                        IF P:HASSUFFIX("DOCKEDSHIPNAME") SET HudOpts[1][3] TO P:DOCKEDSHIPNAME.
                        SET HudOpts[1][2] TO "               ".
                       SET  botrow TO FormatFields(p,MeterList[0][1],MeterList[0][2],1,0)[0].
                      }
                    }
                    IF DispInfo = 22 {SET HudOpts[1][3] TO getstatus(HudItem,hudtag,2,1).}
                    ELSE{
                    IF DispInfo = 23 {
                      IF HudItem = RBTTag{ // off
                        IF P:HASMODULE("ModuleRoboticController"){
                          LOCAL PLP TO getstatus(HudItem,hudtag,1,1,-1).
                          IF PLP = 0 SET PLP TO "Playing". ELSE SET PLP TO "Paused".
                          SET PLP TO "Status:"+PLP.
                          LOCAL LPM TO getstatus(HudItem,hudtag,2,1,-1).
                          IF LPM = 0 SET LPM TO "None". 
                          IF LPM = 1 SET LPM TO "Repeat".
                          IF LPM = 2 SET LPM TO "Ping Pong".
                          IF LPM = 3 SET LPM TO "None-Restart".
                          SET LPM TO "Loop Mode:"+LPM.
                          LOCAL TDR TO getstatus(HudItem,hudtag,3,1,-1).
                          IF TDR = 0 SET TDR TO "Foward". ELSE SET TDR TO "Reverse".
                          SET TDR TO "Play Direction:"+TDR.
                          SET HudOpts[1][3] TO getstatus(HudItem,hudtag,4,1,-1)+" | "+PLP+" | "+LPM+" | "+TDR.
                          SET plspd TO getEvAct(P,"ModuleRoboticController","Play Speed",30,-1,2).
                          IF plspd:istype("string") SET plspd TO plspd:tonumber.
                          SET botrow TO "Play Speed:"+SetGauge(Removespecial(plspd/mtrcur[1])*100,1,widthlim-16).
                        }
                        ELSE{
                          LOCAL aaa TO getstatus(HudItem,hudtag,MtrCur[5],1,2).
                          IF BR >0{
                              LOCAL MDPRINT TO modulelist[2][RBTTag][MtrCur[5]*3-2]. 
                              IF MDPRINT:tostring:contains("(%)") SET mtrcur[1] TO 100.
                            IF AAA <> "                                    " {
                              LOCAL localguage TO Removespecial(aaa:tonumber/mtrcur[1])*100. 
                              IF br > 0  SET botrow TO MDPRINT+SetGauge(localguage,1,widthlim-4-MDPRINT:length).
                              SET BOTPREV TO "000".
                            }
                            PRINT MDPRINT AT (WidthLim-MDPRINT:length,10).
                          }
                            QuickField(p).
                        }
                      }
                    }}
                  }
                  ELSE{
                  IF DispInfo <40 {
                    IF DispInfo = 33 {
                      LOCAL LCL2 TO "GRN".
                      IF GrpDspList[itemnumcur][TagNumCur] = 1 SET LCL2 TO "RED".
                      IF GrpDspList[itemnumcur][TagNumCur] = 2 SET LCL2 TO "CYN".
                      SET HudOpts[1][1] TO getcolor(modulelist[2][itemnumcur][statusdispnum],LCL2).
                      printline(" "+HudOpts[1][1]+ HudOpts[1][2]+ HudOpts[1][3],0,hudstart-1).
                      SET  botrow TO FormatFields(p,MeterList[0][1],MeterList[0][2],1,0)[0].
                    }ELSE{
                    }
                  }
                  ELSE{
                  IF DispInfo <50 {
                    IF DispInfo = 41 {
                      LOCAL op TO 2.
                      IF HudItem = DrillTag SET op TO 3.
                      IF HudItem = MksDrlTag SET op TO 4.
                      IF BR=1 {
                      LOCAL aaa TO getstatus(HudItem,hudtag,op,1).
                      IF AAA = "                                    " {SET halfmtr TO "". }ELSE{
                      LOCAL bbb TO removeletters(aaa).
                      LOCAL ccc TO bbb:split("/").
                      LOCAL localguage TO (ccc[0]:tonumber / ccc[1]:tonumber)*100.
                      SET FullMtr TO "core temp"+SetGauge(localguage,1,widthlim-11).
                      IF br > 0 SET botrow TO FullMtr.
                      SET HalfMtr TO "core temp"+SetGauge(localguage,1,30).
                      }}
                      IF mks > 0{
                        IF HudItem = PWRTag{
                          IF p:HASMODULE("usi_converter"){
                            LOCAL t1 TO p:getmodule("usi_converter").
                            SET fl TO t1:allfieldnames[0].
                            IF baylst[0] > 0{  
                              SET fl TO baytrg[baysel][0].                   
                              SET t1 TO prtlist[pwrtag][hudtag][1]:getmodulebyindex(baytrg[baysel][2]).
                            }
                            SET hudopts[1][2] TO "".
                            SET hudopts[1][1] TO fl.
                            IF GrpDspList[HudItem][hudtag] = 2 SET hudopts[1][3] TO GetColor(":ACTIVE:","CYN"). 
                            IF GrpDspList[HudItem][hudtag] = 1 SET hudopts[1][3] TO GetColor(":NOT ACTIVE:","RED").
                            IF rowval = 1{
                              IF BR=1 {
                                LOCAL aaa TO getstatus(HudItem,hudtag,3,1).
                                IF AAA <> "                                    " {
                                  LOCAL localguage TO (aaa:tonumber / 1)*100. 
                                  IF halfmtr = "" {SET botrow TO "Governor"+SetGauge(localguage,1,widthlim-11).}ELSE{
                                  IF br > 0 SET botrow TO "Governor"+SetGauge(localguage,1,30)+" "+halfmtr.
                                }}
                                  SET hudopts[1][2] TO "".
                                  SET hudopts[1][1] TO fl.
                                  IF baylst[0] > 0 {
                                  SET hudopts[1][3] TO ":"+BayLst[BaySel][0]+":"+BayLst[BaySel][1]. 
                                  SET HDXT TO "BAY ".
                                  }
                              }
                            }ELSE{ MKSConvCheck(fl,1,HudItem, hudtag).}.
                          }
                        }
                        IF HudItem = MksDrlTag{
                          IF p:HASMODULE("usi_harvester"){
                            LOCAL t1 TO p:getmodule("usi_harvester").
                            SET fl TO t1:allfieldnames[1].
                            SET hudopts[1][2] TO "".
                            SET hudopts[1][1] TO "".
                            IF GrpDspList2[HudItem][hudtag] = 4 SET hudopts[1][3] TO ":ACTIVE:".
                            IF GrpDspList2[HudItem][hudtag] = 3 SET hudopts[1][3] TO ":NOT ACTIVE:".
                            MKSDrillCheck(fl,1,HudItem, hudtag).
                              IF BR=1 {
                                LOCAL aaa TO getstatus(HudItem,hudtag,3,1).
                                IF AAA <> "                                    " {
                                  LOCAL localguage TO (aaa:tonumber / 1)*100.
                                  IF halfmtr = ""{ IF br > 0 SET botrow TO "Governor"+SetGauge(localguage,1,widthlim-11).}
                                  ELSE{
                                  IF ROWVAL = 1 { IF br > 0 SET botrow TO "Governor"+SetGauge(localguage,1,30)+" "+halfmtr.}
                                }}
                                SET hudopts[1][2] TO "".
                                SET hudopts[1][1] TO "".
                              }
                          }
                        }
                      }
                      IF HudItem = ISRUTag{
                        SET hudopts[1][2] TO isruoptlst[ConvRSC]+":". 
                        SET hudopts[1][3] TO ToggleResConv(p,isruoptlst[ConvRSC],ConvRSC,2). 
                        SET hudopts[1][1] TO "Converter:"+ConvRSC+":".
                      }ELSE{
                      IF HudItem = DrillTag{
                        SET hudopts[1][1] TO "Ore Rate".
                        SET hudopts[1][2] TO ":".
                        SET HudOpts[1][3] TO getstatus(HudItem,hudtag,2,1)+"        ".}}
                    }
                  }
                  ELSE{
                  IF DispInfo <70 {
                    IF DispInfo = 51 {
                      SET HudOpts[1][1] TO "".
                      SET HudOpts[1][2] TO "".
                      SET HudOpts[1][3] TO GetFuelLeft(prtList[HudItem][hudtag],2).
                    }
                    ELSE{
                    IF DispInfo = 52 {
                      SET HudOpts[1][1] TO "".
                      SET HudOpts[1][2] TO "".
                      IF SAS = FALSE {SET HudOpts[1][3] TO getcolor(" SAS MDOE:OFF","RED").}ELSE{SET HudOpts[1][3] TO getcolor(" SAS MODE:"+sasMode,"CYN").}
                      IF steeringmanager:enabled = TRUE SET HudOpts[1][3] TO getcolor("HEADING LOCKED","CYN"). 
                        IF hudtag = 1 {
                        IF apsel = 1 AND axsel > 3 SET axsel TO 1.
                        IF apsel = 2 IF axsel < 4 OR axsel > 6 SET axsel TO 4.
                        IF apsel = 3 AND axsel < 7 SET axsel TO 7.
                          LOCAL l1 TO " ".
                          LOCAL l2 TO "               ".
                          LOCAL prfx TO LIST(" ").
                          LOCAL sffx TO LIST(" ").
                          FOR i IN range(0,APaxis[0]) prfx:ADD(l1).
                          FOR i IN range(0,APaxis[0]) sffx:ADD(l2).
                            FOR i IN range (1,APaxis[0]){
                              IF HdngSet[3][i] = 1 {
                                SET prfx[i] TO "*".
                                SET sffx[i] TO "*"+l2:substring(1,l2:length-1).
                              }
                            }
                          IF br = 1{
                            IF NOT prfx[axsel]:contains("*") {
                              SET prfx[axsel] TO ">".
                              SET sffx[axsel] TO "<"+l2:substring(1,l2:length-1).
                              SET ItmTrg TO " MODE OFF ".
                            }
                            ELSE{
                              SET prfx[axsel] TO "<".
                              SET sffx[axsel] TO ">"+l2:substring(1,l2:length-1).
                              SET ItmTrg TO " MODE ON  ".
                            }
                            SET HudOpts[1][1] TO "".
                            SET HudOpts[1][3] TO "        ".
                            IF apsel = 1{
                              IF AXSEL = 1 SET HudOpts[1][2] TO "HEADING:"+ HdngSet[0][1].
                              IF AXSEL = 2 SET HudOpts[1][2] TO "PITCH:"  + HdngSet[0][2].
                              IF AXSEL = 3 SET HudOpts[1][2] TO "ROLL:"   + HdngSet[0][3].
                            }
                            IF apsel = 2{
                              IF AXSEL = 4 SET HudOpts[1][2] TO "SPEED:"  + HdngSet[0][4].
                              IF AXSEL = 5 SET HudOpts[1][2] TO "ALT:"    + HdngSet[0][5].
                              IF AXSEL = 6 SET HudOpts[1][2] TO "V-SPD:"  + HdngSet[0][6].
                            }
                            IF apsel = 3{
                              IF AXSEL = 7 SET HudOpts[1][2] TO "PITCH LIM:"+ HdngSet[0][7].
                              IF AXSEL = 8 SET HudOpts[1][2] TO "SPEED MIN:"+ HdngSet[0][8].
                              IF AXSEL = 9 SET HudOpts[1][2] TO "AOA LIM:"  + HdngSet[0][9].
                            }
                          }
                          IF apsel = 1{
                            SET botrow TO " "+prfx[1]+       "HEADING:"+ HdngSet[0][1]+sffx[1].
                            SET botrow TO     botrow+prfx[2]+"PITCH:"  + HdngSet[0][2]+sffx[2].
                            SET botrow TO     botrow+prfx[3]+"ROLL:"   + HdngSet[0][3]+sffx[3].
                          }
                          IF apsel = 2{
                            SET botrow TO  " "+prfx[4]+       "SPEED:"  + HdngSet[0][4]+sffx[4].
                            SET botrow TO      botrow+prfx[5]+"ALT:"    + HdngSet[0][5]+sffx[5].
                            SET botrow TO      botrow+prfx[6]+"V-SPD:"  + HdngSet[0][6]+sffx[6].
                          }
                           IF apsel = 3{
                            SET botrow TO  " "+prfx[7]+       "PITCH LIM:"+ HdngSet[0][7]+sffx[7].
                            SET botrow TO      botrow+prfx[8]+"SPEED MIN:"+ HdngSet[0][8]+sffx[8].
                            SET botrow TO      botrow+prfx[9]+"AOA LIM:"  + HdngSet[0][9]+sffx[9].
                          }
                          IF GrpDspList3[FLYTAG][1] <> 6{
                          LOCAL PR TO "                   ".
                          IF FlState = "Flight" {SET  ss TO "      SIDESLIP:"+ROUND(bearing_between(SHIP,srfprograde,SHIP:FACING),1). IF colorprint = 1 {SET pr TO "    ".}}
                          ELSE{ SET ss TO "                ". IF colorprint = 1 {SET ss TO "    ". SET pr TO "                ".}}
                          PRINTLINE(pr+"HEADING:"+ ROUND(compass_and_pitch_for()[0],0)+"         PITCH:"  + ROUND(compass_and_pitch_for()[1],0)+"         ROLL:"   + ROUND(roll_for(),0)+ss,0,13).
                          SET ln14 TO 2.
                          }
                        }ELSE{
                          IF prttagList[HudItem][hudtag]:contains("TARGET") {
                            IF BR=1 {SET botrow TO "set target to:"+trglst[anttrgsel]+"           ". SET ItmTrg TO " SET TRGT ".SET lcl TO "CYN".}
                            ELSE{IF hastarget = TRUE {SET botrow TO "Current target:"+TARGET+"           ". SET lcl TO "WHT".}
                            ELSE {SET botrow TO "WARNING: NO TARGET SET. SET A TARGET TO USE THIS MODE".SET lcl TO "RED". SET ItmTrg TO EmptyHud.}}
                          }
                        }
                    }
                    ELSE{
                    IF DispInfo = 61 {
                      IF HudItem = habtag{
                        IF alttag=1{SET ItmTrg TO " DPST RSC ".
                          IF BR=1{
                            IF SHIP:RESOURCES[RscNum["MaterialKits"]]:CAPACITY > 0 {
                            IF rowval = 1 SET botrow TO RscList[RscNum["MaterialKits"]][1]+SetGauge(SHIP:RESOURCES[RscNum["MaterialKits"]]:AMOUNT/SHIP:RESOURCES[RscNum["MaterialKits"]]:CAPACITY*100,1,widthlim-4-RscList[RscNum["MaterialKits"]][1]:length).
                            }ELSE{IF rowval = 1 SET botrow TO "No Material Kits Storage". SET lcl TO "RED".}
                          } 
                        }
                      }
                    }
                    }}
                  }
                  ELSE{}}}}}
                 }
                  IF meterpart > 0 {
                    IF mtrcur[8]:length > 0 AND NextGoodField <> 0 AND mtrcur[6] <>  mtrcur[1] AND mtrcur[6] <>  mtrcur[0]{
                      IF mtrcur[8][mtrcur[6]]:contains("NoAct"){
                        LOCAL amt TO 0.
                        LOCAL lcldir TO "+".
                        IF NextGoodField >  mtrcur[6] SET amt TO NextGoodField- mtrcur[6].
                        IF NextGoodField <  mtrcur[6] {SET amt TO  mtrcur[6]-NextGoodField. SET lcldir TO "-".}
                        adjust_Meter(prtlist[HudItem][hudtag], MAX(abs(amt)-1,1), lcldir, 4, HudItem,  MtrCur[0], MtrCur[1]).  SET forcerefresh TO 2.
                      }ELSE{ SET MeterGoodLast TO  mtrcur[6].}
                    }
                  }
              }ELSE SET forcerefresh TO 1.
                  IF botrow = bigempty2 SET lcl TO 0.      
                  IF botrow:length > WidthLim SET botrow TO botrow:substring(0,WidthLim).
                  IF printpause = 0 AND hsel[2][1] <> agtag{
                    LOCAL STPRINT TO " "+HudOpts[1][1]+ HudOpts[1][2]+ HudOpts[1][3].
                    IF STPREV <> STPRINT {
                      printline(STPRINT,0,hudstart-1).
                      SET STPREV TO STPRINT.
                    }
                    IF BOTPREV <> BOTROW{
                      PRINTLINE(botrow,lcl).
                      SET BOTPREV TO BOTROW.
                    }
                  }ELSE{SET BOTPREV TO "zz". SET STPREV TO "zz".}
                  IF NEWHUD = 2 SET NEWHUD TO 0.
                  //set ActionWait to 0.
                  SpeedBoost("off").
   }

   //#endregion 
    FUNCTION ToggleGroup{//togglegroup(item number, tag number, option, auto).
      LOCAL PARAMETER Inum, tagnum, optnin, auto IS 0.
      SpeedBoost().
      IF auto = 0 LastIn().
      SET forcerefresh TO 2.
      LOCAL FLT TO 0.
      IF INUM > ItemList[0] SET FLT TO 1.
      LOCAL INAME TO "".
      IF FLT = 0 {IF TAGNUM > PRTTAGLIST[INUM][0] SET FLT TO 2. IF FLT < 2 SET INAME TO ":"+itemlist[Inum].}
      IF dbglog > 0{
        LOCAL nd TO " MANUAL".
        IF auto = 1 SET nd TO ":AUTO".
        IF auto = 2 SET nd TO ":FROM QUEUE".
        IF auto = 3 SET nd TO ":TOP HUD BUTTON".
        log2file("TOGGLEGROUP:I:"+inum+" - T:"+tagnum+" - Opt:"+optnin+" - AUTO:"+auto). 
        IF FLT = 0 log2file("           :"+itemlist[Inum]+":"+prttaglist[Inum][tagnum]+nd). ELSE {log2file("           :BAD VALUE!!!!!!"+INAME).RETURN.}
      }
        IF OPTNIN = 0{
          SET AutoDspList[Inum][TagNum] TO abs(AutoDspList[Inum][TagNum]).
          SET AutoDspList[0][Inum][TagNum][0] TO 0.
          LOCAL udo TO 1. 
          IF AutoValList[Inum][tagnum] < 0 SET UDO TO 2.
          PRINTQ:PUSH(REMOVESPECIAL(ItemListHUD[Inum]," ")+":"+Prttaglist[Inum][TagNum]+" DETECTION NOW ACTIVE"+"<sp>"+"GRN"). 
          IF DbgLog > 1 log2file("       UpdateAutoTriggers (UDO("+UDO+"),AutoDspList[Inum][TagNum]("+AutoDspList[Inum][TagNum]+"),Inum("+inum+"),TagNum("+tagnum+"))." ).
          UpdateAutoTriggers(UDO,AutoDspList[Inum][TagNum],Inum,TagNum).
          SpeedBoost("off").
          SET ShipStatPREV2 TO "ForceRenew".
          RETURN.
        }
        IF OPTNIN = -1{
          SET OPTNIN TO AutoTRGList[Inum][tagnum].
        }
        IF OPTNIN = -2{
          IF AutoDspList[0][INUM][TAGNUM]:LENGTH > 1 LINKCHECK(inum, tagnum).
          PRINTQ:PUSH( prttaglist[inum][tagnum]+ " "+" TRIGGERED EXTERNALLY"+"<sp>"+"WHT"). 
          SpeedBoost("off").
          RETURN.
        }
      //#region toggle group settings
      SET checktime TO TIME:SECONDS.
      LOCAL MDL TO modulelist[0][inum].
      LOCAL MDL2 TO modulelist[1][inum].
      LOCAL MDL3 TO modulelist[2][inum].
      LOCAL tagname TO prttaglist[inum][tagnum].
      LOCAL pl TO prtList[inum][tagnum].
      SET pl TO pl:sublist(1, pl:length).
      LOCAL opset TO optnin.
      IF opset > 3 SET opset TO 3. 
      LOCAL optn3 TO opset*3.
      LOCAL optn2 TO optn3-1.
      LOCAL optn1 TO optn3-2.
      LOCAL lightcheck TO 0.
      LOCAL cmd TO TRUE.
      LOCAL evact TO 0.
      IF MDL[0] = "Event" OR MDL2[0] = "Event"  SET evact TO 1.
      IF MDL[0] = "Action" OR MDL2[0] = "Action"  SET evact TO 2.
      //local ea1 to MDL[0].
      //local ea2 to MDL2[0]. 
      LOCAL fld TO mdl3[0]. //field to get
      LOCAL op TO mdl3[4]. //option for off
      GLOBAL Module1 TO MDL[optn1].
      GLOBAL Event1On TO MDL[optn2].
      GLOBAL Event1Off TO MDL[optn3].
      GLOBAL Module2 TO MDL2[optn1].
      GLOBAL Event2On TO MDL2[optn2].
      GLOBAL Event2Off TO MDL2[optn3].
      GLOBAL COMMAND TO "".
      LOCAL PrintOverride TO 0.
      LOCAL opout TO 0.
      LOCAL fl TO "".
      LOCAL t TO "".
      LOCAL printout TO "".
      LOCAL PRFX TO "".
      SET cnt TO 0.
      LOCAL SymCheck TO 0.
      LOCAL lco TO 0.
      LOCAL modov TO "".
      LOCAL MODULE TO "".
      LOCAL AltTrg TO 0.
      LOCAL ccc TO LIST().
      LOCAL OnOffAdd TO LIST(meterlist[4][inum][0],meterlist[4][inum][1]).
      IF optnin > 0 AND meterlist[4][inum]:length > 2 SET OnOffAdd TO LIST(meterlist[4][inum][optnin*2-2],meterlist[4][inum][optnin*2-1]).
      LOCAL Pnum TO  getgoodpart(Inum,tagnum,2).
      SET p TO  prtlist[Inum][tagnum][PNUM].
      IF MeterList[1][inum][0] <> 0 SET modov TO TrimModules2(MeterList[1][inum],inum,tagnum).
      //#endregion
      IF inum <> agtag AND inum <> flyTag AND (inum <>CMDTag AND tagnum < cmdln+1){
        LOCAL PL2 TO PL:COPY.
        FOR pt IN pl2{
          IF NOT pt:tostring:contains("tag="+tagname){
            IF pt <> core:part {IF DbgLog > 0 log2file("         "+PT:TOSTRING+" REMOVED FOR TAG MISMATCH(tag="+tagname+")" ).} ELSE{IF DbgLog > 0 log2file("         PART GONE").}
            SET cnt TO cnt+1.
            PL:REMOVE(PL:FIND(pt)).
          }ELSE{IF DbgLog > 2 log2file("         PART GOOD(tag="+tagname+")" +PT:TOSTRING).}
        }
      IF cnt > pl2:length-1 OR PL:LENGTH = 0{
        IF DbgLog > 0 log2file("          TAG REMOVED FOR TAG MISMATCH(tag="+tagname+")" ).
        SpeedBoost("off").
       RETURN.
      }
      IF DbgLog > 1 log2file("          PartsIn:"+LISTTOSTRING(PL)).
      }
      IF autoTRGList[0][inum][tagnum] < 0 {SpeedBoost("off"). RETURN.}
      IF autoTRGList[0][inum][tagnum] > 0 AND auto = 1 SET evact TO 4.
      //#region TOGGLE CHECK
      IF inum > 0{
        LOCAL localmods TO MeterList[1][inum].
        IF auto = 0 AND inum <> engtag SET localmods TO MeterList[0][1].
        SET PRFX TO MeterList[3][inum]+" ".
        IF debug > 0 AND optnin < 4 PRINTLINE(optnin+"-"+Module1+"-"+Event1On+"-"+Event1Off,0,13).
        IF DbgLog > 1 AND optnin < 4 log2file("           MOD IN: Module1:"+optnin+"-Module1:"+Module1+"-Event1On:"+Event1On+"-Event1Off:"+Event1Off+" FLD:"+fld ).
        IF auto > -2 SET ItemLastRun TO INUM.
        IF inum = lighttag{
          SET PRFX TO "LIGHT ".
          IF P:HASMODULE("modulecommand") AND AUTO <> 0 {SpeedBoost("off").RETURN.}
          IF optnin = 1{
            SET ccc TO checkActions(5,1,localmods, LIST("lights on","light on"),LIST("lights off", "light off")).
            IF  ccc[3] = 0 OR ccc[0] = "moduleanimategeneric" {SET ccc TO checkActions("OnOff",5,localmods, "toggle light","toggle light").}
            IF  ccc[3] > 0 {
              ClearCHK(ccc,-1,0,3,"<>","PO/ TOGGLED  ", "moduleanimategeneric"). 
              IF ccc[0] = "modulecolorchanger" {SET PRINTOUT TO " TOGGLED  ".  SET PrintOverride TO 3.}
            }
            IF AUTO = 2 SET PrintOverride TO -1.
          }
          IF optnin = 2 {
              SET fld TO " ".
            IF tagnum = 1 AND auto = 0 AND ROWVAL = 0{
              SET LOADBKP TO LOADBKP+1.
              SET forcerefresh TO 1.
              SpeedBoost("off").RETURN.
            }
          }
          IF optnin = 3 {
            IF tagnum = 1 AND auto = 0 AND ROWVAL = 0{
              SET SAVEBKP TO SAVEBKP+1.
              SET forcerefresh TO 1.
              SpeedBoost("off").RETURN.
            }
          }
        }
          ELSE{
          IF mks =1 {
          IF inum = PWRTag {
            IF optnin = 1 {
              IF p:HASMODULE("usi_converter"){
                SET PrintOverride TO 1.
                SET forcerefresh TO 1.
                SET t TO p:getmodule("usi_converter").
                SET fl TO t:allfieldnames[0]. 
                IF baytrg[0] > 1{ 
                  SET t TO p:getmodulebyindex(baytrg[baysel][2]).
                  SET fl TO baytrg[baysel][0].
                  SET evact TO 3.
                }
                SET module TO module1.
                SET ccc TO getactions("Actions"+Pnum,localmods,inum, tagnum,optnin,1,LIST("start", "activate"),LIST("stop", "deactivate")).          
                IF ccc[3] = 3 OR ccc[3] = 0{
                  IF GrpDspList[Inum][tagnum] = 1{ 
                  PRINTQ:PUSH(" "+prtTagList[INUM][tagnum]+" TURNED ON"+"<sp>"+"CYN").  
                    SET ccc TO getactions("Actions"+Pnum,localmods,inum, tagnum,optnin,2,LIST("toggle"),LIST("zz")).
                    SET GrpDspList[Inum][tagnum] TO 2.
                    }
                  ELSE{
                  IF GrpDspList[Inum][tagnum] = 2{
                    PRINTQ:PUSH(" "+prtTagList[INUM][tagnum]+" TURNED OFF"+"<sp>"+"RED"). 
                  SET ccc TO getactions("Actions"+Pnum,localmods,inum, tagnum,optnin,2,LIST("zz"),LIST("toggle")).
                  }}
                }ELSE{
                    IF ccc[3] = 1  PRINTQ:PUSH(" "+prtTagList[INUM][tagnum]+" TURNED ON"+"<sp>"+"CYN").                   
                    IF ccc[3] = 2  PRINTQ:PUSH(" "+prtTagList[INUM][tagnum]+" TURNED OFF"+"<sp>"+"RED"). 
                }
                SET PrintOverride TO -1.
               IF  ccc[3] > 0 SetTrgVars(CCC,-1).
              }
            }ELSE{
              IF optnin = 3 AND BTHD11:contains("TETHR"){
                SET ccc TO getactions("Actions"+Pnum,LIST("USI_InertialDampener"),inum, tagnum, optnin, 1,LIST("ground tether: on"),LIST("ground tether: off")).
                ClearCHK(ccc,0,0,0,"="). 
              }
            }
          }
          ELSE{
            IF inum = MksDrlTag {
              IF OPTNIN = 1{
                SET GrpDspList2[Inum][tagnum] TO 3.
              }
              IF optnin = 2 {
                  IF getactions("OnOff"+Pnum,AnimModAlt,inum, tagnum,1,6,LIST("retract")) <> 0 {
                  IF prtlist[MksDrlTag][tagnum][1]:HASMODULE("usi_harvester"){
                    SET forcerefresh TO 1.
                    SET t TO prtlist[MksDrlTag][tagnum][1]:getmodule("usi_harvester").
                    SET fl TO t:allfieldnames[1].
                    //set fl2 to getEvAct(P,"usi_harvester",t:getfield(fl+" rate"),30).
                        SET ccc TO getactions("Actions"+Pnum,LIST("usi_harvester"),inum, tagnum, optnin, 0,LIST("start","activate"),LIST("stop","deactivate")).
                        IF ccc[3] <> 3 {
                        IF ccc[3] = 1  PRINTQ:PUSH(" "+prtTagList[INUM][tagnum]+" TURNED ON"+"<sp>"+"CYN").                   
                        IF ccc[3] = 2  PRINTQ:PUSH(" "+prtTagList[INUM][tagnum]+" TURNED OFF"+"<sp>"+"RED"). 
                        }ELSE{
                      IF GrpDspList2[Inum][tagnum] = 3{
                        SET ccc TO getactions("Actions"+Pnum,localmods,inum, tagnum,optnin,2,LIST("activate","toggle"),LIST("ZZ")).
                        SET GrpDspList2[Inum][tagnum] TO 4.
                        }
                      ELSE{
                      IF GrpDspList2[Inum][tagnum] = 4{
                        SET ccc TO getactions("Actions"+Pnum,localmods,inum, tagnum,optnin,2,LIST("zz"),LIST("deactivate","toggle")).
                        SET GrpDspList2[Inum][tagnum] TO 3.
                      }}
                    }
                  ClearCHK(ccc,-1).
                  }
                }ELSE{                  
                   PRINTQ:PUSH(" DRILL NOT DEPLOYED! DEPLOYING AND STARTING"+"<sp>"+"ORN").
                      ActionQNew:ADD(LIST(TIME:SECONDS,inum,tagnum,1)). 
                      ActionQNew:ADD(LIST(TIME:SECONDS+5,inum,tagnum,2)). 
                }
                SET PrintOverride TO -1.
              }
            }
            ELSE{IF inum = habtag {SET forcerefresh TO 1.}}
          }
        }// stop putting else line here.
          IF inum = ENGtag { 
            IF optnin = 1 {
              SET localmods TO engmods.
              LOCAL lon TO LIST(" on", "activate").
              LOCAL loff TO LIST(" off","shutdown").
              IF p:HASSUFFIX("modes") IF P:modes:length > 1 {IF NOT P:primarymode SET AltTrg TO 1.}
              IF p:HASSUFFIX("ignition"){IF p:ignition = FALSE SET loff TO LIST(""). ELSE SET lon TO LIST("").}  
              IF p:HASMODULE("FSengineBladed"){IF getEvAct(P,"FSengineBladed","Status",30):contains("inactive") SET loff TO LIST(""). ELSE SET lon TO LIST("").}
              SET ccc TO getactions("Actions"+Pnum,localmods,inum, tagnum,optnin,3,lon,loff).
             ClearCHK(ccc,-1).
            }
            IF optnin = 2 {
                IF p:HASMODULE("FSengineBladed"){
                    IF ROWVAL = 1{ SET PrintOverride TO -1.
                    PRINTQ:PUSH(CheckTrue(40,pl,"FSengineBladed","thr keys"," "+prtTagList[INUM][tagnum]+" THROTTLE KEY RESPONSE SET TO ON   "+"<sp>"+"CYN"," "+prtTagList[INUM][tagnum]+" THROTTLE KEY RESPONSE SET TO Off  "+"<sp>"+"RED")).                     
                    }ELSE{
                        SET ccc TO getactions("Actions"+Pnum,LIST("FSengineBladed"),inum, tagnum,optnin,3,"hover").
                        ClearCHK(ccc,-1).
                }
                }
                IF p:HASMODULE("FSswitchEngineThrustTransform"){
                        SET ccc TO getactions("Actions"+Pnum,LIST("FSswitchEngineThrustTransform"),inum, tagnum,OPTNIN,3,LIST("reverse"),LIST("normal")).
                        IF  ccc[3] > 0 SetTrgVars(CCC,-1).
                        IF ccc[3] = 2  PRINTQ:PUSH(" "+prtTagList[INUM][tagnum]+" THRUST SET TO NORMAL  "+"<sp>"+"CYN").
                        IF ccc[3] = 1  PRINTQ:PUSH(" "+prtTagList[INUM][tagnum]+" THRUST SET TO REVERSE "+"<sp>"+"RED"). 
                        SET PrintOverride TO -1.
                }
            }
            IF optnin = 3 {
                    IF p:HASMODULE("FSengineBladed"){
                      SET PrintOverride TO -1.
                        IF rowval = 1 {PRINTQ:PUSH(CheckTrue(40,pl,"FSengineBladed","thr state"," "+prtTagList[INUM][tagnum]+" THROTTLE STATE RESPONSE SET TO ON   "+"<sp>"+"CYN"," "+prtTagList[INUM][tagnum]+" THROTTLE STATE RESPONSE SET TO Off  "+"<sp>"+"RED")).
                        }ELSE{PRINTQ:PUSH(CheckTrue(40,pl,"FSengineBladed","steering"," "+prtTagList[INUM][tagnum]+" ROTOR STEERING SET TO ON   "+"<sp>"+"CYN"," "+prtTagList[INUM][tagnum]+" ROTOR STEERING SET TO Off  "+"<sp>"+"RED")).}
                    }
                    ELSE{SET fld TO "GIMBAL". SET op TO "False".}
            }
          }//}
          ELSE{
          IF inum = dcptag { 
            IF optnin = 1{
              LOCAL ct TO 0.
              FOR pt IN pl {
                FOR md IN DcpModAlt{
                  IF pt:HASMODULE(md){SET ct TO ct+1.
                    IF ct = 1 SET module1 TO md. 
                    IF ct = 2 SET module2 TO md.
                  }
                }
              }
               IF p:HASMODULE(Module1){
                IF p:getmodule(Module1):hasEVENT("jettison heat shield"){SET t TO p:getmodulebyindex(0). SET evact TO 3.}
              }
          }
          IF P:HASMODULE("moduledecouple") OR P:HASMODULE("ModuleAnchoredDecoupler") IF P:HASSUFFIX("ISDECOUPLED")  IF P:ISDECOUPLED = TRUE { PRINTQ:PUSH("ALREADY DECOUPLED      "+"<sp>"+"RED"). SpeedBoost("off").RETURN.}.
          }
          ELSE{
          IF inum = WMGRtag {
                IF optnin = 1 {
                  IF P:HASMODULE("MissileFire"){
                    getEvAct(P,"MissileFire","fire missile",20). SET PrintOverride TO -1.  PRINTLINE(tagname+ " FIRING" ,"RED"). SpeedBoost("off").RETURN.
                  }
                }
                IF optnin = 2 AND Radartag > 0 AND BTHD10 = "NEXT TRGT "{
                  IF getEvAct(P,"ModuleRadar","target next",20) PRINTQ:PUSH("RADAR TARGET CYCLED    "+"<sp>"+2). 
                  SpeedBoost("off").RETURN.
                }
                IF optnin = 3 {
                  IF CMtag > 0 AND BTHD11 <> "NEXT TEAM " FOR cm IN cmlist {IF getEvAct(cm,"CMDropper","fire countermeasure",20) PRINTLINE("COUNTERMEASURES FIRED " ,"RED").} 
                  IF BTHD11 = "NEXT TEAM " AND auto = 0  IF getEvAct(P,"MissileFire","next team",20)PRINTQ:PUSH("Team changed to "+P:getmodule("MissileFire"):getfield("team")+"<sp>"+2). SET PrintOverride TO -1.
                  RETURN.
                }
              }
          ELSE{
          IF inum = BDPtag {
              IF P:HASMODULE("BDModulePilotAI"){ 
                SET fl TO P:getmodule("BDModulePilotAI").
                IF getEvAct(p,"BDModulePilotAI","deactivate pilot",1,3) = TRUE SET event1on TO "".
                IF optnin = 2 AND P:getmodule("BDModulePilotAI"):hasFIELD("standby mode"){ 
                  SET forcerefresh TO 1.
                  IF fl:GETFIELD("standby mode") = FALSE {
                    fl:SETFIELD("standby mode", TRUE). PRINTQ:PUSH("STANDBY MODE ON "+"<sp>"+2).  
                    SET GrpDspList2[Inum][tagnum] TO 4. SpeedBoost("off").RETURN.}
                  ELSE{
                    fl:SETFIELD("standby mode", FALSE). PRINTQ:PUSH("STANDBY MODE OFF "+"<sp>"+1).  
                    SET GrpDspList2[Inum][tagnum] TO 3. SpeedBoost("off").RETURN.}
                }
                IF optnin = 3 AND fl:hasFIELD("unclamp tuning "){ SET forcerefresh TO 1.
                  IF fl:GETFIELD("unclamp tuning ") = FALSE {
                    fl:SETFIELD("unclamp tuning ", TRUE).  PRINTQ:PUSH( "TUNING UNCLAMPED "+"<sp>"+1). SET ALTVAL TO 1. SET GrpDspList3[Inum][tagnum] TO 6. SET remeter TO 1. SpeedBoost("off"). RETURN.}
                  ELSE{
                    fl:SETFIELD("unclamp tuning ", FALSE). PRINTQ:PUSH( "TUNING CLAMPED "+"<sp>"+2).   SET ALTVAL TO 0. SET GrpDspList3[Inum][tagnum] TO 5. SET remeter TO 1. SpeedBoost("off"). RETURN.}
                }
              }
            }
          ELSE{
          IF inum = SMRTtag {
              IF currentpart:HASMODULE("Timer"){
                IF optnin = 1 {
                SET ccc TO  getactions("Actions"+Pnum,LIST("Timer"),inum, tagnum,2,1,LIST("Start Countdown"),LIST("zzz")).
                ClearCHK(ccc,0,0,0,">","po/ TOGGLED").
                }
                IF optnin = 3 {
                SET fld TO " ".
                }
              }
            }
          ELSE{
          IF inum = AGTag {
            IF evact <> 4{
              IF optnin = 1 {
                SET opout TO 1.
                IF tagnum = 1 {  toggle ag1 . IF ag1  = FALSE SET opout TO 2.}ELSE{
                IF tagnum = 2 {  toggle ag2 . IF ag2  = FALSE SET opout TO 2.}ELSE{
                IF tagnum = 3 {  toggle ag3 . IF ag3  = FALSE SET opout TO 2.}ELSE{
                IF tagnum = 4 {  toggle ag4 . IF ag4  = FALSE SET opout TO 2.}ELSE{
                IF tagnum = 5 {  toggle ag5 . IF ag5  = FALSE SET opout TO 2.}ELSE{
                IF tagnum = 6 {  toggle ag6 . IF ag6  = FALSE SET opout TO 2.}ELSE{
                IF tagnum = 7 {  toggle ag7 . IF ag7  = FALSE SET opout TO 2.}ELSE{
                IF tagnum = 8 {  toggle ag8 . IF ag8  = FALSE SET opout TO 2.}ELSE{
                IF tagnum = 9 {  toggle ag9 . IF ag9  = FALSE SET opout TO 2.}ELSE{
                IF tagnum = 10 { toggle ag10. IF ag10 = FALSE SET opout TO 2.}ELSE{
                IF tagnum = 11 {
                  IF THROTTLE < 1 SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 1. ELSE SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
                  IF THROTTLE < 0 SET opout TO 2.}ELSE{
                IF tagnum = 12 { 
                  IF RCS = FALSE RCS ON. ELSE RCS OFF.
                  IF RCS = FALSE SET opout TO 2.}ELSE{
                IF tagnum = 13 {toggle ABORT.  IF ABORT = FALSE SET opout TO 2.}ELSE{
                IF tagnum = 14 {toggle GEAR.   IF GEAR  = FALSE SET opout TO 2.}ELSE{
                IF tagnum = 15 {toggle LIGHTS. IF LIGHTS= FALSE SET opout TO 2.}ELSE{
                IF tagnum = 16 {toggle BRAKES. IF BRAKES= FALSE SET opout TO 2.}ELSE{
                }}}}}}}}}}}}}}}}
                SET GrpDspList[Inum][tagnum] TO opout.
                PRINTQ:PUSH( tagname+ " "+" TRIGGERED "+"<sp>"+opout). 
                IF AutoDspList[0][INUM][TAGNUM]:LENGTH > 1 LINKCHECK(inum, tagnum).
                IF PRINTQ:LENGTH > 0 AND printpause = 0 PrintTheQ().
                SET AgSPrev TO AgState:COPY.
                SpeedBoost("off").RETURN.
              }
              IF OPTNIN = 2 AND auto = 0{
                  IF rowsel = 1{
                    IF tagnum = 2 {
                      SET refreshRateSlow TO CHANGESEL(10,refreshRateSlow ,"+").
                      PRINTQ:PUSH(" HUD REFRESH RATE SET TO "+refreshRateSlow+"<sp>"+"WHT"). SET PrintOverride TO -1.
                      SET RFSBAak TO refreshRateSlow.
                    }
                    IF tagnum = 4 {
                      SET SPEEDSET[2] TO CHANGESEL(speeds[1]:length-1,SPEEDSET[2],"+"). 
                      IF SPEEDSET[2] > SPEEDSET[3] SET SPEEDSET[3] TO SPEEDSET[2].
                      SET CPUSPD TO SPEEDSET[2].
                      PRINTQ:PUSH(" Power Save Processing Speed Set to "+Removespecial(speeds[0][SPEEDSET[2]]," ")+"<sp>"+"PRP").
                      SET PrintOverride TO -1.
                    }                    
                    IF tagnum = 10 {
                      SET dbglog TO CHANGESEL(4,dbglog ,"+").
                      IF dbglog > 3 SET dbglog TO 0.
                      LOCAL ZZ TO " ON". IF dbglog = 0 SET ZZ TO " OFF". IF dbglog = 2 SET ZZ TO " VERBOSE".  IF dbglog = 3 SET ZZ TO " OVERKLL".
                      PRINTQ:PUSH(" LOGGING SET TO "+ZZ+"<sp>"+"WHT"). SET PrintOverride TO -1.
                    }
                    IF PRINTQ:LENGTH > 0 AND printpause = 0 PrintTheQ().
                    SpeedBoost("off"). RETURN.
                  }ELSE{
                  IF tagnum = 1 {
                    IF RunAuto = 1 OR RUNAUTO = 2 {SET RunAuto TO 3. PRINTQ:PUSH(" AUTO TRIGGERS DISABLED "+"<sp>"+"RED"). SET PrintOverride TO -1.}
                      ELSE IF RUNAUTO = 3 {
                        IF SHIP:STATUS = "PRELAUNCH" {SET RUNAUTO TO 2.  PRINTQ:PUSH(" AUTO TRIGGERS SET TO PRELAUNCH "+"<sp>"+"YLW"). SET PrintOverride TO -1.}
                        ELSE IF IsPayload[0] = 1 AND IsPayload[1] <> core:part {SET RunAuto TO 0. PRINTQ:PUSH(" AUTO TRIGGERS SET TO PAYLOAD PART "+"<sp>"+"YLW"). SET PrintOverride TO -1.}
                        ELSE {SET RunAuto TO 1. PRINTQ:PUSH(" AUTO TRIGGERS ENABLED "+"<sp>"+"CYN"). SET PrintOverride TO -1.}
                      }
                    }
                  IF tagnum = 2{
                     SET LOADBKP TO LOADBKP+1.
                      SET forcerefresh TO 1.
                      SpeedBoost("off").RETURN.
                    }
                    IF tagnum = 3 {
                      SET HLon TO CHANGESEL(1,HLon ,"+",0).
                      IF hlon = 1 PRINTQ:PUSH(" PART HIGHLIGHTING ENABLED"+"<sp>"+"CYN"). ELSE PRINTQ:PUSH(" PART HIGHLIGHTING DISABLED"+"<sp>"+"ORN"). 
                      SET PrintOverride TO -1.
                    }
                    IF tagnum = 4 {
                      SET SPEEDSET[0] TO CHANGESEL(speeds[1]:length-1,SPEEDSET[0],"+"). 
                      IF SPEEDSET[0] > SPEEDSET[1] SET SPEEDSET[1] TO SPEEDSET[0].
                      SET CPUSPD TO SPEEDSET[0].
                      PRINTQ:PUSH(" Processing Speed Set to "+Removespecial(speeds[0][SPEEDSET[0]]," ")+"<sp>"+"WHT").
                    }
                    IF PRINTQ:LENGTH > 0 AND printpause = 0 PrintTheQ().
                    SpeedBoost("off"). RETURN.
                  }
              }
              IF optnin = 3 AND auto = 0{
                IF TAGNUM = 1{
                  PRINTQ:PUSH(" LISTING AUTO SETTINGS"+"<sp>"+"CYN"). SET PrintOverride TO -1.
                  listautosettings().
                }
                IF rowsel = 1{
                  IF tagnum = 2{
                      SET refreshRateFast TO CHANGESEL(10,refreshRateFast ,"+").
                      PRINTQ:PUSH(" INFO REFRESH RATE SET TO "+refreshRateFast+"<sp>"+"WHT"). SET PrintOverride TO -1.
                    }
                  IF tagNumcur = 4 {
                    SET SPEEDSET[3] TO CHANGESEL(speeds[1]:length-1,SPEEDSET[3],"+",SPEEDSET[2]).
                    PRINTQ:PUSH(" Power Save BOOST Processing Speed Set to "+Removespecial(speeds[0][SPEEDSET[3]]," ")+"<sp>"+"prp").
                  }
                }ELSE{
                    IF tagnum = 2 {
                     SET SAVEBKP TO SAVEBKP+1.
                      SET forcerefresh TO 1.
                      SpeedBoost("off").RETURN.
                    }
                  IF tagNumcur = 4 {
                    SET SPEEDSET[1] TO CHANGESEL(speeds[1]:length-1,SPEEDSET[1],"+",SPEEDSET[0]).
                    PRINTQ:PUSH(" BOOST Processing Speed Set to "+Removespecial(speeds[0][SPEEDSET[1]]," ")+"<sp>"+"WHT").
                  }
                IF tagnum = 10 {
                  SET DEBUG TO CHANGESEL(2,DEBUG ,"+").
                  IF debug> 1 SET DEBUG TO 0.
                  LOCAL ZZ TO " ON". IF DEBUG = 0 SET ZZ TO " OFF".
                  PRINTQ:PUSH(" DEBUG SET TO "+ZZ+"<sp>"+"WHT"). SET PrintOverride TO -1.
                }
              }
            }
            }
          }
          ELSE{
          IF inum = FlyTag {
            IF evact <> 4{
              SET opout TO 2.
              LOCAL strst TO StrLock.
              LOCAL trgsas TO 1.
              IF tagnum > 1{
                IF optnin = 1 AND MJB <> 2 {
                  IF SHIP:VELOCITY:SURFACE:MAG<1 AND tagnum < 4 {SET trgsas TO 0.}
                  UNLOCK STEERING.
                  IF sasmode =  Removespecial(prtTagList[Flytag][tagnum]," ") AND SAS = TRUE SET opout TO 1.
                  IF opout = 1 {
                  SAS OFF. 
                  PRINTQ:PUSH(" SAS SET TO:OFF"+"<sp>"+"GRN"). SET PrintOverride TO -1.
                    SET StrLock TO 0.
                  }
                  ELSE{
                    LOCAL SSKP TO 0.
                    IF trgsas = 1{
                      IF prttagList[INUM][TAGNUM]:contains("TARGET") {
                        IF hastarget <> TRUE {PRINTQ:PUSH("NO TARGET SET. SET A TARGET TO USE THIS MODE"+"<sp>"+"RED"). SET SSKP TO 1.}
                      }
                      IF SSKP = 0{
                        SAS ON. WAIT 0.1. 
                        SET sasmode TO Removespecial(prtTagList[Flytag][tagnum]," ").
                        PRINTQ:PUSH(" SAS SET TO:"+sasMode+"<sp>"+"CYN").  SET PrintOverride TO -1.
                        SET StrLock TO tagnum.
                      }
                    }
                  }
                }ELSE{IF MJB > 1 {PRINTQ:PUSH(" CAN'T ENABLE SAS MODE, MECHJEB ACTIVE<sp>"+"RED").  SET PrintOverride TO -1.}}
              }
              ELSE{
                IF rowval = 1 {
                  IF optnin = 1 {
                    SET HdngSet[3][axsel] TO CHANGESEL(1,HdngSet[3][axsel] ,"+",0).
                  }
                  IF optnin = 2 {
                    IF zop = 1{
                      IF axsel = 1 SET HdngSet[0][1] TO ROUND(compass_and_pitch_for()[0],0).
                      IF axsel = 2 SET HdngSet[0][2] TO ROUND(compass_and_pitch_for()[1],0). 
                      IF axsel = 3 SET HdngSet[0][3] TO ROUND(roll_for(),0).
                      IF axsel = 4 SET HdngSet[0][4] TO ROUND(SHIP:VELOCITY:SURFACE:MAG,0).
                      IF axsel = 5 SET HdngSet[0][5] TO ROUND(SHIP:ALTITUDE,0).
                      IF axsel = 6 SET HdngSet[0][6] TO ROUND(SHIP:VERTICALSPEED,0).
                    SET zop TO 2.
                    RETURN.
                    }
                    ELSE{
                      IF axsel = 1 SET HdngSet[0][1] TO 0.
                      IF axsel = 2 SET HdngSet[0][2] TO 0.
                      IF axsel = 3 SET HdngSet[0][3] TO 0.
                      IF axsel = 4 SET HdngSet[0][4] TO 0.
                      IF axsel = 5 SET HdngSet[0][5] TO 0.
                      IF axsel = 6 SET HdngSet[0][6] TO 0.
                      IF axsel = 7 SET HdngSet[0][7] TO 0.
                      IF axsel = 8 SET HdngSet[0][8] TO 0.
                      IF axsel = 9 SET HdngSet[0][9] TO 0.
                      SET zop TO 1.
                      RETURN.
                    }
                  }
                }ELSE{
                  IF optnin = 1 AND MJB <> 2{
                    IF GrpDspList[Inum][tagnum] = 1 {
                      SET opout TO 2.
                      SAS OFF.
                      //LOCK STEERING TO HEADING(HdngSet[0][1]+flyadj[1],HdngSet[0][2]+flyadj[2]+plimadj,HdngSet[0][3]+flyadj[3]).
                      LOCK STEERING TO HEADING(HdngSet[0][1]+flyadj[1],HdngSet[0][2]+flyadj[2],HdngSet[0][3]+flyadj[3]).
                      SET StrLock TO 1.
                      PRINTQ:PUSH(" HEADING LOCKED"+"<sp>"+"CYN"). SET PrintOverride TO -1.
                    }
                    ELSE{
                      SET opout TO 1.
                      UNLOCK STEERING. SET strlock TO 0.
                      PRINTQ:PUSH(" STEERING UNLOCKED"+"<sp>"+"ORN"). SET PrintOverride TO -1.
                    } 
                  }ELSE{IF MJB > 1 {PRINTQ:PUSH(" CAN'T ENABLE SAS MODE, MECHJEB ACTIVE<sp>"+"RED").  SET PrintOverride TO -1.}}
                  IF optnin = 2 {
                    SET HdngSet[0][1] TO ROUND(compass_and_pitch_for()[0],0).
                    SET HdngSet[0][2] TO ROUND(compass_and_pitch_for()[1],0). 
                    SET HdngSet[0][3] TO ROUND(roll_for(),0).
                    SET HdngSet[0][4] TO ROUND(SHIP:VELOCITY:SURFACE:MAG,0).
                    SET HdngSet[0][5] TO ROUND(SHIP:ALTITUDE,0).
                    //set HdngSet[0][6] to ROUND(ship:VERTICALSPEED,0).
                    PRINTQ:PUSH(" ALL SET TO CURRENT"+"<sp>"+"WHT").
                    RETURN.
                  }
                  IF optnin = 3{
                    IF GrpDspList3[Inum][tagnum] = 5 {SET GrpDspList3[Inum][tagnum] TO 6. PRINTQ:PUSH(" HEADING WILL ALWAYS SHOW"+"<sp>"+"WHT"). SET PrintOverride TO -1.}
                    ELSE{                             SET GrpDspList3[Inum][tagnum] TO 5. PRINTQ:PUSH(" HEADING WILL SHOW ON THIS PAGE"+"<sp>"+"GRN"). SET PrintOverride TO -1.}
                    SET forcerefresh TO 1.
                    SpeedBoost("off").RETURN.
                  }
                }
              }
              SET GrpDspList[Inum][tagnum] TO opout. 
              IF strst > 0 {IF steeringmanager:enabled = FALSE SET GrpDspList[Inum][strst] TO 1. ELSE SET GrpDspList[Inum][strst] TO 2.}
              SpeedBoost("off").RETURN.
            }
          }
          ELSE{
            IF inum = CMDTag{
              IF optnin = 1 {
                IF tagnum > cmdln{
                  PRINTQ:PUSH(" MECHJEB: "+prtTagList[CMDTag][tagnum]+" ACTIVATED <sp>"+"CYN").  SET PrintOverride TO -1.
                  SET Event1On TO mjeb[1][mjeb[0]:find(prtTagList[CMDTag][tagnum])]. SET module1 TO "mechjebcore".
                  SET Event1Off TO "".
                  ClearOOA().
                  SET MJB TO 2.
                  IF TAGNUM > 8 SET MJB TO 3.
                  IF TAGNUM > 10 SET MJB TO 4.
                  IF TAGNUM > 18 SET MJB TO 5.
                  IF Event1On = "deactivate smartacs" SET MJB TO 1.
                }
              }
              IF optnin = 2 {
                IF tagnum > cmdln{
                  PRINTQ:PUSH(" MECHJEB SAS: TURNED OFF <sp>"+"ORN").  SET PrintOverride TO -1.
                  clearev().
                  IF TAGNUM > 10 SET Event1On TO "translatron off". ELSE SET Event1On TO "deactivate smartacs".
                  SET module1 TO "mechjebcore".
                  SET MJB TO 1.
                  }
              }
              IF optnin = 3{
                IF P:HASMODULE("ModuleScienceContainer"){
                  SET ccc TO getactions("Actions"+Pnum,LIST("ModuleScienceContainer"),inum, tagnum,optnin,3,LIST("collect")).
                  IF  ccc[3] <> 0{
                    ClearCHK(ccc,0,0,4,"<>","po/ SCIENCE COLLECTED","NA").
                  }
                }
              }
            }ELSE{
          IF inum = sciTag {
            IF NOT p:HASMODULE("modulecommand"){
              SET localmods TO TrimModules(listadd(scimodalt,p:modules:sublist(0,MAX(p:modules:length-1,3)),1),p,1).
            } ELSE SET localmods TO scimodalt.
            IF localmods = 0 {PRINTQ:PUSH(" NO MODULES FOUND:<sp>ORN"). RETURN.}
            SET LCO TO 1.
            IF optnin = 1{
              IF getactions("OnOff"+Pnum,localmods,inum, tagnum,1,1,LIST("review","reset")) <> 0  AND auto = 0{
                SET printout TO " DELETEDa               ".
                SET evact TO 2.
                IF P:HASMODULE("SCANexperiment") SET ccc TO getactions("Actions"+Pnum,LIST("SCANexperiment"), inum, tagnum,optnin,1, LIST("review", "analyze","delete","discard")).  
                ELSE SET ccc TO getactions("Actions"+Pnum,localmods, inum, tagnum,optnin,evact, LIST("delete","discard", "reset")). 
                SetTrgVars(CCC).
                SET forcerefresh TO 2.
              }ELSE{
                LOCAL wt TO 0.
                SET evact TO 1.
                IF auto < 2 {
                  LOCAL DDD TO getactions("Actions"+Pnum,localmods, inum, tagnum,optnin,EVACT, LIST("deploy","extend","open"),LIST("crew report")). //l1 = check to make sure deployed optns, l2 = if has sci action and unrelated deploy optn
                  IF DDD[3] <> 0 {
                    SET module1 TO DDD[0].
                    IF ddd[1] <> "" SET Event1On TO DDD[1]. ELSE SET Event1On TO DDD[2].
                    SET fld TO " ".
                    IF ddd[3] = 1{
                      SET wt TO 1.
                      ActionQNew:ADD(LIST(TIME:SECONDS+5,inum,tagnum,optnin)). 
                      ActionQNew:ADD(LIST(TIME:SECONDS+9,inum,tagnum,2)). 
                      PRINTQ:PUSH("Deploying! Experiment will run in 5 seconds then retract."+"<sp>"+"WHT").
                      SET PrintOverride TO -1.
                    }
                  }
                  }
                  IF wt = 0{

                      SET ccc TO getactions("Actions"+Pnum,localmods,inum, tagnum, optnin, 3,SciRun).
                      ClearCHK(ccc,-2).
                  }
              }
              SET scipart TO 1.
              }
            IF optnin = 2{
              SET evact TO 1.
                SET ccc TO getactions("Actions"+Pnum,localmods, inum, tagnum,optnin,2, LIST("transmit")).
                IF auto = 2 SET ccc[3] TO 0.
                IF  ccc[3] <> 0{
                  IF P:getmodule(ccc[0]):Hasdata{
                    P:getmodule(ccc[0]):transmit. 
                    LOCAL CNN TO 1.
                    IF rtech <> 0 {IF NOT rtech:hasKSCconnection(SHIP) SET cnn TO 0.} ELSE {IF HOMECONNECTION = "" SET CNN TO 0.}
                    IF cnn = 1 PRINTQ:PUSH(" TRANSMITTING SCIENCE"+"<sp>"+"WHT"). ELSE PRINTQ:PUSH(" NO CONNECTION"+"<sp>"+"ORN"). 
                    SET PrintOverride TO -1.
                  } 
                }ELSE{
                  SET ccc TO getactions("Actions"+Pnum,localmods,inum, tagnum,optnin,evact,LIST("deploy","extend","open"),LIST("retract","close")). 
                  ClearCHK(ccc,0,0,0,"=").
                }
            }
            IF optnin = 3{
              SET evact TO 2. 
              IF P:HASMODULE("ModuleScienceContainer"){
                SET ccc TO getactions("Actions"+Pnum,LIST("ModuleScienceContainer"),inum, tagnum,optnin,3,LIST("collect")).
                IF  ccc[3] <> 0{
                  ClearCHK(ccc,0,0,4,"<>","po/ SCIENCE COLLECTED","NA").
                }
              }
              IF GetActions(1,localmods,inum, tagnum,3,1,LIST("reset")) <> 0{
                SET ccc TO getactions("Actions"+Pnum,localmods, inum, tagnum, 3, 1, LIST("reset")).
                IF  ccc[3] <> 0{
                  SET botrow TO bigempty2.
                  ClearCHK(ccc,0,0,4,"<>","po/ RESET","NA"). //chkin, strg is 0, chlc is 0, chpo is 0, CHGEQ is ">", CHANS IS "", CHMod IS "".
                }
              }
              IF P:HASMODULE("scansat"){
                SET ccc TO  getactions("Actions"+Pnum,LIST("scansat"),inum, tagnum,2,1,LIST("start"),LIST("stop")).
                IF ccc[3]= 1 SET printout TO "SCAN STARTED".
                IF ccc[3]= 2 SET printout TO "SCAN STOPPED". 
                SetTrgVars(CCC).
              }
            }
            IF optnin = 4{
              FOR md IN sciModAlt{
                IF P:HASMODULE(md){
                  LOCAL pm TO P:GetModule(md).
                  LOCAL sc TO pm:alleventnames.
                  IF sc:length = 0 {SET sc TO pm:allactionnames. SET evact TO 2.}
                  IF sc:length > 0{
                    SET event1on TO sc[scipart-1]. SET event2on TO "".
                    SET event1off TO sc[scipart-1]. SET event2off TO "".
                    SET module1 TO md. SET module2 TO "".
                    PRINTQ:PUSH("EXPERIMENT "+event1on+" RUN"+"<sp>"+"CYN").
                    SET PrintOverride TO -1.
                    BREAK.
                  }ELSE{SpeedBoost("off").RETURN.}
                }
              } SET scipart TO 1.
            }
          }
          ELSE{
          IF inum = baytag{IF P:HASMODULE("Hangar") SET module TO module2.}
          ELSE{
          IF inum = geartag{
            SET SymCheck TO 1.
            SET evact TO 1.
            IF P:HASMODULE(module1) SET evact TO 2.
            IF P:HASMODULE(module2) AND NOT P:HASMODULE(module1) {SET fld TO " ". SET SymCheck TO 0.
              IF getactions("OnOff"+Pnum,AnimModAlt ,inum, tagnum,1,1,LIST("extend"),LIST("retract")) <> 0{
                LOCAL DDD TO TOGCHECK(PL,LIST("extend"),LIST("retract"),LIST("toggle"),AnimModAlt).
                IF DDD[0]:CONTAINS("TOGGLE") SET evact TO 2.
                SET ccc TO getactions("Actions"+Pnum,localmods,inum, tagnum,optnin,evact,DDD[0],DDD[1]).
                ClearCHK(ccc).
                ClearOOA().
              }
            }
            IF rowval = 1 {
              SET ccc TO LIST(0,0,0,0,0).
              IF optnin = 1 {SET ccc TO checkActions("HasField",1,LIST("ModuleWheelSuspension"), "spring/damper: override"   , "spring/damper: auto"   , "spring strength"  ,"", " spring/damper set to manual"   , " spring/damper set to auto").   }
              IF optnin = 2 {SET ccc TO checkActions("HasField",1,LIST("ModuleWheelBase")      , "friction control: override", "friction control: auto", "friction control" ,"", " friction control set to manual", " friction control set to auto").}
              IF optnin = 3 {SET ccc TO checkActions("HasField",1,LIST("ModuleWheelSteering")  , "steering adjust: override" , "steering adjust: auto" , "steering response",""," steering adjust set to manual" , " steering adjust set to auto" ).}
              ClearCHK(ccc,0,0,0,"<>").
            }
          }
          ELSE{
          IF inum = anttag{
            IF optnin = 1{
              IF rowval = 0 {
                IF P:HASMODULE("ModuleAnimateGeneric") AND NOT P:HASMODULE("ModuleDeployableAntenna"){
                  SET ccc TO getactions("Actions"+Pnum,LIST("ModuleAnimateGeneric"),inum, tagnum,optnin,1,LIST("extend"),LIST("retract")). 
                  IF  ccc[3] <> 0{SetTrgVars(CCC). SET OPTNIN TO 2.}
                }
              }ELSE{
                IF rowval = 1 AND ITMTRG = "SET TARGET"{
                  getEvAct(P,"ModuleRTAntenna","target",40, trglst[anttrgsel]).
                  PRINTQ:PUSH("target set to:"+ trglst[anttrgsel]+"<sp>"+"CYN"). 
                  SET PrintOverride TO -1.
                }
              }
            }
          }
          ELSE{
          IF inum = RBTTag{
            IF P:HASMODULE("ModuleRoboticController"){
              SET ccc TO "".
              SET fld TO " ".
              IF optnin = 1 {SET ccc TO getactions("Actions"+Pnum,LIST("ModuleRoboticController"),inum, tagnum,optnin,2,LIST("toggle play")). SET PRINTOUT TO " PLAY TOGGLED".}
              IF optnin = 2 {SET ccc TO getactions("Actions"+Pnum,LIST("ModuleRoboticController"),inum, tagnum,optnin,2,LIST("toggle loop mode")). SET PRINTOUT TO "LOOP MODE TOGGLED".}
              IF optnin = 3 {
                IF BTHD11 <> "ENAB/DISAB" {SET ccc TO getactions("Actions"+Pnum,LIST("ModuleRoboticController"),inum, tagnum,optnin,2,LIST("toggle direction")). SET PRINTOUT TO "DIRECTION TOGGLED".}
                ELSE                      {SET ccc TO getactions("Actions"+Pnum,LIST("ModuleRoboticController"),inum, tagnum,optnin,2,LIST("toggle controller enabled")). SET PRINTOUT TO "ENABLE TOGGLED".}
              }
              ClearCHK(ccc,-1,1). 
            }
              ELSE{
              IF OPTNIN = 1{
              LOCAL count TO 0.
              FOR MD IN localmods{
                IF P:modules:contains(MD) {
                  SET module1 TO MD. SET module2 TO "".
                  IF OPTNIN = 1 {
                    SET fld TO " ".
                    SET ccc TO getactions("Actions"+Pnum,LIST(MD),inum, tagnum,optnin,2,LIST("toggle")).
                    ClearCHK(ccc,-1,1).
                  }
                  BREAK.
                }
                SET count TO count+1.
              }
                FOR pt IN pl {getEvAct(pt,module1,"disengage servo lock",20).}
                }
              IF OPTNIN = 2{
                LOCAL swp TO SwapBool(getEvAct(p,module1,"locked",30,-1,2)).
                FOR pt IN pl {PRINTQ:PUSH(CheckTrue(40,pl,module1,"locked"," "+prtTagList[INUM][tagnum]+" LOCK ENABLED   "+"<sp>"+"CYN"," "+prtTagList[INUM][tagnum]+" LOCK DISABLED  "+"<sp>"+"RED")).}
                SET FORCEREFRESH TO 2.
                SpeedBoost("off").RETURN.
              }
            }
          }
          ELSE{
            IF inum = labtag{
              IF optnin = 3{SET evact TO 2. 
                SET ccc TO GetActions(5,LIST("ModuleScienceContainer"),inum, tagnum,optnin,3,LIST("collect")).
                ClearCHK(ccc,0,0,4,"<>","po/ SCIENCE COLLECTED","NA"). //chkin, strg is 0, chlc is 0, chpo is 0, CHGEQ is ">", CHANS IS "", CHMod IS "".
              }
            }           
            ELSE{
              IF INUM = DockTAG {
                IF optnin = 1{
                   IF P:HASSUFFIX("STATE") IF P:STATE ="DISABLED" {
                    IF getactions("OnOff"+Pnum,AnimModAlt ,inum, tagnum,1,1,LIST("OPEN"),LIST("CLOSE")) <> 0 {
                      ActionQNew:ADD(LIST(TIME:SECONDS,inum,tagnum,2)).
                      PRINTQ:PUSH(tagname+ " NOT DEPLOYED. DEPLOYING"+"<sp>"+"YLW").
                      SpeedBoost("off").RETURN.
                    }
                     }
                  IF P:HASSUFFIX("HASPARTNER") IF P:HASPARTNER <> TRUE {PRINTQ:PUSH(tagname+ " NOT DOCKED"+"<sp>"+"ORN"). SpeedBoost("off").RETURN.}
                }
                IF optnin = 2{
                  LOCAL l1 TO LIST("open","close","toggle"). LOCAL l2 TO LIST("open","close","toggle").
                  IF P:HASSUFFIX("STATE") IF P:STATE ="DISABLED" SET l2 TO LIST(""). ELSE SET l1 TO LIST(""). 
                  SET ccc TO getactions("Actions"+Pnum,AnimModAlt,inum, tagnum,optnin,3,l1,l2).
                ClearCHK(ccc,0,0,0,"<>"). 
                }
                IF optnin = 3 AND BTHD11 = "CNTRL FROM" {
                  SET ccc TO getactions("Actions"+Pnum,localmods,inum, tagnum,optnin,3,LIST("control from here"),LIST("control from here")).
                  ClearCHK(ccc,0,0,0,"<>"). 
                }
              }ELSE{
                         
              IF DbgLog > 0 log2file("    "+P:TOSTRING+"    NO TAG MATCH!!!!" ).}}}}}}}}}}}}}}}}
          //#endregion 
          //#region TRIGGER
           IF DBGLOG > 2 log2file("           TRIGGERSECTION:").
          IF module2   = module1   SET module2  TO "". 
          IF Event2On  = Event1On  SET Event2On  TO "". 
          IF Event2Off = Event1Off SET Event2Off TO "".
          IF evact <> 3 AND fld = " "{
            IF Event1On  = Event1Off SET Event1Off  TO "". 
            IF Event2Off = Event2On  SET Event2Off TO "".
          }
          IF fld = "" SET fld TO " ".
          IF modov = "" SET modsout TO LIST(module1,module2). ELSE SET modsout TO modov.
          IF modsout = "" SET modsout TO LIST(module1,module2).
          LOCAL EvOnOut TO listadd(LIST(Event1On,Event2On),OnOffAdd[0]).
          LOCAL EvOffOut TO listadd(LIST(Event1Off,Event2Off),OnOffAdd[1]).
          IF  ccc:length <  4 SET ccc TO               getactions("Actions"+Pnum,modsout,inum, tagnum,optnin,0,EvOnOut,EvOffOut).
          ELSE IF  ccc[3] = 0 SET ccc TO               getactions("Actions"+Pnum,modsout,inum, tagnum,optnin,1,EvOnOut,EvOffOut).
          IF  ccc[3] = 0 OR ccc[3] = 3{
            IF fld = " "  SET ccc TO  getactions("Actions"+Pnum,modsout,inum, tagnum,optnin,2,EvOnOut,EvOffOut).
            ELSE          SET ccc TO  getactions("Actions"+Pnum,modsout,inum, tagnum,optnin,0,EvOnOut,EvOffOut).
            }
          IF ccc[3] <> 0 {
            SET evact TO ccc[4].
            SetTrgVars(CCC,-1,evact).
            SET module TO ccc[0].
            IF fld <>" " AND CCC[2] = op{SET lightcheck TO 1.}ELSE{SET lightcheck TO ccc[3].}
            IF lightcheck = 1 OR lightcheck = 3{SET OPout TO optn2. SET command TO ccc[1].}
            IF lightcheck = 2                  {SET OPout TO optn3. SET command TO ccc[2].}
          }
          IF fld <>" " AND (evact <> 1 OR ccc[3] = 3){
            LOCAL yn TO 0. 
            LOCAL ddd TO getactions("Actions"+Pnum,modsout,inum, tagnum,optnin,4,LIST(fld)).
            SET lightcheck TO ddd[3].
            SET module TO ddd[0]. 
            //set fld to ddd[1]. 
            LOCAL FldVal TO ddd[2]. 
            IF FldVal = op{SET command TO Event1On.  SET OPout TO optn2. SET lightcheck TO 1.}
              ELSE{        SET command TO Event1Off. SET OPout TO optn3. SET lightcheck TO 2.}
              IF DbgLog > 0 log2file("     FIELD CHECK: "+module+"-"+command+"-"+fld+":"+fldval+"-"+op).
          }
          IF REMOVESPECIAL(printout," ") = "" SET printout TO modulelist[2][inum][OPout].
          IF dbglog > 0{
            log2file("              module:"+LISTTOSTRING(module)).
            log2file("              EVACT:"+LISTTOSTRING(evact)).
            log2file("              EvOnOut:"+LISTTOSTRING(EvOnOut)).
            log2file("              EvOffOut:"+LISTTOSTRING(EvOffOut)).
            log2file("              command:"+LISTTOSTRING(command)).
            log2file("              FLD:"+FLD).
            log2file("              fldoff:"+OP)..
            log2file("              OPout:"+OPout).
            log2file("              Symcheck:"+LISTTOSTRING(symcheck)).
            log2file("              PRINTOUT:"+PRINTOUT).
          }
          IF OPout > 0 {
              IF lightcheck = 1 OR lightcheck = 3 SET cmd TO TRUE.
              IF lightcheck = 2 SET cmd TO FALSE.
            SET dbgtrk TO "0".
            LOCAL lc TO 0.
                IF autoTRGList[0][inum][tagnum] > 0 AND auto = 1 SET evact TO 4.
                IF module <> "" SET modsout TO LIST(module). //if modov = "" SET modsout TO LIST(module).
                IF evact < 4 AND evact > 0{LOCAL cnt TO 0. LOCAL PUIDPrev TO LIST().
                FOR md IN modsout {IF dbglog > 2 log2file("            TriggerMOD:"+MD).
                  FOR pt IN pl {LOCAL pev TO evact.
                    IF symcheck = 1 {IF  pt:symmetrycount > 1{IF dbglog > 2 log2file("                  Symcheck:"+pt:uid).
                      FOR sym IN range (1,pt:symmetrycount+1){
                        //if sym = pt:symmetrycount+1 break. 
                        LOCAL inbt TO " =/= ".
                        IF PUIDPrev:contains(pt:SYMMETRYPARTNER(sym):uid) {SET pev TO 5. SET inbt TO "  =  ".}
                        IF dbglog > 2 log2file("                      part("+sym+"):"+pt:SYMMETRYPARTNER(sym):uid+inbt+listtostring(PUIDPrev)).
                        }
                      }
                    }
                      IF PrtListcur:contains(pt) AND SHIP:PARTS:contains(pt) AND pev < 5 {IF dbglog > 2 log2file("            TriggerPart("+cnt+"):"+pt). SET cnt TO cnt+1.
                        IF pev < 3{
                            IF getEvAct(PT,md,command,pev){
                              IF INUM = RBTTag AND autoRstList[0][0][tagnum] > 0 AND optnin =1 AND NOT P:HASMODULE("ModuleRoboticController"){ActionQNew:ADD(LIST(TIME:SECONDS+autoRstList[0][0][tagnum],inum,tagnum,2)).}   //QUEUE FOR ROBOT LOCK
                              IF inum = dcptag AND optnin = 1 {IF NOT tagname:contains("Payload") AND NOT tagname[0]:contains("Z0"){DcpPrtXtra(pt).}} //decoupler xtra
                              IF pev = 1 {
                                IF AltTrg = 1 {IF dbglog > 2 log2file("                    ALT Triggered:"+MD+"-"+command+"-"+AltTrg). LOCAL zz TO AlternateTrigger(pt,AltTrg,LIGHTCHECK). IF zz = FALSE SET AltTrg TO 0.}
                                IF AltTrg = 0{IF dbglog > 2 log2file("                    Event Triggered:"+MD+"-"+command).            IF pt:getmodule(md):hasevent(command) pt:GETMODULE(md):doevent(command).                   }}
                              IF pev = 2 {    IF dbglog > 2 log2file("                    Action Triggered:"+MD+"-"+command+"-"+cmd).   IF pt:getmodule(md):hasaction(command) pt:GETMODULE(md):doaction(command,cmd).              }
                            }
                          }
                        IF pev = 3 {getEvAct(PT,md,command,10).SET dbgtrk TO "3".}
                        WAIT 0.001.
                      } IF pev < 4 PUIDPrev:ADD(pt:uid).
                    }
                  }
                  IF rowval = 1 AND auto = 0 SET lco TO 1.
                IF inum <> lighttag AND P <> SHIP:rootpart AND lco = 0 SET lc TO LGHTCHECK(tagname,p).
                }
                IF evact = 4 SET PrintOverride TO -1.
                IF lc = 1 AND P <> SHIP:rootpart AND lco = 0 SET printout TO printout+" AND LIGHTS TOGGLED".
                LOCAL lcl TO lightcheck.
                SET lout TO PRFX+tagname+ " "+ printout.
                IF PrintOverride > 0  SET lcl TO PrintOverride.
                IF PrintOverride > -1 PRINTQ:PUSH(lout:tostring+"<sp>"+LCL:tostring).  
                IF debug > 0 PRINTLINE(module+"-"+command+"-"+opout+"-"+evact+"-"+cmd+"-"+fld+"-"+op,0,14).
                IF DbgLog > 0{
                  LOCAL EVTXT TO "      ACTION OUT:".
                  IF evact = 1 SET EVTXT TO "     EVENT  OUT:".
                  log2file(EVTXT+module+":"+command+" - "+modulelist[2][inum][OPout]+" - FIELD:"+fld+" - FIELDOFF:"+op+" lout:"+lout+" prfx:"+prfx+" PRINTOVERRIDE:"+PRINTOVERRIDE).
                }
                IF AutoDspList[0][INUM][TAGNUM]:LENGTH > 1 LINKCHECK(inum, tagnum).
                SetHudOptn(lightcheck, optnin, inum, tagnum).
          }
          ELSE{
            IF debug > 0 PRINTLINE(module1+"-"+module2+"-"+command+"-"+evact+"-"+LIGHTCHECK+"-"+fld+"-"+op+" NOTRG ",0,14).
            IF DbgLog > 0 AND evact <> 4 log2file("     MOD OUT: "+module1+"-"+module2+"-"+command+"-"+evact+"-"+LIGHTCHECK+"-"+fld+"-"+op+" NOTRG " ).
            IF PrintOverride > -1 AND evact <> 4 AND auto <> 1 {
            PRINTQ:PUSH(PRFX+tagname+ " "+ printout+" TRIGGER FAILED"+"<sp>"+"ORN").
            IF DbgLog > 0 log2file(PRFX+tagname+ " "+ printout+" TRIGGER FAILED" ).
            }
          }
          //#endregion 
          }
            IF evact = 4 AND auto = 1 {
              ActionQNew:ADD(LIST(TIME:SECONDS+AutoTRGList[0][inum][tagnum],inum,tagnum,optnin)). //ActionQueue2[AutoTRGList[0][inum][tagnum]]:ADD(List(inum,tagnum,optnin)). 
              PRINTQ:PUSH(tagname+" "+autoTRGList[0][inum][tagnum]+" SECOND DELAY"+"<sp>"+"YLW").
              IF DbgLog > 0 log2file("     "+tagname+" "+autoTRGList[0][inum][tagnum]+" SECOND DELAY").
              IF PRINTQ:LENGTH > 0 AND printpause = 0 PrintTheQ().
              SpeedBoost("off").RETURN.
            }
          IF PRINTQ:LENGTH > 0 {IF printpause = 0 PrintTheQ().}
          //#region TRG FUNCTIONS
          FUNCTION ClearCHK{ //ClearCHK(ccc,0,0,0,">","po/TOGGLED").
            LOCAL PARAMETER chkin, strg IS 0, chlc IS 0, chpo IS 0, CHGEQ IS ">", CHANS IS "", CHMod IS "".
            IF DbgLog > 2 log2file("                ClearCHK:"+" chkin:"+LISTTOSTRING(chkin)+" strg:"+strg+" chlc:"+chlc+" chpo:"+chpo+" CHGEQ:"+CHGEQ+" CHANS:"+CHANS+" CHMod:"+CHMod).
              IF (chkin[3] > 0 AND CHGEQ = ">") OR (chkin[3] < 0 AND CHGEQ = "<") OR (chkin[3] <> 0 AND CHGEQ = "<>") OR CHGEQ = "=" OR strg = -2{
              clearev().
              IF strg = -2 { SetTrgVars(chkin). RETURN.}
              SetTrgVars(chkin,strg).
              IF (CHmod <> "" AND chkin[0] = CHMod) OR chmod = "NA"{
                IF chmod <> "NA" clearev(chkin[3]).
                IF CHANS <> "" {
                  SET chans TO chans:split("/").
                  IF chans[0]:contains("po") SET printout TO CHANS[1].
                }
              }
              IF chlc <> 0 SET lightcheck TO chlc.
              IF chpo <> 0 {SET PrintOverride TO chpo.}
            } 
          }
          FUNCTION AlternateTrigger{
            LOCAL PARAMETER ATpart, ATopt, ATlchk.
            LOCAL ATres TO 0.
            IF atopt = 1 {IF ATlchk = 1{IF ATpart:HASSUFFIX("activate"){ATpart:activate. SET ATres TO 1.}}ELSE{IF ATlchk = 2{IF ATpart:HASSUFFIX("shutdown") {ATpart:SHUTDOWN. SET ATres TO 1.}}}}
            IF ATres = 1 RETURN TRUE. ELSE RETURN FALSE.
          }
          FUNCTION TogCheck{
            LOCAL PARAMETER TCPin, TCL1,TCL2, TCL3, TCMdls.
            LOCAL TCnt TO LIST(0,0).
            FOR PTS IN TCPIN{
              LOCAL CMP TO LIST().
              IF getactions("OnOff",TCMdls,0,PTS,1,1,TCL1) <> 0 SET TCnt[0] TO TCnt[0]+1.
              IF getactions("OnOff",TCMdls,0,PTS,1,1,TCL2) <> 0 SET TCnt[1] TO TCnt[1]+1.
            }
            IF TCNT[0] > 0 {IF TCNT[1] > 0 RETURN LIST(TCL3,TCL3). ELSE RETURN LIST(TCL1,"").}ELSE{IF TCNT[1] > 0 RETURN LIST("",TCL2).}
          }
          FUNCTION checkActions{
            LOCAL PARAMETER mode, evac, mods, opt1, opt2 IS "", field1 IS "", FldOffAns IS "", ans1 IS "", ans2 IS "".
            IF NOT opt1:istype("List") SET opt1 TO LIST(opt1).
            IF NOT opt2:istype("List") SET opt2 TO LIST(opt2).
            IF NOT field1:istype("List") SET field1 TO LIST(field1).
            LOCAL TmpMDX TO StrginAct(mode:tostring).
            SET mode TO TmpMDX[0].
            LOCAL mdx TO TmpMDX[1].
            IF NOT mdx:istype("scalar") SET mdx TO 0.
            IF DBGLOG > 2 log2file("        checkactions: MODE:"+MODE+" EVAC:"+EVAC+"MODS:"+LISTTOSTRING(MODS)+"opt1:"+LISTTOSTRING(opt1)+"opt2:"+LISTTOSTRING(opt2)+" FldOffAns:"+FldOffAns+" ans1:"+ans1+" ans2:"+ans2+" MDX:"+MDX).
            LOCAL FFF TO getactions("Actions"+Pnum,mods,inum, tagnum,optnin,evac,opt1,opt2). //standard check to evac
            IF mdx > 0 AND FFF[3] = 0 SET FFF TO getactions("Actions"+Pnum,mods,inum, tagnum,optnin,mdx,opt1,opt2).//add number to mode or use number only to use alt event call on fail of 1st
            IF mode = "OnOff"{//overwrite on/off with different value
              LOCAL skp TO 0.
              IF field1 <> ""  IF FFF[0] <> field1 SET skp TO 1. 
              IF FFF[3] > 0 AND skp = 0 {SET FFF[3] TO getactions("OnOff"+Pnum,mods,inum, tagnum,optnin,3,opt1,opt2).}
              }
            IF mode = "HasField" {//check if field exists to verify on/off            
              SET FFF[3] TO getactions("OnOff"+Pnum,mods,inum, tagnum,optnin,4,field1).
              IF FFF[3] = 0 SET FFF[3] TO 2.
              IF FFF[3] = 2 SET PRINTOUT TO ans1.
              IF FFF[3] = 1 SET PRINTOUT TO ans2.
              SET PrintOverride TO 1.
            }
            IF DBGLOG > 2 log2file("        checkactionsANS:"+LISTTOSTRING(FFF)).
            RETURN FFF.
          }
          FUNCTION SetTrgVars{
            LOCAL PARAMETER inlst, fldin IS 0, evactin IS 0.
            IF DbgLog > 1 log2file("                SETTRGVARS: inlst:"+LISTTOSTRING(inlst)+" fldin:"+fldin+" evactin:"+evactin+" FLDin:"+fld).
            IF evactin = 0 SET evact TO inlst[4].
              IF inlst[0] <> "" AND inlst[0] <> module2 SET module1 TO inlst[0]. 
              IF inlst[1] <> "" AND inlst[1] <> Event2On  SET Event1On  TO inlst[1].
              IF inlst[2] <> "" AND inlst[2] <> Event2Off SET Event1Off TO inlst[2]. 
              IF inlst[3] <> "" SET lightcheck TO inlst[3].
            IF fldin <> -1{
              IF fldin = 0 SET fld TO " ". ELSE SET fld TO fldin.
            }
            IF DbgLog > 1 log2file("                  MODULEout:"+INLST[0]+" EVENT1ONout:"+EVENT1ON+" EVENT1OFFout:"+EVENT1OFF+" EVENT2ONout:"+EVENT2ON+" EVENT2OFFout:"+EVENT2OFF+" LIGHTCHECKout:"+LIGHTCHECK+" FLDout:"+fld).
          }
          FUNCTION LINKCHECK{
            LOCAL PARAMETER inm, tnm.
            IF DbgLog > 0 log2file("   LINKCHECK:"+ITEMLIST[Inm]+":"+PRTTAGLIST[INUM][TNM]+"("+LISTTOSTRING(AutoDspList[0][inm][tnm])+")").
            LOCAL itm2 TO "0".
            SET AutoDspList[0][inm][tnm] TO DEDUP(AutoDspList[0][inm][tnm]).
            FOR I IN RANGE(AutoDspList[0][inm][tnm]:LENGTH-1,0){
              LOCAL itm1 TO AutoDspList[0][inm][tnm][I].
              IF itm2 <> itm1 {
                LOCAL aa TO 0.
                LOCAL splt TO itm1:split("-").
                IF splt:length > 2 {IF splt:length = 4{SET aa TO 0-splt[3]:tonumber. SET splt[2] TO aa:tostring.}
                LOCAL pnt TO LIST(TIME:SECONDS+AutoTRGList[0][splt[0]:tonumber][splt[1]:tonumber],splt[0]:tonumber,splt[1]:tonumber,splt[2]:tonumber).
                IF NOT ActionQNew:contains(pnt) ActionQNew:ADD(pnt).
                IF aa = 0 AutoDspList[0][inm][tnm]:REMOVE(I).
                }
              }
              SET itm2 TO itm1.
            }
          }
          FUNCTION LGHTCHECK{
                LOCAL PARAMETER  tn, LCPin.
                LOCAL rtn IS 0.
                IF lighttag = 0 RETURN rtn.
                LOCAL SKP TO 1.
                IF prttaglist[lighttag]:contains(tn) SET skp TO 0.
                FOR md IN lightChkskp{ IF p:HASMODULE(md) SET SKP TO 1. BREAK.}
                 IF SKP = 0{SET rtn TO 1. ActionQNew:ADD(LIST(TIME:SECONDS+1,1,prttaglist[lighttag]:find(tn),1)).}
              IF DbgLog > 0 log2file("      LIGHTCHECK:"+TN+"("+rtn+")").
                RETURN rtn.
          }
          FUNCTION SetHudOptn{
            LOCAL PARAMETER lchk, opchk, IN, tn.
            IF DbgLog > 1 log2file("      SETHUDOPTN-LCHK:"+LCHK+" opchk:"+opchk+" IN:"+IN+" TN:"+TN).
              IF lchk = 1 {
                IF opchk =1  SET GrpDspList[IN][tn] TO 2.
                IF opchk =2 SET GrpDspList2[IN][tn] TO 4.
                IF opchk =3 SET GrpDspList3[IN][tn] TO 6.
              }
              IF lchk = 2 {                  
                IF opchk =1 SET  GrpDspList[IN][tn] TO 1.
                IF opchk =2 SET GrpDspList2[IN][tn] TO 3.
                IF opchk =3 SET GrpDspList3[IN][tn] TO 5.
              }
              IF forcerefresh = 0 SET forcerefresh TO 1.
              RETURN.
          }
          FUNCTION DcpPrtXtra{
            LOCAL PARAMETER prt.
            LOCAL wtx TO 0.
            IF DbgLog > 0 log2file("   DCP PART EXTRA:"+prt).
              FOR chl IN prt:children {
                FOR chl2 IN chl:children {
                  FOR chl3 IN chl2:children {
                    actions(chl3).}
                  actions(chl2).}
                actions(chl).
              }
                  LOCAL FUNCTION actions{
                  LOCAL PARAMETER prt2, m IS "", evnt IS "", dcpxev IS 1.
                  LOCAL cont TO 0.
                  LOCAL DCPmods TO TrimModules(DcpXtraMod,prt2,1).
                  IF dcpmods[0] = 0 RETURN.
                    FOR it IN DCPmods{IF prt2:modules:contains(it){SET cont TO 1. BREAK.}}
                    IF cont = 0 RETURN.
                      LOCAL lll TO GetActions("Actions",DCPmods,0, prt2,0,3,LIST("on", "activate","deploy","arm","toggle")).
                      IF DbgLog > 0 log2file("   DCP PART EXTRATRG:"+LISTTOSTRING(LLL)).
                      IF  lll[3] > 0 AND (prt2:tag = "" OR prt2:tag = prt:tag){
                        SET m TO lll[0]. SET evnt TO lll[1]. SET dcpxev TO lll[4]. SET fnd TO 1.
                        IF dcpxev = 1 {IF prt2:getmodule(m):hasevent(evnt) prt2:getmodule(m):doevent(evnt).}ELSE getEvAct(prt2,m,evnt,10).
                        IF dcpxev = 2 {IF prt2:getmodule(m):hasAction(evnt) prt2:getmodule(m):doAction(evnt, TRUE).}
                        WAIT .001.
                        IF evnt:contains("chute") OR evnt:contains("deploy") SET wtx TO .25.
                      }
                }
                WAIT wtx.
              }
          FUNCTION clearooa{
                SET OnOffAdd TO LIST("","").
              }
          FUNCTION clearev{
            LOCAL PARAMETER op IS 0.
            IF dbglog > 2 log2file("              clearev("+OP+")").
            IF op = 0 {
              SET event1on TO "". SET event1off TO "". SET module1 TO "".
              SET event2on TO "". SET event2off TO "". SET module2 TO "".
            }ELSE{
              SET Event1Off TO Event1On. SET fld TO " ".
              IF op = 1 {SET Event1Off TO "". SET Event2Off TO "".}
              IF op = 2 {SET Event1On TO "". SET Event2On TO "".}
            }
          }
          //#endregion 
          RETURN.
      }
    FUNCTION TopHugTrig{//translate top buttons to appropriate triggers
        LOCAL PARAMETER HudNum.
        LOCAL trgnum TO enghud[hudnum].
        LOCAL ActNum TO 1.
        IF trgnum > 100 {SET actnum TO trgnum - 100. SET trgnum TO enghud[hudnum-1].}
        togglegroup(engtag,TrgNum,ActNum,3).
    }

    //#region meter set
   FUNCTION UpdateMeterLeft{//left meter
    LOCAL PARAMETER 
    ItemNum IS hsel[2][1],
    TagNum  IS hsel[2][2].
         LOCAL lim TO 7-ln14.
         LOCAL sensordisp TO LIST().
          IF hudop <> 5{
            IF FlState = "Space" OR FlState = "SpaceATM"{
              IF HASNODE = TRUE{
                LOCAL TM TO formatTime(ETA:NEXTNODE).
                IF TM <> "PASSED" sensordisp:ADD("NODE:"+TM+"   ").
              }
              IF ORBIT:hasnextpatch = TRUE{
                LOCAL TM TO formatTime(ETA:TRANSITION).
                IF TM <> "PASSED" sensordisp:ADD("XSTN:"+TM+"   ").
              }
            }
            LOCAL skp TO 0.
            IF ItemNum = engtag OR (crewact:length > 1 AND (ItemNum = CMDTag OR ItemNum = labtag)) OR (itemnum = scitag AND scanlist:length > 0) SET skp TO 1.
            IF skp = 0 {
              IF senseskp = 0 {
                IF senselist[3] = 1 AND AutoValList[0][0][3][8]  <> 2 {sensordisp:ADD("PSR :"+ROUND(SHIP:SENSORS:PRES,0)+" kPa").}
                IF senselist[1] = 1 AND AutoValList[0][0][3][11] <> 2 {sensordisp:ADD("GRAV:"+ROUND(SHIP:sensors:grav:MAG,1)+" M/S2").}
                IF senselist[4] = 1 AND AutoValList[0][0][3][10] <> 2 {sensordisp:ADD("TEMP:"+ROUND(SHIP:SENSORS:TEMP,1)+" K").}
                IF senselist[0] = 1 AND AutoValList[0][0][3][12] <> 2 {sensordisp:ADD("ACCL:"+ROUND(SHIP:sensors:acc:MAG,1)+" G").}
                IF senselist[2] = 1 AND AutoValList[0][0][3][9]  <> 2 {sensordisp:ADD("SUN :"+ROUND(SHIP:SENSORS:LIGHT,2)+" EXP").}
              }
            }
            ELSE{
            IF ItemNum = ENGTag{
              LOCAL eng_list TO prtlist[engtag][TagNum].
              LOCAL ltg TO prtTagList[engtag][TagNum].
              LOCAL enout TO LIST().
              LOCAL cnt TO 0.
              LOCAL thr TO 0.
              FOR engs IN eng_list {
                IF engs:HASSUFFIX("thrust"){
                  LOCAL thrs TO engs:thrust.
                  IF thrs > 10 SET thrs TO ROUND(thrs,0). ELSE SET thrs TO ROUND(thrs,1).
                  LOCAL enout1 TO ltg+":("+cnt+"):"+thrs.
                  IF engs:HASSUFFIX("flameout") IF engs:flameout = TRUE SET enout1 TO ltg+"("+cnt+"):"+"FLAMEOUT".
                  IF engs:HASSUFFIX("ignition") IF engs:ignition = FALSE SET enout1 TO ltg+"("+cnt+"):"+"OFF".
                    SET thr TO thr + thrs.
                    SET cnt TO cnt+1.
                    LOCAL LSFX TO "kN".
                    IF ENOUT1:TOSTRING:CONTAINS("OFF") SET LSFX TO "".
                    enout:ADD(enout1+LSFX).
                  }
                }
                IF thr > 0 enout:insert(0,ltg+" THRUST:"+thr+"kN").
                FOR ac IN enout sensordisp:ADD(ac).
              }
              ELSE{
                IF ItemNum = LabTag OR ItemNum = CMDTag OR ItemNum = ACDTag OR ItemNum = habtag{
                  sensordisp:ADD("CREW:"+MeterList[3][ItemNum]+":"+prtTagList[ItemNum][TagNum]). 
                  FOR ac IN CrewAct {FOR pts IN prtList[ItemNum][TagNum]{IF ac:part = pts AND ac:part:tag = prtTagList[ItemNum][TagNum] AND NOT sensordisp:contains(ac) sensordisp:ADD(ac).}}
                }ELSE{
                IF ItemNum = scitag AND scanlist:LENGTH > 0{
                  sensordisp:ADD("Surface Scanner:").
                  FOR i IN range(Lscroll[0],MAX(Lscroll[1]+1,MIN(7,scanlist:length-1))){ IF I = LSCROLL[1]+1 BREAK. sensordisp:ADD(scanlist[i]).} 
                  IF scanlist:length > lim-1 SET lscroll[0] TO ADDMAX(Lscroll[0],1,0,Lscroll[1]-6).
                  } 
                }
              }
            }
          }ELSE{
                  sensordisp:ADD("ACTIONS AVAILABLE:").
                  FOR i IN actnlist:sublist(1,actnlist:length-1){sensordisp:ADD(" "+i).} 
                  SET lim TO actnlist:length.
          }
        IF sensordisp:LENGTH < lim {sensordisp:INSERT(0,"                                        ").}
        UNTIL sensordisp:length > lim-1 sensordisp:ADD("                                        ").
        LOCAL spc TO " ".
        FOR ln IN range (0, lim-1){IF ln < sensordisp:length PRINT sensordisp[ln]:tostring:padright(widthlim/2) AT (1,ln+8).  ELSE {IF ln+9 < lim+8 PRINT spc:padright(widthlim/2) AT (1,ln+8). BREAK.}}
        IF hudop = 5 PRINT ">"AT (1,AutoSetAct+8).
    }
   FUNCTION UpdateFuel{
    LOCAL PARAMETER 
    ItemNum IS hsel[2][1],
    TagNum  IS hsel[2][2].
        IF dcptag <> 0 AND ItemNum = dcptag AND fuelmon = 1 {
          IF DCPRes = 0 {
            LOCAL rscl TO getRSCList(DcpPrtList[TagNum][1]:RESOURCES).
            SET prsclist TO rscl[0].
            SET prsclist2 TO rscl[2].
            SET pRscNum TO rscl[1].
            SET DCPRes TO 1.
          }
            IF newhud = 1 {
              IF autoRscList[ItemNum][TagNum]:istype("string") {
                    SET RscSelection TO safekey(pRscNum,autoRscList[ItemNum][TagNum]). } 
              ELSE {SET RscSelection TO autoRscList[ItemNum][TagNum].}
            }
            LOCAL lm TO widthlim-5-ClrMin. 
            LOCAL fmtr TO GetFuelLeft(DcpPrtList[TagNum],3,0,RscSelection).
            LOCAL lcl TO MtrColor(fmtr).
            printline (" "+HudOpts[1][1],0,16).
            IF lcl:istype("string") AND HudOpts[1][1] <> "No Part"{
              PRINTLINE("("+fmtr+"%)"+GetFuelLeft(DcpPrtList[TagNum],0,lm,RscSelection),lcl).
              }
        }
    }  
   FUNCTION MtrColor{//returns color based on percentage
  LOCAL PARAMETER pctin.
  LOCAL lcl TO "WHT".
  IF pctin < 10 SET lcl TO "RED".ELSE{
  IF pctin < 25 SET lcl TO "RRN".ELSE{
  IF pctin < 40 SET lcl TO "ORN".ELSE{
  IF pctin < 55 SET lcl TO "YRN".ELSE{
  IF pctin < 70 SET lcl TO "YLW".ELSE{
  IF pctin < 85 SET lcl TO "YGR".ELSE{
  IF pctin < 95 SET lcl TO "GRN".ELSE{
  }}}}}}}
  RETURN lcl.
}
   FUNCTION SETHUD{//set some button content, almost totally depreciated
    LOCAL PARAMETER ItemNum IS hsel[2][1].
          IF rowval = 0 {
            SET HUDOP TO 1.
            IF itemnum = scitag{} SET HUDOP TO 2.
          }
          IF rowval = 1 {
              SET HUDOP TO 4.
              IF itemnum = DCPtag{SET HUDOP TO 10. SET hudoptsl[1][10] TO "RSRC   ". SET hudoptsl[3][10] TO "RSRC   ".SET HDXT TO "    ".}
              ELSE{
              IF   MeterPart > 0 {
                SET hudop TO 10. SET hudoptsl[1][10] TO "LIMIT  ". SET hudoptsl[3][10] TO "LIMIT  ".SET HDXT TO "OPTN".
                }
              ELSE{
              IF itemnum = Flytag{SET hudop TO 10.
                IF ItmTrg = " SET TRGT "{SET hudoptsl[1][10] TO "TARGET ". SET hudoptsl[3][10] TO "TARGET ".SET HDXT TO "    ".}
                ELSE{SET hudoptsl[1][10] TO "LIMIT  ". SET hudoptsl[3][10] TO "LIMIT  ".SET HDXT TO "AMNT".}}
              ELSE{
              IF mks = 1 {
                IF itemnum = pwrtag OR itemnum = MksDrlTag {SET hudop TO 10. SET hudoptsl[1][10] TO "GOV    ". SET hudoptsl[3][10] TO "GOV    ".}
              }ELSE{}}}}//}}}
          }
          PRINT "         " AT (61,8).
          IF hudop <> 5 AND hudopprev = 5 {PRINTLINE(). PRINTLINE("",0,16). }
    }
   FUNCTION GetFuelLeft{
     LOCAL PARAMETER prts, opt IS 1, GMAX IS 0, resnum IS 0,
    ItemNum IS hsel[2][1],
    TagNum  IS hsel[2][2].
    LOCAL GFLDlvl TO 2.
    IF Tagnum = dcptag SET GFLDlvl TO 6. 
     IF dbglog > GFLDlvl log2file("    GETFUELLEFT:"+ItemList[itemnum]+":"+prtTagList[itemnum][Tagnum]+" resnum:"+resnum).
     LOCAL prtf TO prts:COPY.
     IF resnum:istype("string"){
      IF hudop <> 5 {
        IF Tagnum = dcptag {
             SET resnum TO safekey(pRscNum,resnum).}
        ELSE{SET resnum TO safekey(RscNum ,resnum).}
      }
     }
      LOCAL PctTot TO 0.
      SET cnt TO 0.
      IF prtf:length = 0 RETURN.
         prtf:ADD("").
      LOCAL pl4 TO prtf:sublist(1, prtf:length).
      IF pl4:length = 0 RETURN.
      IF dbglog > GFLDlvl log2file("               :"+LISTTOSTRING(pl4)+" OPT:"+opt+" gmax:"+gmax+" resnum:"+resnum + " AUTOTRG:"+autoTRGList[0][itemnum][Tagnum]).
      LOCAL gauge TO ":".
      LOCAL DCPGone TO 1.
      IF autoTRGList[0][itemnum][Tagnum] > -1 {
          FOR pt IN pl4{
              IF pt <> "" {
                IF dbglog > GFLDlvl log2file("    PRT:"+pt).
                IF pt <> CORE:PART{
                  SET DCPGone TO 0.
                  IF resnum > pt:RESOURCES:length SET resnum TO pt:RESOURCES:length-1.
                  IF pt:RESOURCES:length > MAX(resnum-1,0) {
                    IF  pt:RESOURCES[resnum]:CAPACITY > 0 {
                      IF SHIP:parts:contains(pt){
                        SET resource TO pt:RESOURCES[resnum].
                        SET ResCur TO resource:NAME+":".
                        SET percentage TO resource:AMOUNT / resource:CAPACITY * 100.
                        SET cnt TO cnt+1.
                        SET PctTot TO PctTot+percentage.
                      }
                    }ELSE{SET HudOpts[1][1] TO pt:RESOURCES[resnum]:NAME+":". IF opt < 3 SET gauge TO ":No res. storage". ELSE SET gauge TO 0.}
                  }ELSE{IF opt < 3{SET HudOpts[1][1] TO "". SET HudOpts[1][2] TO "".} SET gauge TO ":No resources".}

                }
              }
            }
          }
              IF DCPGone = 1 {SET HudOpts[1][1] TO "No Part". SET HudOpts[1][2] TO " ". SET gauge TO "                                                                       ". SET DcpPrtList[Tagnum] TO LIST(0,"").}
              ELSE{
                IF gauge = ":No resources" OR cnt = 0 OR gauge = 0{}ELSE{
                  SET percentage TO PctTot/cnt.
                  IF opt > 4 {
                    IF opt = 5 SET rescur TO "".
                    SET rescur TO rescur+"("+ROUND(percentage,0)+"%)".
                    IF gmax = 0 SET GMAX TO widthlim-3-rescur:length.
                    IF colorprint = 1 SET gauge TO GETCOLOR(SetGauge(percentage, 1, GMAX-9),mtrcolor(percentage)).
                    ELSE  SET gauge TO SetGauge(percentage, 1, GMAX).
                    IF gauge = ":" SET gauge TO ":EMPTY                       ".
                    RETURN rescur+gauge.
                  }
                  IF opt =3 {SET gauge TO ROUND(percentage).}
                  IF opt =4 {SET gauge TO ROUND(percentage,3).}
                  IF OPT < 3{
                    IF opt =1 SET ResCur TO rescur + " ".
                    SET HudOpts[1][1] TO rescur.
                    SET gauge TO SetGauge(percentage, 1, GMAX).
                    IF gauge = ":" SET gauge TO ":EMPTY                       ".
                  }
                }
              }
              IF dbglog > 2 log2file("      "+" AMT:"+gauge+" DCPGONE:"+DCPGone). 
              RETURN gauge.
    }
   FUNCTION adjust_thrust{//adjust some meters, almost totally depreciated
     LOCAL PARAMETER PrtsIN, AMOUNT, direction, op IS 1.
      LOCAL PrtsIN2 TO PrtsIN:sublist(1, PrtsIN:length).
     IF op =1{
        FOR engine IN PrtsIN2 {
            IF engine:HASSUFFIX("thrustlimit"){
            SET CurLim TO engine:thrustlimit.
            IF direction = "+" {SET NewLim TO CurLim + AMOUNT.
            } ELSE {SET NewLim TO CurLim - AMOUNT.}
            SET NewLim TO MAX(0, MIN(100, NewLim)).
            SET engine:thrustlimit TO NewLim.
            }
        }
      }
     IF op =2{
        FOR GOV IN PrtsIN2 {
          SET CurLim TO GOV:getmodule("mksmodule"):getfield("governor").
          IF direction = "+" {SET NewLim TO CurLim + AMOUNT.
          } ELSE {SET NewLim TO CurLim - AMOUNT.}
          IF newlim > 1 SET NewLim TO 1. IF newlim < 0 SET NewLim TO 0.
          GOV:getmodule("mksmodule"):setfield("governor", NewLim).
        }
      }
    }
   FUNCTION adjust_Meter{
      LOCAL PARAMETER PrtsIN, AMOUNT, direction, op IS 1, inum IS 1, limitlow IS 0, limit IS 100, fldin IS 0, mdl IS 0.
      IF dbglog > 1{
        log2file("    ADJUST_METER:"+" amount:"+AMOUNT+" direction:"+direction+" op:"+op+" inum:"+inum+" limitlow:"+limitlow+" limit:"+limit).
        log2file("        "+LISTTOSTRING(PrtsIN)).
      }
      SET BOTPREV TO "zz". SET STPREV TO "zz". 
      SET lastdir TO direction.
      LOCAL PrtsIN2 TO PrtsIN:sublist(1, PrtsIN:length).
      LOCAL opset TO op.
      LOCAL optn1 TO opset*3-2.
      LOCAL mdn TO 0.
      LOCAL rnd IS 0.
      IF AMOUNT:TOSTRING:CONTAINS(".") {//auto set round
        LOCAL AA TO AMOUNT:TOSTRING:split(".").
        SET rnd TO MIN(AA[1]:LENGTH,2).
      }
      IF fldin = 0 SET FldIn TO modulelist[2][inum][optn1].
      IF mdl = 0 {IF meterlist[0][2][0][0] <> "" SET mdl TO splitlist(meterlist[0][2][0][0]). ELSE SET mdl TO modulelist[0][inum][optn1].}
       IF NOT MDL:istype("list") SET MDL TO LIST(MDL).
        FOR Pt IN PrtsIN2 {
          FOR MDL2 IN MDL {
            IF getEvAct(pt,MDL2,FldIn,3,2){
              SET CurLim TO BoolNum(getEvAct(pt,MDL2,FldIn,30,-1,2)).
              IF curlim:istype("list"){
                IF mtrcur[7]:length > 1 {
                  SET curlim TO curlim[0].
                  chklim().
                } ELSE BREAK.
              }
                ELSE{
              IF NOT CurLim:istype("Scalar") SET CurLim TO CurLim:tonumber.
                IF mtrcur[7]:length > 1 {IF mtrcur[7][mtrcur[7]:length-1] = "-1" AND limitlow = 1 SET limitlow TO 0.} 
              IF AMOUNT <> 0 {
                IF mdn = 0 {
                  IF direction = "+" {SET NewLim TO CurLim + AMOUNT.} ELSE {SET NewLim TO CurLim - AMOUNT.}
                  IF newlim > limit SET NewLim TO limit. 
                  IF newlim < limitlow SET NewLim TO limitlow.
                  SET mdn TO 1.
                }
                IF mtrcur[7]:length > 1 {
                  IF mtrcur[7][mtrcur[7]:length-1] = "-1" chklim().
                  }
              }
              ELSE{SET newlim TO SwapBool(getEvAct(pt,MDL2,FldIn,30,-1,2)).}
            }
            IF curlim:istype("Scalar") AND NOT newlim:istype("Scalar") AND NOT newlim:istype("Boolean") SET NewLim TO BoolNum(newlim,1).
            IF newlim:istype("Scalar") Pt:getmodule(MDL2):setfield(FldIn, ROUND(NewLim, rnd)). ELSE Pt:getmodule(MDL2):setfield(FldIn, NewLim).
              IF dbglog > 1{
                log2file("        PART:"+pT+" FIELD:"+FldIn+" SET "+CurLim+" TO:"+NewLim).
              }BREAK.
            }
          }
        }
        FUNCTION chklim{
          LOCAL tmplim TO mtrcur[7]:find(curlim:tostring).
          IF direction = "+" {
            IF mtrcur[7]:length-1 > tmplim SET newlim TO mtrcur[7][tmplim+1].
            ELSE SET newlim TO mtrcur[7][0].
            IF NEWLIM:TOSTRING = "-1" SET newlim TO mtrcur[7][0].
          }ELSE{
            IF tmplim > 0 SET newlim TO mtrcur[7][tmplim-1].
            ELSE SET newlim TO mtrcur[7][mtrcur[7]:length-2].
            IF NEWLIM:TOSTRING = "-1" SET newlim TO mtrcur[7][mtrcur[7]:length-2].
          }
        }
    }
   FUNCTION CheckDcpFuel{//decoupler fuel check
    //if dbglog > 2 log2file(" CHECKDCPFUEL").
  FOR t IN Range(1,prttagList[dcptag][0]+1){
    IF AutoDspList[dcptag][T] = modeshrt:find("FUEL") {
      IF NOT prttaglist[dcptag][T]:contains("Payload"){
      LOCAL trg TO 0. 
      LOCAL vl TO abs(AutoValList[dcptag][T]).
      IF vl = 1 SET vl TO 0.01.
      LOCAL fllft TO GetFuelLeft(DcpPrtList[T],4,0,AutoRscList[dcptag][T],dcptag, t).
        IF NOT fllft:tostring:contains("                                                                       ") {
          IF AutoValList[dcptag][T] > -0.0001 AND fllft > vl SET trg TO 1.
          IF AutoValList[dcptag][T] <  0.0001 AND fllft < vl SET trg TO 2.
          //if dbglog > 2 log2file("     T("+T+")trg("+trg+") - TargetVal:"+vl+" - ActVal:"+fllft).
          IF trg > 0{ToggleGroup(dcptag,t,1,1). ClearAuto(dcptag,t,trg,modeshrt:find("FUEL")).}
        } 
      }
    }
  }
}
   FUNCTION SetGauge{ //returns gauge of 0-100 percent set to fit after row items 1 and 2. 
      LOCAL PARAMETER pct, row, Gmax IS 0.
      SET pct TO ROUND(pct, 0).
      IF dbglog > 2 log2file("              SetGauge: pct:"+pct+" GMAX:"+gmax).
      LOCAL gauge TO ":".
      IF pct <> "                                    "{
      IF pct:typename <> "Scalar"{
        SET pct TO removeletters(pct).
        SET pct TO pct:tonumber.
      }
      IF pct < 100.001 {IF pct > 100 SET pct TO 100.
       IF Gmax = 0{SET GaugeLim TO widthlim-3-HudOpts[row][1]:length-HudOpts[row][2]:tostring:length.}ELSE {SET GaugeLim TO Gmax.}
        FOR i IN RANGE(1, ROUND(pct/(100/GaugeLim),0)) {SET gauge TO gauge+"=".}
        FOR i IN RANGE(ROUND(pct/(100/GaugeLim),0),100/(100/GaugeLim)) {SET gauge TO gauge+"_".}
      }ELSE{SET gauge TO ":OVER LIMIT!!!".}
      RETURN gauge.} ELSE{RETURN pct.}
    }   
   FUNCTION CheckAGs{//check for external changes in action groups
          IF ItemLastRun <> agtag {
          IF dbglog > 2 log2file("        CHECKAGs"+" ItemLastRun:"+ItemLastRun).
            FOR agi IN range (0,AgState:length-1) {
              IF AgState[agi] <> AgSPrev[agi] {
              IF dbglog > 2 log2file("          TOGGROUP:"+(agi+1)+" CRNT:"+AgState[agi]+" PREV:"+AgSPrev[agi]).
                togglegroup(agtag,agi+1,-2,2). 
              }
            }
          }
          SET ItemLastRun TO 0.
          SET AgSPrev TO AgState:COPY.
      }   
   FUNCTION MultiMeter{//sets up new meter disaplays
    LOCAL itemnum IS hsel[2][1].
    LOCAL Tagnum IS hsel[2][2].
    SET meterpart TO 2.
    LOCAL PARAMETER prtin IS currentpart, 
    ModIn IS MeterList[0][1], 
    MtrList IS MeterList[0][2], 
    opt IS 0, RND IS -1, rws IS 2,  DBGLVL IS 1 .
    LOCAL dbglvlH TO MIN(DBGLVL+1,2).
    LOCAL rvl TO rowval.
    LOCAL NoMTR TO TRUE.
    IF NOT ModIn:typename:contains("list")  SET ModIn TO LIST(modin).
    IF opt = 1 OR MtrCur[4] = 0 OR meterlist[0][0] = "Option Not Available" SET rvl TO 0.
    IF MtrOps[itemnum][0] = 1 SET rvl TO 1.
    IF dbglog > DBGLVL log2file("      MultiMeter:"+prtin+" Mod:"+LISTTOSTRING(modin)+" RowVal:"+rvl).
    IF MtrList[0][0] <> "" {
      IF MtrList[0][0] <> "" SET ModIn TO splitlist(MtrList[0][0]).
      IF dbglog > dbglvlH log2file("        MtrList[0][0]:"+MtrList[0][0]).}
    IF MtrList[1][0] <> "" {IF dbglog > dbglvlH log2file("        MtrList[1][0]:"+MtrList[1][0]).}
    IF MtrList:length > 2 {IF dbglog > dbglvlH log2file("       MtrList[2]:"+LISTTOSTRING(MtrList[2])). 
    }
    LOCAL dbgtrk TO "0-".
    IF FieldList[2]:length = 1 AND fieldlist[2][0] ="" SET rvl TO 0.
    IF rvl = 1 {
      SET dbgtrk TO dbgtrk+"1-".
      FOR Md IN ModIn{
          LOCAL MidEnd TO "".
        IF prtin:HASMODULE(md){
          IF dbglog > dbglvlH log2file("          MOD:"+MD). 
          SET BOTPREV TO "000".
          LOCAL fldV TO FieldList[2][MtrCur[5]].
          LOCAL FISAdjBy TO mtrcur[7][mtrcur[7]:length-1].
          IF rnd = -1 {
            IF mtrcur[7][0]:TOSTRING:CONTAINS(".") {//auto set round
              LOCAL AA TO mtrcur[7][0]:TOSTRING:split(".").
              SET RND TO AA[1]:LENGTH.
            }ELSE SET RND TO 0.
          }
          IF prtin:getmodule(MD):hasfield(fldV){
            IF dbglog > dbglvlH log2file("          FIELD:"+FLDV).
            LOCAL ValRes TO getEvAct(prtin,MD,fldV,30,RND,dbglvlH).
            SET HudOpts[1][3] TO "". SET HudOpts[1][2] TO "".
            SET MeterList[0][0] TO fldv.
            IF mtrcur[7]:length = 3 AND mtrcur[7][mtrcur[7]:length-1] <> -1{
              SET dbgtrk TO dbgtrk+"mtrcur[7] = 3-".
              IF ValRes:istype("Boolean") {SET MidEnd TO ValRes:tostring. SET dbgtrk TO dbgtrk+"Bool-". SET adjmode TO "bool".}
              ELSE{
                IF ValRes:istype("Scalar") AND MtrCur[1]:istype("Scalar"){ SET dbgtrk TO dbgtrk+"Scalar-". SET adjmode TO "num".
                SET dbgtrk TO dbgtrk+"mtrcur[7] = guage-".                  
                  LOCAL pct TO (ValRes/MtrCur[1])*100.
                  IF  mtrcur[0] > 0 SET pct TO (ValRes-mtrcur[0])/(MtrCur[1]-mtrcur[0])*100.
                  SET BOTROW TO " "+fldV+SetGauge(pct,1,widthlim-4-fldV:length-1).//dde
                  SET NoMTR TO FALSE.
                  SET MidEnd TO ROUND(ValRes,RND).
                  IF fldv:contains("%") SET MidEnd TO MidEnd+"%".
                  IF dbglog > dbglvlH {
                    log2file("                    LineOut1a:"+BOTROW).
                    log2file("                    LineOut2a:"+MidEnd).
                  }
                }
              }
            }
            IF NoMTR {
              IF FISAdjBy < 1 {
                SET dbgtrk TO dbgtrk+" < 1-".  SET adjmode TO "name".
                IF FieldList[4]:length > 0 AND mtrcur[7]:length > 0{SET dbgtrk TO dbgtrk+"> than 0-".
                  LOCAL fvl TO mtrcur[7]:find(ValRes:TOSTRING).
                  IF mtrcur[7]:contains(ValRes:tostring){SET dbgtrk TO dbgtrk+"Contains valres:-".
                  IF mtrcur[8]:LENGTH < mtrcur[7]:LENGTH {UNTIL mtrcur[8]:length = mtrcur[7]:LENGTH mtrcur[8]:ADD("").}
                    IF dbglog > DBGLVL {log2file("         SetandReplStr:"+ValRes+"("+fvl+")"). 
                                        log2file("         FieldINName ("+fvl+"):"+LISTTOSTRING(mtrcur[7][fvl])).
                                        log2file("        FieldOUTName ("+fvl+"):"+LISTTOSTRING(mtrcur[8][fvl])).}
                    IF mtrcur[8][fvl] <> "" SET ValRes TO ReplaceWords(ValRes,FieldList[3][MtrCur[5]],FieldList[4][MtrCur[5]]).
                    SET MidEnd TO ValRes.
                  }
                }
              }
            }
            IF  mtrcur[7][mtrcur[7]:length-1] <> -1
            IF dbglog > dbglvlH log2file("                   debugtrack:"+dbgtrk+" NoMtr:"+NoMtr+"  FIELDV:"+fldv+" val:"+MidEnd+" FISAdjBy:"+FISAdjBy).
            SET fldv TO ReplaceWords(fldV). 
            SET HudOpts[1][1] TO fldV+":"+MidEnd.
            IF dbglog > dbglvlH log2file("                    LineTopOut:"+HudOpts[1][1]).
              IF FieldList[5]:length > 1 AND FieldList[5][MtrCur[5]] <> "" {SET HudOpts[1][1] TO HudOpts[1][1]+FieldList[5][MtrCur[5]].}
              ELSE{
              LOCAL hout TO HudOpts[1][1]:split(":").
              IF FindCl3:HASKEY(hout[1]) AND hout[1] <> ""{
                SET hout[1] TO  getcolor(hout[1],FindCl3[hout[1]],2).
                SET HudOpts[1][1] TO hout[0]+":"+hout[1].
                }
              }
              IF dbglog > dbglvlH log2file("                    LineTopOutCLR:"+HudOpts[1][1]).
              BREAK.
          }
        }
      } 
    }
    ELSE {SET dbgtrk TO dbgtrk+"0a". 
      IF FieldList[6][0] <> 0 {SET rws TO 1. SET dbgtrk TO dbgtrk+"0b".}
      LOCAL pout TO FormatFields(prtin,ModIn, MtrList,rws,2,DBGLVL).
      IF REMOVESPECIAL(pout[0]," ") = "" OR NOT pout[0]:contains(":") {
      LOCAL optn TO GrpDspList[itemnum][hsel[2][2]].
        SET pout[0] TO modulelist[2][itemnum][1]+modulelist[2][itemnum][4-optn]. 
        IF FIELDLIST[1]:LENGTH > 0 SET FORCEREFRESH TO 2.
        IF dispinfo > 1 SET newhud TO 2.
        //set pout[1] to modulelist[2][itemnum][1+optn].
        }
      IF FieldList[6][0] <> 0 {
        LOCAL nm TO 0.
        IF  FieldList[6][0]:contains("auto") {
          SET pout[1] TO GetFuelLeft(prtlist[itemnum][hsel[2][2]],6).
          SET nm TO GetFuelLeft(prtlist[itemnum][hsel[2][2]],3).
        }ELSE{
          SET pout[1] TO FieldList[6][0]+GetFuelLeft(prtlist[itemnum][hsel[2][2]],5,widthlim-3-FieldList[6][0]:length).
          SET nm TO  GetFuelLeft(prtlist[itemnum][hsel[2][2]],3).
        }
        IF  FieldList[6][0]:contains("/"){
          LOCAL splt TO FieldList[6][0]:split("/").
          IF nm > 0 SET pout[0] TO splt[2]. ELSE SET pout[0] TO splt[1]. 
        }
      }
            SET HudOpts[1][3] TO "". 
            SET HudOpts[1][2] TO "". 
            SET HudOpts[1][1] TO pout[0].
            SET botrow TO " "+pout[1].
            IF dbglog > DBGLVL{ log2file("                   MLineOut1:"+pout[0]). 
                                log2file("                   MLineOut2:"+pout[1]).}
      }
      IF nomtr = 1 AND rvl = 1 {
        SET dbgtrk TO dbgtrk+"1a".
        SET botrow TO " "+FormatFields(prtin,ModIn, MtrList,1,2,DBGLVL)[0].
        IF dbglog > DBGLVL log2file("                   bRLineOut2:"+botrow).
      }
      IF dbglog > dbglvlH log2file("                    DBGTRK:"+DBGTRK).
      RETURN NoMTR.
  }
   FUNCTION FormatFields{//sets up new text displays
    LOCAL PARAMETER prtin, MdIn, MtrList, rws IS 2,  RND IS -1, DBGLVL IS 1.
    IF FieldList[1]:length = 0 RETURN LIST("","").
    LOCAL dbglvlH TO MIN(DBGLVL+1,2).
    IF NOT MdIn:typename:contains("list") SET MdIn TO LIST(MdIn).
    IF dbglog > DBGLVL log2file("         FormatFieldsIN :"+" RWS:"+rws+" RND:"+rnd+" "+prtin+" Mod:"+LISTTOSTRING(MdIn)).  
    IF MtrList[0][0]:istype("scalar") SET MtrList[0] TO MtrList[0][MtrList[0][0]].
    IF NOT MtrList:typename:contains("list")SET MtrList TO LIST(MtrList).
    IF dbglog > DBGLVL log2file("         FormatFieldsADJ:"+prtin+" Mod:"+LISTTOSTRING(MdIn)).                        
        LOCAL pout TO "".
        LOCAL pout2 TO "".
        LOCAL PrintValOut TO LIST("","","","","","","").
        LOCAL styl TO FieldList[7].   
        LOCAL vn TO FieldList[8].
        LOCAL addedlines TO LIST().
        LOCAL fields TO FieldList[1]:COPY.
        //if dbglog > dbglvlH log2file("          fields:"+LISTTOSTRING(fields)). 
        IF fieldlist:length > 9 AND rowval = 1{
          IF fieldlist[9]:length > 0{
            FOR j IN fieldlist[9]{LOCAL CNTJ TO FIELDLIST[2]:FIND(MeterList[2][itemnumcur][0][J[0]:TONUMBER]).
              IF CNTJ < mtrcur[5]+1 AND CNTJ > -1 {SET fields TO J:COPY.}}
          }
        }
        IF fieldlist:length > 10 AND rowval = 0{
          LOCAL xt TO 0.
          IF fieldlist[10]:length > 0{
            FOR j IN fieldlist[10]{
              IF j[0]:contains("STATE-") {
                  LOCAL ste TO j[0]:split("-"). 
                  IF dbglog > dbglvlH log2file("          ste:"+LISTTOSTRING(ste)).
                  FOR k IN ste:sublist(1,ste:length-1){IF FlState = k {SET fields TO j:sublist(1,j:length-1):COPY. SET xt TO 1. BREAK.}}
              }IF xt = 1 BREAK.
            }
          }
        }
        //if dbglog > dbglvlH log2file("          fields2:"+LISTTOSTRING(fields)). 
        LOCAL FIELDS2 TO FIELDS:COPY.
        FOR Md IN mdin{
          IF dbglog > dbglvlH log2file("          MOD:"+LISTTOSTRING(md)). 
          IF prtin:HASMODULE(md){
            FOR i IN range(0,fields2:length+1) {
              PrintValOut:ADD("").
              LOCAL FFAns TO "".
              IF i < fields2:length {SET FFAns TO getEvAct(prtin,md,fields2[i]:tostring:REPLACE("\","/"),30,RND,dbglvlH).}
                //if dbglog > dbglvlH log2file("          fields("+i+"):"+fields2[i]+" FFAns:"+FFAns).} 

              IF REMOVESPECIAL(FFAns," ") <> ""{
                IF FFAns:istype("scalar"){IF abs(FFAns) > 10 SET FFAns TO ROUND(FFAns,0).}.
                LOCAL tmp TO fields2[i]:tostring:REPLACE("\","/").
                //if dbglog > dbglvlH log2file("          tmp:"+tmp). 
                IF FieldList[4]:length > 0 AND FieldList[2]:length > 0{
                  IF FieldList[2]:contains(tmp:TOSTRING){
                    LOCAL fvl TO FieldList[2]:find(tmp:TOSTRING).
                    IF dbglog > dbglvlH {log2file("           FieldINNames("+fvl+"):"+LISTTOSTRING(FieldList[3][fvl])). 
                                        log2file("          FieldOUTNames("+fvl+"):"+LISTTOSTRING(FieldList[4][fvl])).}
                    IF FieldList[4][fvl] <> "" SET FFAns TO ReplaceWords(FFAns,FieldList[3][fvl],FieldList[4][fvl]).
                  }
                }
                
                IF NOT addedlines:contains(tmp:tostring){
                  FIELDS:REMOVE(FIELDS:FIND(fields2[i]:tostring)).
                  addedlines:ADD(tmp).
                  SET PrintValOut[i] TO tmp+":"+FFAns.
                  IF FFAns = "NA" OR FFAns = "N/A" {SET PrintValOut[i] TO "".}
                  //if dbglog > dbglvlH log2file("          PrintValOut("+i+"):"+PrintValOut[i]). 
                }
              }
            }
          }
        }
            FOR i IN range (PrintValOut:length-1,0) IF PrintValOut[i] = "" PrintValOut:REMOVE(i).
            IF PrintValOut[0] = "" PrintValOut:REMOVE(0).
            IF PrintValOut:contains("") PrintValOut:REMOVE(PrintValOut:find("")).
            IF dbglog > dbglvlH log2file("          PrintValOut:"+LISTTOSTRING(PrintValOut)).
            LOCAL lngth TO 0.
            LOCAL brk TO MIN(PrintValOut:length,3).
            LOCAL brkadd TO 0.
            IF rws = 1 SET brk TO PrintValOut:length. 
            IF brk > 2 {
              FOR ln IN range(0,PrintValOut:length){
                SET lngth TO PrintValOut[ln]:length.
                IF lngth > widthlim-5 {SET brk TO ln. BREAK.}
              }
            }
            IF rws > 1{
              IF PrintValOut:length > 4 SET brk TO 3. ELSE
              IF PrintValOut:length = 4 SET brk TO 2. 
              IF PrintValOut:length > 4 {
                LOCAL lng TO widthlim.
                FOR i IN PrintValOut:sublist(brk-1,PrintValOut:length-1) SET lng TO -i:length.
                IF lng > 7 SET brk TO brk-1.
              }ELSE
              IF PrintValOut:length > 1 AND PrintValOut:length < 4 SET brk TO 1.
            }
            LOCAL polngth TO LIST(PrintValOut:length-brk,PrintValOut:length-(PrintValOut:length-brk)).
            FOR i IN range (0,PrintValOut:length){
              LOCAL hout TO PrintValOut[i]:split(":").
              GLOBAL tsth TO hout:COPY.
              LOCAL mdl TO ":".
              IF hout[0] <> "" {
                LOCAL h0Raw TO hout[0].
                SET hout[0] TO ReplaceWords(hout[0]).
                LOCAL fnd TO fieldlist[1]:find(h0Raw).
                IF fnd > -1 {
                  IF fieldList[7][0] <> 0 {
                    IF styl:length > 1 IF styl[fnd] <> "" {
                      IF styl[fnd]:contains("M-") OR styl[fnd]:contains("Mn-") OR styl[fnd]:contains("Mp-"){
                        LOCAL lms TO styl[fnd]:split("-").
                        LOCAL liml TO lms[1].
                        LOCAL limh TO lms[2].
                        LOCAL tmp1 TO "".
                        LOCAL ANS1 TO  hout[1].
                        IF ans1:contains("K /") {
                          SET tmp1 TO ans1:split("/").
                          SET ans1 TO tmp1[0].
                          SET limh TO ROUND(RemoveLetters(RemoveLetters(tmp1[1]),"/ "):tonumber,0).
                          SET liml TO 0.
                        }
                        SET ANS1 TO  RemoveLetters(RemoveLetters(ANS1),"/ ").
                        IF ans1:length > 9 SET ans1 TO ans1:substring(0,9).
                        IF ans1 <> "" {
                          IF NOT ans1:istype("string") SET ans1 TO ans1:tostring.
                          IF ans1:contains("."){
                            LOCAL ddd TO ans1:split(".").
                            IF ddd[1]:length < 3{SET ans1 TO ROUND(ans1:tonumber,0).}ELSE{SET ans1 TO removeletters(ans1,".").}}
                          SET ans1 TO BoolNum(ans1,1).
                          SET liml TO BoolNum(liml,1).
                          SET limh TO BoolNum(limh,1).
                          IF liml+limh = 0 {
                            LOCAL aaa TO "".
                            FOR mdls IN MtrSpecList {LOCAL bbb TO getEvAct(prtin,mdls,h0Raw,30). IF bbb <> FALSE AND bbb <> "" {SET aaa TO bbb. BREAK.}}
                            IF AAA <> "" {
                              SET aaa TO removeletters(aaa).
                              SET aaa TO aaa:split("/").
                              SET liml TO 0.
                              SET ans1 TO aaa[0]:tonumber.
                              SET limh  TO aaa[1]:tonumber.
                            }
                          }
                          LOCAL pct TO ans1/limh*100.
                          IF  liml > 0 SET pct TO ((ans1-liml)/(limh-liml)*100).
                          LOCAL submore TO 0.
                          IF PrintValOut:length = 5 AND BRK = 2 SET BRKADD TO 1.
                          //if i > 0 and brk = 1 set brkadd to PrintValOut):length/4. 
                          LOCAL lnlngth TO polngth[0].
                          IF i > brk SET lnlngth TO polngth[1].
                          //if PrintValOut:length-1 > i+1 and PrintValOut:length > 3 set lnlngth to 2.
                          IF lnlngth > 1 {
                            IF PrintValOut:length-1 > i SET submore TO PrintValOut[i+1]:length.
                            IF PrintValOut:length-1 > i+1  SET submore TO submore+PrintValOut[i+2]:length.
                            IF PrintValOut:length-1 > i+1 SET submore TO submore+PrintValOut[i+2]:length.
                          }
                          IF styl[fnd]:contains("Mp-") SET hout[0] TO hout[0]+"("+ROUND(PCT,0)+"%)".
                          IF styl[fnd]:contains("Mn-") SET hout[0] TO HOUT[0]+"("+ans1+")".
                          LOCAL gl TO (widthlim/(MAX(1,lnlngth)))-hout[0]:length.
                          IF gl+hout[0]:length > widthlim-5 SET gl TO (widthlim/(MAX(1,lnlngth)))-hout[0]:length-5.
                          IF colorprint = 1 AND lnlngth = 1 SET hout[1] TO GETCOLOR(SetGauge(pct, 1, gl-4),mtrcolor(pct)).
                          ELSE SET hout[1] TO SetGauge(pct, 1, gl).//finish meter fix
                          IF hout[1]:contains(":") OR  hout[0]:contains(":") SET mdL TO "".
                        }
                      }
                    }
                  }
                }
                SET hout[1] TO ReplaceWords(hout[1]).
                IF rws > 1 AND brk < 2 AND i < 1{IF FindCl3:HASKEY(hout[1]){SET hout[1] TO getcolor(hout[1],FindCl3[hout[1]],2).}}
                IF VN:length > 1 AND fnd > -1 IF vn[fnd] <> "" SET hout[1] TO hout[1]+vn[fnd].
                SET PrintValOut[i] TO hout[0]+mdl+hout[1].
              }
            }
            LOCAL Pbrk TO brk+brkadd.
            IF PrintValOut:length > 6 SET PrintValOut TO PrintValOut:sublist(0,6).
            UNTIL PrintValOut:length > brk+2 PrintValOut:ADD("").
            GLOBAL tstbrk TO brk.
            GLOBAL tstpo TO PrintValOut.
            LOCAL addxtra TO 0.
            IF brk = 2 OR lngth < widthlim*0.8 SET addxtra TO 2.
            LOCAL l3max TO 0.
            LOCAL l1max TO                  MAX(PrintValOut[0]:length+1,PrintValOut[brk]:length+2+addxtra).
            LOCAL l2max TO                  MAX(PrintValOut[1]:length+1,PrintValOut[brk+1]:length+2+addxtra).
                  IF Pbrk > 2  SET l3max TO MAX(PrintValOut[2]:length+1,PrintValOut[brk+2]:length+2+addxtra).
            LOCAL inb TO MAX(0,(widthlim-2-l1max-l2max-l3max)/MAX(brk-1,1)). 
            IF (l1max+inb+l2max+inb+l3max) < widthlim-3 {UNTIL (l1max+inb+l2max+inb+l3max) > WIDTHLIM-4 SET INB TO INB+1.}
            LOCAL inb2 TO inb.
            //if brk > 2 {LOCAL INB2 TO INB+(l2max/2). SET INB TO INB-(l2max/2).}
            SET pout  TO PrintValOut[0]:padright(l1max+inb).
            IF brk >1 SET pout TO pout+PrintValOut[1]:padright(l2max+INB2).
            IF brk >2 SET pout TO pout+PrintValOut[2].
            SET pout2 TO PrintValOut[brk]:padright(MAX(0,l1max+inb))+PrintValOut[brk+1]:padright(MAX(0,l2max+INB2))+PrintValOut[brk+2].
            IF dbglog > DBGLVL{ log2file("                   LineOut1:"+pout). 
                                log2file("                   LineOut2:"+pout2). 
                                log2file("                   List:"+LISTTOSTRING(PrintValOut)).
                                log2file("                    BRK:"+brk).}
        RETURN LIST(pout, pout2).
  }
   FUNCTION SplitDisplayList{//split list to usable format
    LOCAL PARAMETER  MdInDl, MtrList, OPT IS 0, DBGLVL IS 1. //MeterList[1][itemnumcur], MeterList[2][itemnumcur]
    IF dbglog > DBGLVL log2file("     SplitDisplayList ModIn:"+LISTTOSTRING(MdInDl)). 
    LOCAL PrintFieldVals TO LIST().
    LOCAL FieldReplaceNames TO LIST().
    LOCAL FieldGoodNames TO LIST().
    LOCAL ValueNames   TO LIST().
    LOCAL FieldAllVals   TO LIST().
    LOCAL GetFuel   TO LIST(0).
    LOCAL SetStyle  TO LIST(0).
    LOCAL MValueNames  TO LIST().
    LOCAL BotRowNames TO LIST().
    LOCAL ALTRowNames TO LIST().
    SET MeterList[0][1] TO LIST().
    SET MeterList[0][2] TO LIST().
        IF MtrList:length > 0 {
          FOR i IN range (0,MtrList:length+1){IF i = MtrList:length BREAK.
            meterlist[0][2]:ADD(MtrList[i]:COPY).
          }
          SET MtrList TO meterlist[0][2]:COPY.
        }
    IF meterlist[0][2]:typename:contains("list"){
      IF meterlist[0][2]:length > 1 SET FieldReplaceNames TO meterlist[0][2][1].
      IF meterlist[0][2][0]:typename:contains("list") {
        IF meterlist[0][2][0][0] <> "" SET MdInDl TO splitlist(meterlist[0][2][0][0]).
        IF meterlist[0][2][1][0] <> "" {
          IF dbglog > DBGLVL log2file("         meterlist[0][2][1]:"+LISTTOSTRING(meterlist[0][2][1])). 
          SET PrintFieldVals TO meterlist[0][2][1][0]:split("/").
        }
        IF OPT = 1 AND MtrOps[hsel[2][1]][0] = 0{
          SET mdindl TO TrimModules2(mdindl).
          IF MeterList[0][2][0]:length > 1{
            SET MeterList[0][2] TO trimfields(MeterList[0][2]:COPY, MdInDl).
          }
        }
        SET MtrCur[4] TO MeterList[0][2][1]:length-1.
        SET MtrCur[3] TO 1.
        IF MtrCur[5] < MtrCur[3] SET MtrCur[5] TO MtrCur[3].
        IF MtrCur[5] > MtrCur[4] SET MtrCur[5] TO MtrCur[4].
        IF meterlist[0][2]:length > 2 {
          LOCAL cnt2 TO 0.
          FOR i IN range (2,meterlist[0][2]:length+1){IF i = meterlist[0][2]:length BREAK.
            IF dbglog > DBGLVL log2file("         meterlist[0][2]["+i+"]:"+LISTTOSTRING(meterlist[0][2][i])). 
            IF meterlist[0][2][i][0] <> "" AND i > 1{
              IF meterlist[0][2][i][0] = "Names"SET FieldGoodNames TO meterlist[0][2][i]:COPY.
              IF meterlist[0][2][i][0]:contains("Values"){
                SET ValueNames TO meterlist[0][2][i]:COPY.
                LOCAL vn TO ValueNames.
                IF meterlist[0][2][i]:length > 0 {SET vn TO splitlist(meterlist[0][2][i][0]).
                  //if meterlist[0][2][i][0]:contains("/") SET vn TO meterlist[0][2][i][0]:split("/"). 
                  FOR k IN range (0,vn:length){SET vn[k] TO REMOVESPECIAL(VN[K]:TOSTRING:REPLACE("\","/")," ").}
                  SET VN TO VN:SUBLIST(1,VN:LENGTH).
                  IF vn:length < PrintFieldVals:length {UNTIL vn:length > PrintFieldVals:length-1 vn:ADD("").}
                  SET MValueNames TO vn.
                }
              }
              IF meterlist[0][2][i][0]:contains("BotRow"){
                LOCAL Pfv TO meterlist[0][2][i][0]:split("/").
                LOCAL brv TO pfv[0]:REPLACE("botrow",""). 
                IF brv = "" SET brv TO "0". 
                SET pfv[0] TO brv:tostring.
                BotRowNames:ADD(Pfv).
                SET cnt2 TO cnt2+1.
              }
              IF meterlist[0][2][i][0]:contains("Style")  {
                SET SetStyle TO meterlist[0][2][i][0]:split("/"). 
                SET SetStyle TO SetStyle:sublist(1,SetStyle:length-1).
                    FOR k IN range (0,SetStyle:length){SET SetStyle[k] TO REMOVESPECIAL(SetStyle[K]:TOSTRING:REPLACE("\","/")," ").}
              }
              ELSE
              IF meterlist[0][2][i][0]:contains("Fuelleft") SET getfuel TO LIST(meterlist[0][2][i][1]).
              ELSE
              IF meterlist[0][2][i][0]:contains("AltVal") {
                LOCAL splt TO meterlist[0][2][i][0]:split("/").
                IF ALTVAL = splt[1]:tonumber {SET FieldReplaceNames TO meterlist[0][2][i].}
              }ELSE
              IF meterlist[0][2][i][0]:contains("STATE-")  ALTRowNames:ADD(meterlist[0][2][i][0]:split("/")).
            }
          }
        }
        SET FieldAllVals TO meterlist[0][2][0]:COPY. //MeterList[2][itemnumcur][0]  
        IF dbglog > DBGLVL log2file("         meterlist[0][2][0]:"+LISTTOSTRING(meterlist[0][2][0])).
        IF meterlist[0][2][0][0] <> "" {SET MdInDl TO LIST(meterlist[0][2][0][0]).}
        IF meterlist[0][2][1][0] <> "" {
          IF dbglog > DBGLVL log2file("         meterlist[0][2][1]:"+LISTTOSTRING(meterlist[0][2][1])). 
          SET PrintFieldVals TO meterlist[0][2][1][0]:split("/").
        }
      }
    }ELSE{SET meterlist[0][2] TO LIST(meterlist[0][2]).}
    LOCAL TMPTRM TO LIST(PrintFieldVals:COPY).
    LOCAL L2 TO 0.  LOCAL SS TO 0. LOCAL VNM TO 0.
    IF NOT SetStyle[0]:typename:contains("SCALAR") {TMPTRM:ADD(SetStyle). SET L2 TO L2+1. SET SS TO L2.}
    IF MValueNames:LENGTH > 0 {TMPTRM:ADD(MValueNames). SET L2 TO L2+1. SET VNM TO L2.}
    //IF TMPTRM:LENGTH > 1 {
      SET TMPTRM TO trimfields(TMPTRM, MdInDl,-1).
      
    //}
    //ELSE set TMPTRM to LIST(trimfields(PrintFieldVals, MdInDl,hsel[2][1],hsel[2][2],BotRowNames:copy)).
    SET PrintFieldVals TO TMPTRM[0].
    IF SS > 0 SET SetStyle TO TMPTRM[SS].
    IF VNM > 0 SET MValueNames TO TMPTRM[VNM].
    IF dbglog > DBGLVL {log2file("            PrintFieldVals:"+LISTTOSTRING(PrintFieldVals)). 
                        log2file("            FieldAllVals:"+LISTTOSTRING(FieldAllVals)).
                        log2file("            FieldReplaceNames:"+LISTTOSTRING(FieldReplaceNames)).
                        log2file("            FieldGoodNames:"+LISTTOSTRING(FieldGoodNames)).
                        log2file("            ValueNames:"+LISTTOSTRING(ValueNames)).
                        log2file("            MValueNames:"+LISTTOSTRING(MValueNames)).
                        log2file("            getfuel:"+LISTTOSTRING(getfuel)).
                        log2file("            SetStyle:"+LISTTOSTRING(SetStyle)).
                        }
    IF NOT meterlist[0][2][0]:typename:contains("list") {SET PrintFieldVals TO splitlist(meterlist[0][2][0]).
      //if meterlist[0][2][0]:contains("/")  SET PrintFieldVals TO meterlist[0][2][0]:split("/").
    }
    //if PrintFieldVals:length = 0 set PrintFieldVals to meterlist[0][2].
    SET REMETER TO 0.
    RETURN LIST(mdinDl, PrintFieldVals:COPY,FieldAllVals:COPY,FieldReplaceNames:COPY,FieldGoodNames:COPY,ValueNames:COPY,Getfuel:COPY,SetStyle:COPY,MValueNames:COPY, BotRowNames:COPY,ALTRowNames:COPY).
  }
   FUNCTION QuickField{//old method for fallover
    LOCAL PARAMETER pt IS p, hdi IS hsel[2][1], mx IS 4, mn IS 1.
    IF dbglog > 1 log2file("         QuickField:"+pt+"("+hdi+")").
    IF MeterList[0][2] <> 0 {
      multimeter().
    }
    ELSE{
      SET mx TO mx*3-2.
      SET mn TO mn*3-2.
      LOCAL lo1 TO LIST().
      LOCAL lo2 TO LIST().
      FOR i IN range(1,13,3){
        IF i > mn-1 AND i < mx+1 {
          lo1:ADD(modulelist[0][hdi][i]).
          lo1:ADD(modulelist[1][hdi][i]).                    
          lo2:ADD(modulelist[2][hdi][i]).
        }
      }
      SET hudopts[1][1] TO FormatFields(pt,lo1,lo2,1,0)[0].
    }
  }
   FUNCTION CycleAjdBy{//change amount to adjust by
    LOCAL adjL TO LIST(1,5,10,25,50,100,1000).
    IF dbglog > 2 log2file("       CycleAdjBy:").
    IF mtrcur[7][0]:TOSTRING:CONTAINS(".") {
      LOCAL AA TO mtrcur[7][0]:TOSTRING:split(".").
      LOCAL bb TO AA[1]:LENGTH.
      IF bb= 1 SET adjL TO LIST(0.1,0.25,0.5,1,5,10,25).
      IF bb= 2 SET adjL TO LIST(0.01,0.05,0.1,0.5,1,5,10,25).
    }
    LOCAL crnt TO mtrcur[2].
    IF adjL:contains(crnt){
      SET cr TO  adjL:find(crnt).
      IF cr < adjL:length-1 SET cr TO cr+1. ELSE SET cr TO 0.
      SET crnt TO adjL[cr].
        IF mtrcur[1] < crnt+.0001 SET crnt TO adjL[0].
        IF dbglog > 2 log2file("              SET "+mtrcur[2]+" TO:"+crnt).
        SET mtrcur[2] TO crnt.
    }
  }
   //#region MKS
   FUNCTION MKSConvCheck{
    LOCAL PARAMETER fl,J,huditem, hudtag.
    LOCAL err1 TO "". LOCAL err2 TO "".
      IF fl = "reactor"{ 
          IF SHIP:RESOURCES[RscNum["EnrichedUranium"]]:CAPACITY = 0 SET err1 TO ": No Enriched Uranium Storage". ELSE IF SHIP:RESOURCES[RscNum["EnrichedUranium"]]:AMOUNT < 0.01 SET err1 TO ": No Enriched Uranium".
          IF SHIP:RESOURCES[RscNum["DepletedFuel"]]:CAPACITY = 0 SET err2 TO ": No Depleted Fuel Storage". ELSE IF SHIP:RESOURCES[RscNum["DepletedFuel"]]:AMOUNT > SHIP:RESOURCES[RscNum["DepletedFuel"]]:CAPACITY-0.5 SET err2 TO ": Depleted Fuel Full". 
          IF err1+err2 = "" {
              SET hudopts[J][2] TO hudopts[J][3]+":Enriched Uranium".
              SET hudopts[J][3] TO SetGauge(SHIP:RESOURCES[RscNum["EnrichedUranium"]]:AMOUNT/SHIP:RESOURCES[RscNum["EnrichedUranium"]]:CAPACITY*100,J).
          }ELSE{
              SET hudopts[J][3] TO err1+err2. 
              SET GrpDspList[HudItem][hudtag] TO 1. SET forcerefresh TO 1.
          }
      }ELSE{   
        IF fl = "agroponics" OR fl = "[greenhouse]" { ResourceCheck(j, huditem, hudtag, "Mulch", "", "Fertilizer", "", ""). }ELSE{                                                       
        IF fl = "chemicals"                  { ResourceCheck(j, huditem, hudtag,"Minerals"        , ""                , ""           , ""                  , "Chemicals"        ). }ELSE{
        IF fl = "[smelter]"                  { ResourceCheck(j, huditem, hudtag,"Machinery"       , ""                , ""           , ""                  , ""                 ). }ELSE{
        IF fl = "[crushser]"                 { ResourceCheck(j, huditem, hudtag,"Machinery"       , ""                , ""           , ""                  , ""                 ). }ELSE{
        IF fl = "Sifter"                     { ResourceCheck(j, huditem, hudtag,"Dirt"            , ""                , ""           , ""                  , "Machinery"        ). }ELSE{
        IF fl = "Silicon"                    { ResourceCheck(j, huditem, hudtag,"Silicates"       , "Machinery"       , ""           , ""                  , "Silicon"          ). }ELSE{
        IF fl = "Polymers"                   { ResourceCheck(j, huditem, hudtag,"Substrate"       , ""                , ""           , ""                  , "Polymers"         ). }ELSE{
        IF fl = "RefinedExotics"             { ResourceCheck(j, huditem, hudtag,"ExoticMinerals"  , "RareMetals"      , "Chemicals"  , ""                  , "RefinedExotics"   ). }ELSE{
        IF fl = "h2o (Hyd)"                  { ResourceCheck(j, huditem, hudtag,"Hydrates"        , ""                , ""           , ""                  , "Water"            ). }ELSE{
        IF fl = "h2o (Kar)"                  { ResourceCheck(j, huditem, hudtag,"Karbonite"       , ""                , ""           , ""                  , "Water"            ). }ELSE{
        IF fl = "h2o (Ore)"                  { ResourceCheck(j, huditem, hudtag,"Ore"             , ""                , ""           , ""                  , "Water"            ). }ELSE{
        IF fl = "Chemicals"                  { ResourceCheck(j, huditem, hudtag,"Minerals"        , ""                , ""           , ""                  , "Chemicals"        ). }ELSE{
        IF fl = "Fertilizer(G)"              { ResourceCheck(j, huditem, hudtag,"Gypsum"          , ""                , ""           , ""                  , "Fertilizer"       ). }ELSE{
        IF fl = "Fertilizer(M)"              { ResourceCheck(j, huditem, hudtag,"Minerals"        , ""                , ""           , ""                  , "Fertilizer"       ). }ELSE{
        IF fl = "Metals"                     { ResourceCheck(j, huditem, hudtag,"MetallicOre"     , ""                , ""           , ""                  , "Metals"           ). }ELSE{
        IF fl = "LFO"                        { ResourceCheck(j, huditem, hudtag,"Ore"             , ""                , ""           , ""                  , "LiquidFuel"       , "Oxidizer"). }ELSE{//not sure always full
        IF fl = "LiquidFuel"                 { ResourceCheck(j, huditem, hudtag,"Ore"             , ""                , ""           , ""                  , "LiquidFuel"       ). }ELSE{//not sure always full
        IF fl = "Monopropellant"             { ResourceCheck(j, huditem, hudtag,"Ore"             , ""                , ""           , ""                  , "Monopropellant"   ). }ELSE{
        IF fl = "Recycling"                  { ResourceCheck(j, huditem, hudtag,"Recyclables"     , ""                , ""           , ""                  , "Metals"           ,"Chemicals", "Polymers"). }ELSE{
        IF fl = "RocketParts"                { ResourceCheck(j, huditem, hudtag,"SpecializedParts", "MaterialKits"    , ""           , ""                  , "RocketParts"      ). }ELSE{
        IF fl = "DepletedFuel"               { ResourceCheck(j, huditem, hudtag,"DepletedFuel"    , ""                , ""           , ""                  , "EnrichedUranium"  ). }ELSE{
        IF fl = "SpecializedParts"           { ResourceCheck(j, huditem, hudtag,"RefinedExotics"  , ""                , "Silicon"    , ""                  , "SpecializedParts" ). }ELSE{
        IF fl = "MaterialKits"               { ResourceCheck(j, huditem, hudtag,"Metals"          , "Polymers"        , "Chemicals"  , ""                  , "MaterialKits"     ). }ELSE{
        IF fl = "agriculture(s)"             { ResourceCheck(j, huditem, hudtag,"Substrate"       , "Water"           , "Fertilizer" , "Organics"          , ""                 ). }ELSE{
        IF fl = "agriculture(d)"             { ResourceCheck(j, huditem, hudtag,"Dirt"            , "Water"           , "Organics"   , "Fertilizer"        , ""                 ). }ELSE{
        IF fl = "ColonySupplies"             { ResourceCheck(j, huditem, hudtag,"Organics"        , "SpecializedParts", "MaterialKits", ""                 , "ColonySupplies"   ). }ELSE{
        IF fl = "Machinery"                  { ResourceCheck(j, huditem, hudtag,"SpecializedParts", ""                , "MaterialKits", ""                 , "Machinery"        ). }ELSE{
        IF fl = "EnrichedUranium"            { ResourceCheck(j, huditem, hudtag,"Uraninite"       , ""                , ""           , ""                  , "EnrichedUranium"  ). }ELSE{
        IF fl = "Deuterium"                  { ResourceCheck(j, huditem, hudtag,"Deuterium"       , "Helium3"         , ""           , ""                  , "D2"               ). }ELSE{
        IF fl = "FusionPellets"              { ResourceCheck(j, huditem, hudtag,"FusionPellets"   , ""                , "Helium3"    , ""                  , ""                 ). }ELSE{
        IF fl = "Silicates"                  { ResourceCheck(j, huditem, hudtag,"Silicates"       , ""                , ""           , ""                  , "Silicates"        ). }ELSE{
        IF fl = "Minerals"                   { ResourceCheck(j, huditem, hudtag,""                , ""                , ""           , ""                  , "Minerals"         ). }ELSE{
        IF fl = "MetallicOre"                { ResourceCheck(j, huditem, hudtag,""                , ""                , ""           , ""                  , "MetallicOre"      ). }ELSE{
        IF fl = "cultivate(s)"               { ResourceCheck(j, huditem, hudtag,"Substrate"       , "Water"           , "Fertilizer" , ""                  , ""                 ). }ELSE{
        IF fl = "cultivate(d)"               { ResourceCheck(j, huditem, hudtag,"Dirt"            , "Water"           , "Fertilizer" , ""                  , ""                 ). }ELSE{
        IF fl = "centrifuge"                 { ResourceCheck(j, huditem, hudtag,"Uraninite"       , ""                , ""           , ""                  , "EnrichedUranium"  ). }ELSE{
        IF fl = "breeder"                    { ResourceCheck(j, huditem, hudtag,"depletedfuel"    , ""                , ""           , ""                  , "EnrichedUranium"  ). }ELSE{
        IF fl = "electronics"                { ResourceCheck(j, huditem, hudtag,"MaterialKits"    , "Synthetics"      , ""           , ""                  , "electronics"      ). }ELSE{
        IF fl = "Alloys"                     { ResourceCheck(j, huditem, hudtag,"Metals"          , "RareMetals"      , ""           , ""                  , "Alloys"           ). }ELSE{
        IF fl = "Prototypes"                 { ResourceCheck(j, huditem, hudtag,"Electronics"     , "Robotics"        , "Machinery"  , "SpecializedParts"  , ""                 ). }ELSE{
        IF fl = "Robotics"                   { ResourceCheck(j, huditem, hudtag,"Alloys"          , "MaterialKits"    , "Machinery"  , ""                  , "Robotics"         ). }ELSE{      
        IF fl = "Synthetics"                 { ResourceCheck(j, huditem, hudtag,"Machinery"       , "ExoticMinerals"  , "Polymers"   , ""                  , "Synthetics"       ). }ELSE{     
        IF fl = "Dirt"                       { ResourceCheck(j, huditem, hudtag,""                , ""                , ""           , ""                  , "Dirt"       ). }ELSE{  
        IF fl = "transportCredits"           { ResourceCheck(j, huditem, hudtag,"MaterialKits"    , "liquidfuel"      , ""           , ""                  , "transportCredits"). }ELSE{  
        //if fl = "Lodeharvester"            { ResourceCheck(j, huditem, hudtag,""                , ""                , ""           , ""                  , "ResourceNode"  ). }ELSE{



          
        }}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}
  }
   FUNCTION MKSDrillCheck{
      LOCAL PARAMETER fl,j,huditem, hudtag.
        IF fl = "Dirt"                      { ResourceCheck(j, huditem, hudtag, ""       , ""                , ""           , ""                  , "Dirt"             ). }ELSE{//working      
        IF fl = "Minerals"                  { ResourceCheck(j, huditem, hudtag, ""       , ""                , ""           , ""                  , "Minerals"         ). }ELSE{
        IF fl = "Silicates"                 { ResourceCheck(j, huditem, hudtag, ""       , ""                , ""           , ""                  , "Silicates"        ). }ELSE{
        IF fl = "Ore"                       { ResourceCheck(j, huditem, hudtag, ""       , ""                , ""           , ""                  , "Ore"              ). }ELSE{
        IF fl = "Exotic Minerals"           { ResourceCheck(j, huditem, hudtag, ""       , ""                , ""           , ""                  , "ExoticMinerals"   ). }ELSE{
        IF fl = "Karbonite"                 { ResourceCheck(j, huditem, hudtag, ""       , ""                , ""           , ""                  , "Karbonite"        ). }ELSE{
        IF fl = "Uraninite"                 { ResourceCheck(j, huditem, hudtag, ""       , ""                , ""           , ""                  , "Uraninite"        ). }ELSE{
        IF fl = "Gypsum"                    { ResourceCheck(j, huditem, hudtag, ""       , ""                , ""           , ""                  , "Gypsum"           ). }ELSE{
        IF fl = "Substrate"                 { ResourceCheck(j, huditem, hudtag, ""       , ""                , ""           , ""                  , "Substrate"        ). }ELSE{
        IF fl = "MetallicOre"               { ResourceCheck(j, huditem, hudtag, ""       , ""                , ""           , ""                  , "MetallicOre"      ). }ELSE{
        IF fl = "Water"                     { ResourceCheck(j, huditem, hudtag, ""       , ""                , ""           , ""                  , "Water"            ). }ELSE{
        IF fl = "Hydrates"                  { ResourceCheck(j, huditem, hudtag, ""       , ""                , ""           , ""                  , "Hydrates"         ). }ELSE{
        IF fl = "Uraninite"                 { ResourceCheck(j, huditem, hudtag, ""       , ""                , ""           , ""                  , "Uraninite"        ). }ELSE{
        IF fl = "RareMetals"                { ResourceCheck(j, huditem, hudtag, ""       , ""                , ""           , ""                  , "RareMetals"       ). }ELSE{
        IF fl = "Rock"                      { ResourceCheck(j, huditem, hudtag, ""       , ""                , ""           , ""                  , "Rock"             ). }ELSE{
        }}}}}}}}}}}}}}}
   
  }
   FUNCTION ResourceCheck {
      LOCAL PARAMETER j, huditem, hudtag, RsIn1, RsIn2, RsIn3, RsIn4 IS "", RsOt1 IS "", RsOt2 IS "", RsOt3 IS "".
      LOCAL err1 TO "". LOCAL err2 TO "". LOCAL err3 TO "". LOCAL err4 TO "". LOCAL GgL TO 0. LOCAL ggl2 TO 0.
      LOCAL p1 TO 0. LOCAL p2 TO 0. LOCAL p3 TO 0. LOCAL p4 TO 0. LOCAL P5 TO 0. LOCAL p6 TO 0. LOCAL p7 TO 0.
      IF RsIn1 <> ""{SET p1 TO 1. 
        IF RscNum:HASKEY(RsIn1){
          SET ggl TO ggl+ RscList[RscNum[RsIn1]][1]:length+1.
          IF SHIP:RESOURCES[RscNum[RsIn1]]:CAPACITY = 0 SET err1 TO ": No " +RscList[RscNum[RsIn1]][1] + " Storage". 
          ELSE IF SHIP:RESOURCES[RscNum[RsIn1]]:AMOUNT < 0.01 SET err1 TO ": No " +RscList[RscNum[RsIn1]][1].
        }ELSE{SET err1 TO ": No " +RsIn1+ " Storage".} 
      }
      IF RsIn2 <> ""{SET p2 TO 1. 
        IF RscNum:HASKEY(RsIn2){
          SET ggl TO ggl+RscList[RscNum[RsIn2]][1]:length+2.
          IF SHIP:RESOURCES[RscNum[RsIn2]]:CAPACITY = 0 SET err2 TO ": No " +RscList[RscNum[RsIn2]][1] + " Storage". 
          ELSE IF SHIP:RESOURCES[RscNum[RsIn2]]:AMOUNT < 0.01 SET err2 TO ": No " +RscList[RscNum[RsIn2]][1].
        }ELSE{SET err2 TO ": No " +RsIn2+ " Storage". }
      }
      IF RsIn3 <> ""{SET p3 TO 1. SET p6 TO 1.
        IF RscNum:HASKEY(RsIn3){
          SET ggl2 TO ggl2+RscList[RscNum[RsIn3]][1]:length.
          IF SHIP:RESOURCES[RscNum[RsIn3]]:CAPACITY = 0 SET err3 TO ": No " +RscList[RscNum[RsIn3]][1] + " Storage". 
          ELSE IF SHIP:RESOURCES[RscNum[RsIn3]]:AMOUNT < 0.01 SET err3 TO ": No " +RscList[RscNum[RsIn3]][1].
        }ELSE{SET err3 TO ": No " +RsIn3+ " Storage". }
      }
      IF RsIn4 <> ""{SET p4 TO 1. 
        IF RscNum:HASKEY(RsIn4){
          SET ggl2 TO ggl2+RscList[RscNum[RsIn4]][1]:length+1.
          IF SHIP:RESOURCES[RscNum[RsIn4]]:CAPACITY = 0 SET err4 TO ": No " +RscList[RscNum[RsIn4]][1] + " Storage". 
          ELSE IF SHIP:RESOURCES[RscNum[RsIn4]]:AMOUNT < 0.01 SET err4 TO ": No " +RscList[RscNum[RsIn4]][1].
        }ELSE{SET err4 TO ": No " +RsIn4+ " Storage". }
      }
      IF RsOt1 <> ""{SET p4 TO 1. SET P5 TO 1. 
        IF RscNum:HASKEY(RsOt1){
          SET ggl2 TO ggl2+RscList[RscNum[RsOt1]][1]:length+1.
          IF SHIP:RESOURCES[RscNum[RsOt1]]:CAPACITY = 0 SET err4 TO ": No " +RscList[RscNum[RsOt1]][1] + " Storage". 
          ELSE IF SHIP:RESOURCES[RscNum[RsOt1]]:AMOUNT > SHIP:RESOURCES[RscNum[RsOt1]]:CAPACITY-0.5 SET err4 TO ": "+RscList[RscNum[RsOt1]][1]+" Full".
        }ELSE{SET err4 TO ": No " +RsOt1+ " Storage". }
      }
      IF RsOt2 <> ""{SET p6 TO 1. SET P4 TO 1. SET p5 TO 2. 
        IF RscNum:HASKEY(RsOt2) {
        IF  RscNum:HASKEY(RsOt1){
        SET ggl2 TO ggl2+RscList[RscNum[RsOt2]][1]:length+1.
        IF SHIP:RESOURCES[RscNum[RsOt1]]:CAPACITY = 0 SET err3 TO ": No " +RscList[RscNum[RsOt1]][1] + " Storage". 
          ELSE IF SHIP:RESOURCES[RscNum[RsOt1]]:AMOUNT > SHIP:RESOURCES[RscNum[RsOt1]]:CAPACITY-0.5 SET err3 TO ": "+RscList[RscNum[RsOt1]][1]+" Full".
        SET err4 TO"".
        IF SHIP:RESOURCES[RscNum[RsOt2]]:CAPACITY = 0 SET err4 TO ": No " +RscList[RscNum[RsOt2]][1] + " Storage". 
          ELSE IF SHIP:RESOURCES[RscNum[RsOt2]]:AMOUNT > SHIP:RESOURCES[RscNum[RsOt2]]:CAPACITY-0.5 SET err4 TO ": "+RscList[RscNum[RsOt2]][1]+" Full".
      }ELSE{}
        }ELSE{SET err3 TO ": No " +RsOt2+ " Storage". }
      }
      IF RsOt3 <> ""{SET p7 TO 1. 
        IF RscNum:HASKEY(RsOt3){
        SET ggl TO ggl+RscList[RscNum[RsOt3]][1]:length+2.
          IF SHIP:RESOURCES[RscNum[RsOt3]]:CAPACITY = 0 SET err2 TO ": No " +RscList[RscNum[RsOt3]][1] + " Storage". 
            ELSE IF SHIP:RESOURCES[RscNum[RsOt3]]:AMOUNT > SHIP:RESOURCES[RscNum[RsOt3]]:CAPACITY-0.5 SET err2 TO ": "+RscList[RscNum[RsOt3]][1]+" Full".
        }ELSE{SET err4 TO ": No " +RsOt3+ " Storage".}       
      }
            IF err1+err2+err3+err4 = "" {
              SET ggl  TO (widthlim-3-ggl-hudopts[J][3]:length-hudopts[J][2]:length-hudopts[J][1]:length)/2*(2-p2-p7)-1.
              SET ggl2 TO (widthlim-3-ggl2)/2*(2-p6).
                IF p1 = 1             SET err1 TO RscList[RscNum[RsIn1]][1]+SetGauge(SHIP:RESOURCES[RscNum[RsIn1]]:AMOUNT/SHIP:RESOURCES[RscNum[RsIn1]]:CAPACITY*100,J,GgL).
                IF p2 = 1             SET err2 TO RscList[RscNum[RsIn2]][1]+SetGauge(SHIP:RESOURCES[RscNum[RsIn2]]:AMOUNT/SHIP:RESOURCES[RscNum[RsIn2]]:CAPACITY*100,J,GgL).
                IF p7 = 1             SET err2 TO RscList[RscNum[RsOt3]][1]+SetGauge(SHIP:RESOURCES[RscNum[RsOt3]]:AMOUNT/SHIP:RESOURCES[RscNum[RsOt3]]:CAPACITY*100,J,GgL).
                IF p3 = 1             SET err3 TO RscList[RscNum[RsIn3]][1]+SetGauge(SHIP:RESOURCES[RscNum[RsIn3]]:AMOUNT/SHIP:RESOURCES[RscNum[RsIn3]]:CAPACITY*100,J,(GgL2)).
                IF p4 = 1 AND P5 = 0  SET err4 TO RscList[RscNum[RsIn4]][1]+SetGauge(SHIP:RESOURCES[RscNum[RsIn4]]:AMOUNT/SHIP:RESOURCES[RscNum[RsIn4]]:CAPACITY*100,J,(GgL2)).
                IF p4 = 1 AND P5 = 1  {
                  IF p1+p2>0{SET err4 TO RscList[RscNum[RsOt1]][1]+SetGauge(SHIP:RESOURCES[RscNum[RsOt1]]:AMOUNT/SHIP:RESOURCES[RscNum[RsOt1]]:CAPACITY*100,J,(GgL2)).}
                  ELSE{      SET err2 TO RscList[RscNum[RsOt1]][1]+SetGauge(SHIP:RESOURCES[RscNum[RsOt1]]:AMOUNT/SHIP:RESOURCES[RscNum[RsOt1]]:CAPACITY*100,J,(GgL-5)).}
                }
                IF p4 = 1 AND P5 = 2  SET err3 TO RscList[RscNum[RsOt1]][1]+SetGauge(SHIP:RESOURCES[RscNum[RsOt1]]:AMOUNT/SHIP:RESOURCES[RscNum[RsOt1]]:CAPACITY*100,J,(GgL2)).
                IF p5 = 2             SET err4 TO RscList[RscNum[RsOt2]][1]+SetGauge(SHIP:RESOURCES[RscNum[RsOt2]]:AMOUNT/SHIP:RESOURCES[RscNum[RsOt2]]:CAPACITY*100,J,(GgL2)).
                SET hudopts[J][3] TO hudopts[J][3]+err1+" "+err2.
                SET botrow TO err3+" "+err4.
            }ELSE{
              IF huditem = pwrtag{
                SET hudopts[J][3] TO ":not converting:".
                SET botrow TO err1+err2+err3+err4.
                SET GrpDspList[HudItem][hudtag] TO 1.
                SET forcerefresh TO 1.
              }
              IF huditem = MksDrlTag{
                SET hudopts[J][3] TO ":not Active:"+err1+err2+err3+err4.
                SET GrpDspList2[HudItem][hudtag] TO 4.
                SET forcerefresh TO 1.
              }

            }
    }
    //#endregion
    //#endregion
    //#region get text info
   FUNCTION CHANGESEL{
    LOCAL PARAMETER OMAX, CSCURRENT, DIR, OMIN IS 1.
        IF dbglog > 1 log2file("    CHANGESEL:"+" CSCURRENT:"+ CSCURRENT+" DIR:"+ DIR+" OMIN:"+ OMIN+" OMAX:"+ OMAX).
        IF DIR = "+" {IF CSCURRENT < OMAX {SET CSCURRENT TO CSCURRENT + 1.}ELSE{SET CSCURRENT TO OMIN.}}ELSE{
        IF DIR = "-" {IF CSCURRENT > OMIN {SET CSCURRENT TO CSCURRENT - 1.}ELSE{SET CSCURRENT TO OMAX.}}}
        IF dbglog > 1 log2file("         OUT:"+CSCURRENT).
        RETURN CSCURRENT.
    }
   FUNCTION ToggleResConv{
    LOCAL PARAMETER prt, rsrc, rscnumL, mode IS 1.
    LOCAL TRCAns TO "".
    IF rsrc = "liquidfuel" SET rsrc TO "lqdfuel".
    IF rsrc = "oxidizer" SET rsrc TO "ox".
      LOCAL t TO prt:getmodulebyindex(rscnumL).
      IF prt:HASMODULE("ModuleResourceConverter"){
        IF t:HASEVENT("start isru ["+rsrc+"]"){SET TRCAns TO "not converting      ".
          IF mode = 1 {t:DOEVENT("start isru ["+rsrc+"]"). SET TRCAns TO "converting            ".}}
        ELSE{
        IF t:HASEVENT("stop isru ["+rsrc+"]"){SET TRCAns TO "converting            ".
          IF mode = 1 {t:DOEVENT("stop isru ["+rsrc+"]"). SET TRCAns TO "not converting      ".}}
        }}
      RETURN TRCAns.
    }
   FUNCTION ADDMAX{
    LOCAL PARAMETER NmIn, NmAdd, NmMin, NmMax, opt IS 1.
    IF dbglog > 2 log2file("    ADDMAX:"+" NmIn:"+NmIn+" NmAdd:"+NmAdd+" NmMin:"+NmMin+" NmMax:"+NmMax+" opt:"+opt).
    SET nmcalc TO NmIn+NmAdd.
    IF opt = 1{
      IF nmcalc > NmMax SET nmcalc TO(nmcalc- NmMax)-NmMin-1.
      IF nmcalc < NmMin SET nmcalc TO NmMax-abs(nmcalc+ NmMin)+1.
      RETURN nmcalc.
    }
    IF opt = 2{
      IF nmcalc > NmMax SET nmcalc TO NmMin.
      IF nmcalc < NmMin SET nmcalc TO NmMax.
      RETURN nmcalc.
    }
    IF opt = 3{
      IF nmcalc > NmMax SET nmcalc TO NmMax.
      IF nmcalc < NmMin SET nmcalc TO NmMin.
      RETURN nmcalc.
    }
   }
   FUNCTION wordcheck{
      LOCAL PARAMETER input, wordchk.
      LOCAL WCAns TO 0.
      FOR w IN wordchk{IF input:contains(w){SET WCAns TO 1. BREAK.}}
      RETURN WCAns.
    }
   FUNCTION CHECKOPT{
      LOCAL PARAMETER OMAX, CoCURRENT, DIR, LstIn1 IS LIST(""), omin IS 1, opt IS 0.
      LOCAL PLMT IS 13.
      IF DbgLog > 2 log2file("      CheckOPT-:"+CoCURRENT+":"+DIR+" mode:"+LstIn1+" min:"+omin+" MAX:"+OMAX).
      IF DIR = "+" {IF CoCURRENT < OMAX {SET CoCURRENT TO CoCURRENT + 1.}ELSE{SET CoCURRENT TO omin.}}
      IF DIR = "-" {IF CoCURRENT > omin {SET CoCURRENT TO CoCURRENT - 1.}ELSE{SET CoCURRENT TO OMAX.}}
      IF LstIn1 = 6 {
        UNTIL AutoRscList[0][Cocurrent] = 1 {
          IF DIR = "+" {IF CoCURRENT < OMAX {SET CoCURRENT TO CoCURRENT + 1.}ELSE{SET CoCURRENT TO omin.}}
          IF DIR = "-" {IF CoCURRENT > omin {SET CoCURRENT TO CoCURRENT - 1.}ELSE{SET CoCURRENT TO OMAX.}}
        }
        RETURN ItemListHUD[CoCURRENT].
      }
      IF LstIn1 = 7 {
        SET OMAX TO prtTagList[itemnumcur][0].
        IF CoCURRENT > OMAX SET Cocurrent TO omax.
        LOCAL selprv TO CoCURRENT.
        UNTIL autoTRGList[0][ITEMNUMCUR][CoCURRENT] > -1 {
          IF DIR = "+" {IF CoCURRENT < OMAX {SET CoCURRENT TO CoCURRENT + 1.}ELSE{SET CoCURRENT TO omin.}}
          IF DIR = "-" {IF CoCURRENT > omin {SET CoCURRENT TO CoCURRENT - 1.}ELSE{SET CoCURRENT TO OMAX.}}
          IF Cocurrent = selprv BREAK.
        }
      IF DbgLog > 2 log2file("      CheckTAG-:"+CoCURRENT).
        LOCAL ANSOUT TO  PRTTAGLIST[ITEMNUMCUR][MIN(CoCURRENT,PRTTAGLIST[ITEMNUMCUR]:LENGTH-1)].
        IF opt = 0 RETURN ANSOUT. ELSE RETURN ANSOUT:substring(0,(MIN(ANSOUT:length, PLMT))).
      }
      IF LSTIN1:typename = "string" RETURN.
      IF LSTIN1[0]= "" RETURN.
      IF opt = 0 RETURN LstIn1[CoCURRENT]. ELSE RETURN LstIn1[CoCURRENT]:substring(0,(MIN(LstIn1[CoCURRENT]:length, PLMT))).
    }
   FUNCTION SwapBool{
    LOCAL PARAMETER Boolin IS "".
    IF boolin = FALSE SET boolin TO TRUE. ELSE IF boolin = TRUE SET boolin TO FALSE. 
    RETURN boolin.
  }
   //#endregion
    //#region auto
   FUNCTION clearauto{
    LOCAL PARAMETER item, tag, updn, opt, RSM IS autoRstList[item][tag].
    LOCAL UPDN2 TO 0.
    SET opt TO abs(opt).
    IF dbglog > 0{
      log2file("      CLEAR AUTO-:"+itemlist[item]+":"+prttaglist[item][tag]).
      IF dbglog > 1{
        log2file("        "+item+" tag:"+tag+" updn:"+updn+" opt:"+opt ).
        log2file("        autoRstList[item][tag](RSMD):"+RSM ).
        log2file("        AutoValList[item][tag]("+AutoValList[item][tag]+"):"). 
        LOCAL lud TO "OVER".
        IF updn = 2 SET lud TO "UNDER".
        IF updn = 3 SET lud TO "OVER-OFF".
        IF updn = 4 SET lud TO "UNDER-OFF".
        log2file("        AutoLst["+MODELONG[opt]+"("+opt+")]["+lud+"("+updn+")]["+itemlist[item]+"("+item+")]    :"+LISTTOSTRING(AutoLst[opt][updn][item]) ).
        IF AutotagLstUP[item]:length > 1 log2file("         AutotagLstUP["+item+"]:"+LISTTOSTRING(AutotagLstUP[item]) ).
        IF AutotagLstDN[item]:length > 1 log2file("         AutotagLstDN["+item+"]:"+LISTTOSTRING(AutotagLstDN[item]) ).
        IF  AutotagLstNAup[item]:length > 1 log2file("        AutotagLstNAup["+item+"]:"+LISTTOSTRING(AutotagLstNAup[item]) ).
        IF  AutotagLstNADN[item]:length > 1 log2file("        AutotagLstNADN["+item+"]:"+LISTTOSTRING(AutotagLstNADN[item]) ).
      }
    }
    SET cnt TO 0.
    LOCAL trm TO 0.
    LOCAL lst1 TO AutoLst[opt][updn][item]:sublist(0, AutoLst[opt][updn][item]:length).
    FOR i IN lst1{
      IF RSM = 1 {
        LOCAL trg1 TO 0.
        IF updn = 1 AND i = AutoValList[item][tag] SET trg1 TO 1.
        IF updn = 2 AND 0-i = AutoValList[item][tag] SET trg1 TO 2. 
          IF trg1 > 0{
            SET trm TO 1.
            SET AutoLst[opt][updn][item][cnt] TO 0.
            IF   AutotagLstDN[item]:contains(tag)   AutotagLstDN[item]:REMOVE(AutotagLstDN[item]:find(tag)).
            IF   AutotagLstUP[item]:contains(tag)   AutotagLstUP[item]:REMOVE(AutotagLstUP[item]:find(tag)).
            IF AutotagLstNADN[item]:contains(tag) AutotagLstNADN[item]:REMOVE(AutotagLstNADN[item]:find(tag)).
            IF AutotagLstNAup[item]:contains(tag) AutotagLstNAup[item]:REMOVE(AutotagLstNAup[item]:find(tag)).
            BREAK.
          }
          SET cnt TO cnt+1.
      }
      ELSE{
        IF RSM > 1 {
            IF updn = 1 AND i = AutoValList[item][tag]{
              IF DbgLog > 0 log2file("      "+itemlist[item]+":"+prttaglist[item][tag]+" switched to UNDER" ).
              SET UPDN2 TO 2.
              SET AutoValList[item][tag] TO 0-ABS(AutoValList[item][tag]).
            }
            IF updn = 2 AND 0-i = AutoValList[item][tag]{
              IF DbgLog > 0 log2file("      "+itemlist[item]+":"+prttaglist[item][tag]+" switched to OVER" ).
              SET UPDN2 TO 1.
              SET AutoValList[item][tag] TO ABS(AutoValList[item][tag]).
            }
            IF updn2 > 0 {
              IF NOT AutoLst[opt][UPDN2][item]:contains(AutoLst[opt][UPDN][item][cnt]) AutoLst[opt][UPDN2][item]:ADD(AutoLst[opt][UPDN][item][cnt]).
              SET AutoLst[opt][UPDN][item][cnt] TO 0. 
              BREAK.
            }
            SET cnt TO cnt+1.
        }
      }
    }

     IF trm = 1{
            IF AutoItemLst[opt][1]:contains(item) {IF AutotagLstUP[item]:length   = 0 AutoItemLst[opt][1]:REMOVE(AutoItemLst[opt][1]:find(item)).}
            IF AutoItemLst[opt][2]:contains(item) {IF   AutotagLstDN[item]:length = 0 AutoItemLst[opt][2]:REMOVE(AutoItemLst[opt][2]:find(item)).}
            IF AutoItemLst[opt][3]:contains(item) {IF AutotagLstNAUP[item]:length = 0 AutoItemLst[opt][3]:REMOVE(AutoItemLst[opt][3]:find(item)).}
            IF AutoItemLst[opt][4]:contains(item) {IF AutotagLstNADN[item]:length = 0 AutoItemLst[opt][4]:REMOVE(AutoItemLst[opt][4]:find(item)).}
     }
      IF AutoLst[opt][updn][item]:LENGTH > 1 AND AutoLst[opt][updn][item]:CONTAINS(0) AutoLst[opt][updn][item]:REMOVE(AutoLst[opt][updn][item]:SUBLIST(1,AutoLst[opt][updn][item]:LENGTH):FIND(0)+1).
    IF RSM = 1 {SET AutoDspList[item][tag] TO 1.} ELSE 
    IF RSM > 1 AND UPDN2 > 0 UpdateAutoTriggers(updn2,OPT,item,tag).
    //if item = dcptag set DcpPrtList[tag] to list(0,"").
    SET SaveFlag TO 1. 
    UpdateAutoMinMax(opt).
      IF dbglog > 1{
        log2file("        post update triggers").
        log2file("          AutoLst["+opt+"]["+updn+"]["+item+"]    :"+LISTTOSTRING(AutoLst[opt][updn][item]) ).
        IF AutotagLstUP[ITEM]:length > 1 log2file("         AutotagLstUP["+ITEM+"]:"+LISTTOSTRING(AutotagLstUP[ITEM]) ).
        IF AutotagLstDN[ITEM]:length > 1 log2file("         AutotagLstDN["+ITEM+"]:"+LISTTOSTRING(AutotagLstDN[ITEM]) ).
        IF  AutotagLstNAup[ITEM]:length > 1 log2file("        AutotagLstNAup["+ITEM+"]:"+LISTTOSTRING(AutotagLstNAup[ITEM]) ).
        IF  AutotagLstNADN[ITEM]:length > 1 log2file("        AutotagLstNADN["+ITEM+"]:"+LISTTOSTRING(AutotagLstNADN[ITEM]) ).
      }
  }
   FUNCTION TriggerAuto{ //and check auto state
      LOCAL PARAMETER LstIN, md, ThrVal, opt IS 1, opt2 IS 1.
      //lastin().
      SpeedBoost().
      IF dbglog > 0{
        IF opt2 < 2 log2file("TRIGGERAUTO md:"+modelong[md]+"("+md+") ThrVal:"+ThrVal+" opt:"+opt+" opt2:"+opt2 ). ELSE
        IF opt2 = 2 AND dbglog > 2 log2file("CHECK-RSC   md:"+modelong[md]+"("+md+") ThrVal:"+ThrVal+" opt:"+opt+" opt2:"+opt2 ). ELSE
        IF opt2 = 3 AND dbglog > 2 log2file("CHECKSTATE  md:"+modelong[md]+"("+md+") status:"+STATUSOPTS[ThrVal]+"("+thrval+")"+" opt:"+opt+" opt2:"+opt2 ).
        IF dbglog > 2 AND opt2 < 2 log2file("    LstIN:"+LISTTOSTRING(Lstin)).
      }
      LOCAL AbsThr TO abs(ThrVal).
      SET cnt TO 0.   
      LOCAL lst2 TO LIST().
      FOR i IN Lstin:sublist(1, Lstin:length) {
          IF opt = 1 AND AutotagLstUP[i]:length > 0 SET lst2 TO AutotagLstUP[I]:sublist(0, AutotagLstUP[I]:length).
          IF opt = 2 AND AutotagLstDN[i]:length > 0 SET lst2 TO AutotagLstDN[I]:sublist(0, AutotagLstDN[I]:length).
          IF lst2:length > 0 FOR t IN lst2 {
            LOCAL savedVal TO AutoValList[I][T].
            LOCAL trg TO 0. LOCAL act TO 0. 
            LOCAL AbsVal TO abs(savedVal).
            IF DbgLog > 1 AND opt2 < 2{
              log2file("      "+itemlist[I]+"("+I+") "+prtTagList[i][t]+"("+T+")").
              log2file("        AbsVal:"+AbsVal+" "+" savedVal:"+savedVal+" AbsThr:"+AbsThr).
              log2file("        autoRstList[I][T]:"+autoRstList[I][T]).
              log2file("        AutoRscList[I][T]:"+AutoRscList[I][T]).
              log2file("        AutoDspList[I][T]:"+AutoDspList[I][T]).
            }
            IF autoRstList[I][T] > 2 AND autoRstList[I][T] - opt = 2 SET act TO 1.
            IF autoRstList[I][T] < 3 SET act TO 1.
            IF AutoDspList[I][T] = md{
              IF opt2 = 2{
                IF AutoRscList[I][T]<>0{
                  LOCAL RscAmt TO SHIP:RESOURCES[RscNum[AutoRscList[I][T]]]:AMOUNT/SHIP:RESOURCES[RscNum[AutoRscList[I][T]]]:CAPACITY*100.
                  LOCAL ZAdj TO 0. IF savedval = 0 SET zadj TO 0.0001.
                  IF RscAmt > 1 SET RscAmt TO ROUND(RscAmt,0).
                  IF savedVal > -0.0001 {IF RscAmt > AbsVal-zadj SET trg TO 1. SET dpr TO " > ".}
                  IF savedVal <  0.0001 {IF RscAmt < AbsVal+zadj SET trg TO 2. SET dpr TO " < ".}
                  IF DbgLog > 1 AND TRG = 1 AND md <> 14 log2file("       if SavedVal ("+savedval+") >  -0.0001 and "+" rsc:"+AutoRscList[I][T]+"("+RscAmt+")  > AbsVal-"+zadj+"("+(AbsVal-zadj)+") trg:"+TRG+"="+OPT+"--ACT:"+ACT).
                  IF DbgLog > 1 AND TRG = 2 AND md <> 14 log2file("       if SavedVal ("+savedval+") <   0.0001 and "+" rsc:"+AutoRscList[I][T]+"("+RscAmt+")  < AbsVal+"+zadj+"("+(AbsVal+zadj)+") trg:"+TRG+"="+OPT+"--ACT:"+ACT).
                  IF DbgLog > 1 AND TRG = 0 AND md <> 14 log2file("       ITEM:"+itemlist[i]+" TAG:"+prttagList[i][t]+" rsc:"+AutoRscList[I][T]+"("+RscAmt+")"+dpr+absval).
                }}
                ELSE{
              IF opt2 = 3{
                    LOCAL TIMETO TO 999.
                    IF AbsVal < 9{IF AbsVal = statusopts:find(SHIP:STATUS) {SET act TO 1. SET trg TO 1. }}
                    ELSE{
                           IF AbsVal = 9  SET timeto TO ETA:APOAPSIS. 
                      ELSE IF AbsVal = 10 SET timeto TO ETA:PERIAPSIS. 
                      ELSE IF AbsVal = 11 SET timeto TO ETA:NEXTNODE. 
                      ELSE IF AbsVal = 12 SET timeto TO ETA:TRANSITION.
                      IF timeto < 10 { SET act TO 1. SET trg TO 1. IF WARPMODE = "RAILS" AND WARP > 0 SET WARP TO 0. UNTIL kuniverse:timewarp:issettled = TRUE WAIT 0.5.}
                    }
                  }
              ELSE{
                IF AbsVal = AbsThr AND savedVal > -0.0001 AND savedVal > AbsThr-.0001 SET trg TO 1.
                IF AbsVal = AbsThr AND savedVal <  0.0001 AND savedVal < 0-AbsThr+.0001 SET trg TO 2.
                IF DbgLog > 1 AND md <> 14 log2file("       if AbsVal("+AbsVal+") = AbsThr("+AbsThr+") and savedVal("+savedVal+") trg:"+TRG+"="+OPT+"--ACT:"+ACT).}
            }}
              IF trg = opt {IF act = 1 ToggleGroup(i,t,AutoTRGList[I][T],1). ClearAuto(i,t,opt,AutoDspList[I][T]). UPDATEHUDOPTS().}
          }
      }
      SpeedBoost("off").
    }
   FUNCTION listautosettings{
    SpeedBoost().
    IF dbglog > 0 log2file("LISTING AUTO SETTINGS").
    SET loading TO 0.
      SET BtnActn TO 1.
      desktop().
      LOCAL Plst2 IS LIST().
      FOR i IN range(1,itemlist[0]+2){plst2:ADD(LIST(0)).}
      FOR md IN range (1,MODESHRT:LENGTH){
        FOR u IN range(1,5){
          IF u = 5 {
          }
          ELSE{
          IF u = 1 {SET ud TO "  OVER ". SET LS TO autotaglstup.}
          IF u = 2 {SET ud TO " UNDER ". SET LS TO autotaglstdn.}
          IF u = 3 {SET ud TO "  OVER ". SET LS TO AutotagLstNAUP.}
          IF u = 4 {SET ud TO " UNDER ". SET LS TO AutotagLstNADN.}
            FOR i IN range(1,autoitemlst[md][u]:length){
              LOCAL icnt TO 1.
              SET itm TO autoitemlst[md][u][i].
                IF dbglog > 0 log2file("    "+LISTTOSTRING(LS[MD])).
                IF ls[md]:length > 0{
                  FOR t IN range(0,ls[itm]:length){
                    LOCAL tg TO ls[itm][t].
                    IF T <> 0 pout(itm,tg).
                    loadbar().                    
                    SET icnt TO icnt+1.
                  }
                }
            }
          }
        }
      }
      PRINTLINE("",0,16).
      SET LNstp TO 1.
     // PRINT "|          | CONTINUE |          |" AT (0,heightlim).
      PRINT "|          |          |          |" AT (0,heightlim).
        FOR i IN range(1,plst2:length-1){
          IF plst2[i]:length > 1{
            FOR j IN range(1,plst2[i]:length){
              LOCAL po TO printrow(plst2[i][j],0). 
              WAIT.02.
              IF i > plst2:length-2 SET po TO 1.
              IF po = 1 WaitFor(15,1).
            }
          }
        }
        IF plst2:length > 0 WaitFor(15,1).
            LOCAL FUNCTION pout{
              LOCAL PARAMETER itmP,tgP.
              IF dbglog > 0 log2file("    "+ItemList[itmp]+":"+prttaglist[itmp][tgp]).
              LOCAL automode TO abs(AutoDspList[itmP][tgP]).
              LOCAL MODEPRINT TO Removespecial(MODELONG[automode]," "). 
              LOCAL wt4 TO "".
                LOCAL vlprint TO abs(AutovalList[ItmP][TgP]).
                LOCAL ACTLST TO LIST(4,grpopslist[itmP][tgP][GrpDspList[itmP][tgP]],grpopslist[itmP][tgP][GrpDspList2[itmP][tgP]],grpopslist[itmP][tgP][GrpDspList3[itmP][tgP]], EmptyHud).
                FOR l IN range(1,4){
                  IF actlst[l] = EmptyHud SET ACTLST[l] TO "ACTION"+L.
                }
                LOCAL ActionPrint TO ACTLST[AutoTRGList[itmP][TgP]].
                IF ActionPrint:LENGTH > 0 {IF ActionPrint[ActionPrint:LENGTH-1] <> " " SET ActionPrint TO ActionPrint.}
                IF ActionPrint[0] <> " " SET ActionPrint TO " "+ActionPrint.
                SET ActionPrint TO " "+Removespecial(ActionPrint," ")+" ".
                SET ActionPrint TO ActionPrint:REPLACE("TURN","TURN ").
                SET ActionPrint TO ActionPrint:REPLACE("RUN","RUN ").
                SET ActionPrint TO ActionPrint:REPLACE("XMIT","XMIT ").
                SET ActionPrint TO ActionPrint:REPLACE("ACTION","ACTION ").
                LOCAL afttrgprint TO "".
                IF autoTRGList[0][itmP][tgP] > 0 {SET DelayPrint TO " WAIT "+autoTRGList[0][itmP][tgP]+" THEN".} ELSE SET DelayPrint TO "".
                IF AutoDspList[itmP][tgP] < 0 AND AutoDspList[0][itmP][tgP][0]:tostring <> "0"{
                  LOCAL splt TO AutoDspList[0][itmP][tgP][0]:split("-").
                  IF splt:length = 3 SET  wt4 TO "HOLD4 ".
                  IF splt:length = 4 SET  wt4 TO "LOCK2 ".
                }
                IF AutoDspList[itmp][TgP] < 0 AND AutoDspList[0][itmp][TgP][0] <> 0{
                  LOCAL splt TO AutoDspList[0][itmp][TgP][0]:split("-").                  
                  SET DelayPrint TO wt4+REMOVESPECIAL(ItemListHUD[splt[0]:tonumber]," ")+":"+Prttaglist[splt[0]:tonumber][splt[1]:tonumber]+" "+DelayPrint.}
                IF  autoRstList[itmP][tgP] = 1 SET AftTrgPrint TO "DISABLE".
                IF  autoRstList[itmP][tgP] = 2 IF UD = " UNDER " { SET AftTrgPrint TO "SWITCH TO OVER".}ELSE{SET AftTrgPrint TO "SWITCH TO UNDER".}.
                IF UD = " UNDER " { SET vlprint TO "UNDER "+vlprint.
                  IF autoRstList[itmP][tgP] = 4 {SET AftTrgPrint TO "WAIT FOR UNDER".}
                  IF autoRstList[itmP][tgP] = 3 {SET ActionPrint TO "RESET ". SET AftTrgPrint TO "WAIT FOR OVER".}
                }
                IF UD = "  OVER " {SET vlprint TO "OVER "+vlprint.
                  IF autoRstList[itmP][tgP] = 3 {SET AftTrgPrint TO "WAIT FOR OVER".}
                  IF autoRstList[itmP][tgP] = 4 {SET ActionPrint TO "RESET ".  SET AftTrgPrint TO "WAIT FOR UNDER".}
                }
                IF MODEPRINT = "ALTAGL" SET MODEPRINT TO "ALT AGL".
                IF MODEPRINT = "STATUS" SET vlprint TO "is "+ STATUSOPTS[abs(AutoValList[ItmP][TgP])].
                LOCAL itmprint TO prttaglist[itmP][tgP].
                IF itmprint:length > 15 {
                  FOR wd IN trimwords{
                    SET itmprint TO Removespecial(itmprint,wd).
                  }
                }
                SET AftTrgPrint TO " THEN "+AftTrgPrint.
                IF AftTrgPrint = " THEN DISABLE" SET AftTrgPrint TO "".
                IF Plst2[itmP]:length = 1  AND automode <> 1{
                  Plst2[itmP]:ADD(getcolor(itemlist[itmP],"WHT")).
                }
                LOCAL pof TO "  "+itmprint+":"+DelayPrint+ActionPrint+"WHEN "+MODEPRINT+" "+vlprint+AftTrgPrint.
                IF automode <> 1 AND NOT Plst2[itmP]:contains(pof){Plst2[itmP]:ADD(pof).
                IF dbglog > 0 log2file("    "+pof).
                }
            }
            FUNCTION WaitFor{
                LOCAL PARAMETER wt IS 10, opt IS 0.
                LOCAL wt2 TO wt.
                LOCAL ch TO "".
                //until k2 > wt2-1
                FOR k2 IN range (1,wt2-2){
                  //print "continuing in "+(wt2-k2)+" seconds, or press continue." AT (1,16).
                  PRINT "continuing in "+(wt2-k2)+" seconds." AT (1,16).
                  //set k2 to k2 +1.
                  ///figure this out
                  IF terminal:input:haschar {SET ch TO terminal:input:getchar().}
                  IF ch = "5" {button8a().SET ch TO "".}
                  WAIT 1.
                  IF k2 > wt2-1 BREAK.
                FUNCTION button8a{SET k2 TO wt2.}buttons:setdelegate(8,button8a@).
                }
              IF opt = 1{
                FOR z IN range(1,LNstp+1) PRINT "|"+Bigempty2+"|" AT(0,z). 
                SET LNstp TO 1.
              }     
              //buttons:setdelegate(8,button8@).

              SET forcerefresh TO 1.
            }
      SET BtnActn TO 1.
      buttons:setdelegate(8,button8@).
    CLEARSCREEN.
    SpeedBoost("off").
    RETURN.
    }
    //#endregion
    //MAINLOOP
    //#region buttons 
    FUNCTION button0{lastin(). IF BtnActn=0{SET BtnActn TO 1. IF ENG[1] <> EmptyHud{
      IF hudop = 5{
      SET dctnmode TO ADDMAX(dctnmode,1,0,2).}
    ELSE{TopHugTrig(0).}}
    SET buttonRefresh TO 2.}SET BtnActn TO 0. }  buttons:setdelegate(0,button0@).

    FUNCTION button1{lastin(). IF BtnActn=0{SET BtnActn TO 1. IF ENG[2] <> EmptyHud{
      IF hudop = 5{
        IF dctnmode = 0{
          LOCAL lmt TO 2. 
          IF ModeSel > 7 AND modesel < 13 SET lmt TO 3.
          IF modesel > 1 SET AutoValList[0][0][3][modesel] TO CHANGESEL(lmt, AutoValList[0][0][3][modesel] ,"+").
        }
        ELSE{
          SET HDItm TO CHANGESEL(ItemList[0], HDItm ,"+").
          SET HDTag TO 1.
        }
      }
      ELSE{TopHugTrig(1).}}
      SET buttonRefresh TO 2.}SET BtnActn TO 0. }  buttons:setdelegate(1,button1@).
    
    FUNCTION button2{IF BtnActn=0{lastin(). SET BtnActn TO 1. IF ENG[3] <> EmptyHud{
      IF hudop = 5{
        IF dctnmode = 0{
        SET modesel TO CHANGESEL(MODELONG[0], modesel,"+"). 
        UNTIL AutoValList[0][0][3][modesel] > -1 {SET modesel TO CHANGESEL(MODELONG[0], modesel,"+").}
        }
        ELSE{
          SET HDTag TO CHANGESEL(prtTagList[HDItm][0], HDTag ,"+").//AAAA
        }
        //UPDATEHUDOPTS().
      }
      ELSE{TopHugTrig(2).}}
      SET buttonRefresh TO 2.}SET BtnActn TO 0. 
    }buttons:setdelegate(2,button2@).
    
    FUNCTION button3{IF BtnActn=0{lastin(). SET BtnActn TO 1. IF ENG[4] <> EmptyHud{
      IF hudop = 5{IF h5mode = 1 SET h5mode TO 0. ELSE SET h5mode TO 1.} 
      ELSE{TopHugTrig(3).}}SET buttonRefresh TO 2.}SET BtnActn TO 0. }  buttons:setdelegate(3,button3@).
    
    FUNCTION button4{IF BtnActn=0{lastin(). SET BtnActn TO 1. IF ENG[5] <> EmptyHud{
      IF hudop = 5{SET AutoRscList[0][EnabSel] TO CHANGESEL(2, AutoRscList[0][EnabSel] ,"+"). 
    }ELSE{TopHugTrig(4).}}SET buttonRefresh TO 2.}SET BtnActn TO 0. }  buttons:setdelegate(4,button4@).
    
    FUNCTION button5{IF BtnActn=0{lastin(). SET BtnActn TO 1. IF ENG[7] <> EmptyHud{
      IF hudop = 5{SET EnabSel TO CHANGESEL(HudOpts[2][1][0], EnabSel,"+"). PRINT EmptyHud+EmptyHud AT (52,1).SET buttonRefresh TO 2.}
    ELSE{
    IF rowval = 0 {TOGGLE INTAKES.}ELSE{SET MtrOps[hsel[2][1]][0] TO CHANGESEL(1, MtrOps[hsel[2][1]][0],"+",0).}
    }}}SET BtnActn TO 0. SET buttonRefresh TO 3.}  buttons:setdelegate(5,button5@).
    
    FUNCTION button6{IF BtnActn=0{lastin(). SET BtnActn TO 1. SET buttonRefresh TO 2.}SET BtnActn TO 0. }  buttons:setdelegate(6,button6@).
    
    FUNCTION button7{IF BtnActn=0{lastin(). IF PrvITM <> EmptyHud OR hudop = 5{
      SET BtnActn TO 1.SET buttonRefresh TO 3. SET seldir TO "-". 
      IF HUDOP = 5{
        IF TrgLim > 1 SET AutoSetAct TO CHANGESEL(TrgLim, AutoSetAct,"+"). 
      }ELSE{
         clearall(). clearto(2,14).
         //if hsel[2][1] = CMDTag clearto(9,14).
       SET HSEL[2][1] TO CHANGESEL(HudOpts[2][1][0], hsel[2][1],seldir).
        UNTIL AutoRscList[0][HSEL[2][1]] = 1 {SET HSEL[2][1] TO CHANGESEL(HudOpts[2][1][0], hsel[2][1],seldir).}
        SET HSEL[2][2] TO 1. 
        SET HSEL[2][3] TO 1.
        SET HudOpts[2][2] TO prttaglist[hsel[2][1]].
        SET HudOpts[2][3] TO " ".
        SET MtrPrtSel[1] TO 0.}
        SET forcerefresh TO 2.
        UPDATEHUDOPTS().
        SET forcerefresh TO 2.
        }}SET BtnActn TO 0.}  buttons:setdelegate(7,button7@).
    
    FUNCTION button8{
      lastin().
      IF BtnActn=0{
        SET BtnActn TO 1. 
        SET buttonRefresh TO 1.
        IF HUDOP = 5{
          SET AutoSetMode TO CHANGESEL(MODELONG[0], AutoSetMode,"+").
          UNTIL AutoValList[0][0][3][AutoSetMode] = 1 {SET AutoSetMode TO CHANGESEL(MODELONG[0], AutoSetMode,"+").}
        }ELSE{
        IF hsel[2][1] = ISRUTag {SET hudopts[1][3] TO ToggleResConv(prtlist[hsel[2][1]][hsel[2][2]][hsel[2][3]],isruoptlst[ConvRSC],ConvRSC).
        //UPDATEHUDOPTS().
        }
        ELSE{
          IF hsel[2][1] = flytag AND ItmTrg = " SET TRGT " {
            IF trglst[anttrgsel] = "no-target" OR trglst[anttrgsel] = "active-vessel" RETURN. 
            SET TARGET TO trglst[anttrgsel]. PRINTLINE("target set to:"+ trglst[anttrgsel],"CYN").}
          ELSE{
          IF hsel[2][1] = flytag {IF hasTarget = FALSE AND ItmTrg = " SET TRGT " RETURN.}
          togglegroup(hsel[2][1],hsel[2][2],1).  
        }}}SET forcerefresh TO 1. 
      }SET BtnActn TO 0.}  buttons:setdelegate(8,button8@).
    
    FUNCTION button9{lastin(). IF BtnActn=0{IF NXTITM <> EmptyHud{
      SET BtnActn TO 1. SET buttonRefresh TO 3. SET seldir TO "+". 
    IF HUDOP = 5{
      IF  abs(AutoSetMode) = 6 {
        IF RscSelection =RscList:length-1 {SET RscSelection TO 0.}
        ELSE{SET RscSelection TO CHANGESEL(RscList:length-1,RscSelection,seldir).}
      }
      IF abs(AutoSetMode) = 14  SET StsSelection TO CHANGESEL(STATUSOPTS[0],StsSelection,"+").
      IF  abs(AutoSetMode) = 15 {
        IF RscSelection =PRscList:length-1 {SET RscSelection TO 0.}ELSE{
        SET RscSelection TO CHANGESEL(PRscList:length-1,RscSelection,seldir).}
      }
      SET HUDOPPREV TO 0.
    }
    ELSE{
         clearall(). clearto(2,14).
         //if hsel[2][1] = CMDTag clearto(9,14).
        SET HSEL[2][1] TO CHANGESEL(HudOpts[2][1][0], hsel[2][1],seldir).
       UNTIL AutoRscList[0][HSEL[2][1]] = 1 {SET HSEL[2][1] TO CHANGESEL(HudOpts[2][1][0], hsel[2][1],seldir).}
        SET HSEL[2][2] TO 1. 
        SET HSEL[2][3] TO 1.
        SET HudOpts[2][2] TO prttaglist[hsel[2][1]].
        SET HudOpts[2][3] TO " ".
        SET MtrPrtSel[1] TO 0.}
        SET forcerefresh TO 2.
        UPDATEHUDOPTS().
        SET forcerefresh TO 2.
    }}SET BtnActn TO 0.}  buttons:setdelegate(9,button9@).
    
    FUNCTION button10{lastin(). IF BtnActn=0{SET BtnActn TO 1. IF BTHD10 <> EmptyHud{
      IF HUDOP = 5{
       SET AutoRstMode TO CHANGESEL(HudRstMdLst[0],AutoRstMode,"+"). 
       IF  abs(AutoSetMode) = 14 AND AutoRstMode > 1 SET AutoRstMode TO 1.
      }ELSE{
        IF hsel[2][1] = GEARTAG AND rowval = 0{SET AUTOBRAKE TO AUTOBRAKE+1. IF AUTOBRAKE = 3 SET AUTOBRAKE TO 0.}
        ELSE{
          togglegroup(hsel[2][1],hsel[2][2],2).}
        SET buttonRefresh TO 1.}SET forcerefresh TO 2. 
        //UPDATEHUDOPTS().
        }
    }SET BtnActn TO 0.}  buttons:setdelegate(10,button10@).
    
    FUNCTION button11{lastin(). IF BtnActn=0{SET BtnActn TO 1. IF BTHD11 <> EmptyHud{
        IF HUDOP = 5{
          SET AutoDspList[hsel[2][1]][hsel[2][2]] TO 1.
          SET AutoValList[hsel[2][1]][hsel[2][2]] TO 0.
          SaveAutoSettings(). PRINTQ:PUSH(" AUTO FILE SAVED"+"<sp>"+"WHT"). SETHUD().  
          //UPDATEHUDOPTS().
        }ELSE{
          IF hsel[2][1] = RBTTag AND NOT prtlist[hsel[2][1]][hsel[2][2]][hsel[2][3]]:HASMODULE("ModuleRoboticController"){
            SET autoRstList[0][0][tagnumcur] TO autoRstList[0][0][tagnumcur]+1. IF autoRstList[0][0][tagnumcur] = 10 SET autoRstList[0][0][tagnumcur] TO 0. SET forcerefresh TO 1.}
        ELSE{
        IF hsel[2][1] = FlyTag AND ROWVAL = 1 AND HSEL[2][2] = 1{
          SET axsel TO changesel(APaxis[0], axsel,"+").
          IF apsel = 1 AND axsel > 3 SET axsel TO 1.
          IF apsel = 2 IF axsel < 4 OR axsel > 6 SET axsel TO 4.
          IF apsel = 3 AND axsel < 7 SET axsel TO 7.
          SET forcerefresh TO 1.
        }
        ELSE{togglegroup(hsel[2][1],hsel[2][2],3).}}
        SET buttonRefresh TO 1. SET forcerefresh TO 2. 
        //UPDATEHUDOPTS().
        }}
    }SET BtnActn TO 0.}  buttons:setdelegate(11,button11@).
    
    FUNCTION button12{lastin(). IF BtnActn=0{}}  buttons:setdelegate(12,button12@).
    
    FUNCTION button13{lastin(). IF BtnActn=0{}}  buttons:setdelegate(13,button13@).
    
    FUNCTION button14{lastin(). IF BtnActn=0{}}  buttons:setdelegate(14,button14@).
    
    FUNCTION button15{lastin(). IF BtnActn=0{}}  buttons:setdelegate(15,button15@).
    
    FUNCTION buttonUp{lastin(). IF BtnActn=0{SET BtnActn TO 1. 
      IF HUDOP = 5{
        IF abs(AutoSetMode) = 14 {SET StsSelection TO CHANGESEL(STATUSOPTS[0],StsSelection,"+").}
        ELSE{
          IF h5mode = 1 {SET setdelay TO ADDMAX(setdelay,AutoAdjByLst[AUTOHUD[1]],0,100000,3).}
          ELSE{
          SET AUTOHUD[0] TO ADDMAX(AUTOHUD[0],AutoAdjByLst[AUTOHUD[1]],0,1000000000,3).
          }}
      }
      ELSE{IF RowSel < 2 {SET RowSel TO RowSel + 1 - rowval+1. SET buttonRefresh TO 2.}}
      UPDATEHUDOPTS().
      }.SET BtnActn TO 0. SET forcerefresh TO 2.}  buttons:setdelegate(-3,buttonUp@).
    
    FUNCTION buttonDown{lastin(). IF BtnActn=0{SET BtnActn TO 1. 
      IF HUDOP = 5{
        IF abs(AutoSetMode) = 14 {SET StsSelection TO CHANGESEL(STATUSOPTS[0],StsSelection,"-").}
        ELSE{
            IF h5mode = 1 {SET setdelay TO ADDMAX(setdelay,0-AutoAdjByLst[AUTOHUD[1]],0,100000,3).}
        ELSE{
          SET AUTOHUD[0] TO ADDMAX(AUTOHUD[0],0-AutoAdjByLst[AUTOHUD[1]],0,1000000000,3).
          SET HUDOPPREV TO 0.
          }}
      }
      ELSE{IF RowSel > 1 {SET RowSel TO RowSel - 1. SET buttonRefresh TO 2.}}
      UPDATEHUDOPTS().
      }.SET BtnActn TO 0. SET forcerefresh TO 2.}  buttons:setdelegate(-4,buttonDown@).
    
    FUNCTION buttonLeft{lastin(). IF BtnActn=0{SET BtnActn TO 1.  SET buttonRefresh TO 1. SET seldir TO "-".
            IF HUDOP = 5{
              SET HUDOPPREV TO 0.
              IF AUTOHUD[2] = "  OVER "{ SET AUTOHUD[2] TO " UNDER ".}ELSE{
              IF AUTOHUD[2] = " UNDER " SET AUTOHUD[2] TO "  OVER ".}
            }
      ELSE{ clearall(). SET forcerefresh TO 2. IF hsel[2][1] = CMDTag clearto(9,14).
      IF rowval = 0{
        IF hsel[2][1] = scitag SET scipart TO 1.
        LOCAL selprv TO HSEL[2][2].
        SET HSEL[2][2] TO CHANGESEL(HudOpts[2][2][0], hsel[2][2],seldir). 
        IF autoTRGList[0][HSEL[2][1]][hsel[2][2]] < 0{
          UNTIL autoTRGList[0][HSEL[2][1]][HSEL[2][2]] > -1 OR HSEL[2][2] = selprv{
          SET HSEL[2][2] TO CHANGESEL(HudOpts[2][2][0], hsel[2][2],seldir). 
          }
        }
        SET HSEL[2][3] TO 1.
        SET MtrPrtSel[1] TO 0.
      }
      IF rowval = 1 {
        LOCAL ys TO 0.
        IF mtrcur[7]:length > 0 {IF mtrcur[7][mtrcur[7]:length-1] = -2 SET ys TO 1.}
        IF hsel[2][1] = flytag AND hsel[2][2] = 1 SET ys TO 1.
          IF ys = 1 OR meterpart = 0{
            IF hsel[2][1] = WMGRtag AND meterlist[0][0] = "weapon"{getEvAct(prtlist[hsel[2][1]][hsel[2][2]][hsel[2][3]],"MissileFire","previous weapon",20).}ELSE{
            IF hsel[2][1] = anttag AND meterlist[0][0]:contains("target"){SET anttrgsel TO changesel(trglst[0], anttrgsel,seldir).}ELSE{


            IF hsel[2][1] = ISRUTag {SET ConvRSC TO changesel(isruoptlst[0], ConvRSC,seldir).
              SET hudopts[1][3] TO ToggleResConv(prtlist[hsel[2][1]][hsel[2][2]][hsel[2][3]],isruoptlst[ConvRSC],ConvRSC,2).}ELSE{
            IF hsel[2][1] = scitag {SET scipart TO changesel(SciDsp:length,scipart,seldir).}ELSE{
            IF hsel[2][1] = DcpTag  {SET RscSelection TO CHANGESEL(PRscList:length-1, RscSelection,seldir,0).
            }ELSE{
            IF hsel[2][1] = BDPTag  {adjust_Meter(prtlist[hsel[2][1]][hsel[2][2]], MtrCur[2], seldir, 1, hsel[2][1],  MtrCur[0], MtrCur[1]).}ELSE{
            IF hsel[2][1] = FlyTag  {
              SET HdngSet[0][(axsel)] TO ADDMAX(HdngSet[0][(axsel)],-AutoAdjByLst[AUTOHUD[1]], HdngSet[2][(axsel)], HdngSet[1][(axsel)]).
              IF ItmTrg = " SET TRGT " SET anttrgsel TO changesel(trglst[0], anttrgsel,seldir).
            }ELSE{
            IF mks =1{ 
              IF hsel[2][1] = pwrTag    {adjust_thrust(prtlist[hsel[2][1]][hsel[2][2]],0.1,seldir,2).}ELSE{
              IF hsel[2][1] = MksDrlTag {adjust_thrust(prtlist[hsel[2][1]][hsel[2][2]],0.1,seldir,2).}
            }
            }}}}}}}}
          }ELSE{IF MeterPart > 0 {adjust_Meter(prtlist[hsel[2][1]][hsel[2][2]], MtrCur[2], seldir, 4, hsel[2][1],  MtrCur[0], MtrCur[1]).}}
      }
      } 
      UPDATEHUDOPTS().
      }.SET BtnActn TO 0. SET forcerefresh TO 2.}  buttons:setdelegate(-5,buttonLeft@).
    
    FUNCTION buttonRight{lastin(). IF BtnActn=0{SET BtnActn TO 1. SET buttonRefresh TO 1. SET seldir TO "+".
      IF HUDOP = 5{SET AUTOHUD[1] TO CHANGESEL(AutoAdjByLst[0],AUTOHUD[1],seldir). SET HUDOPPREV TO 0. SET forcerefresh TO 2.}
      ELSE{ clearall(). SET forcerefresh TO 2.
      IF rowval = 0 {
        IF hsel[2][1] = scitag SET scipart TO 1.
        LOCAL selprv TO HSEL[2][2].
        SET HSEL[2][2] TO CHANGESEL(HudOpts[2][2][0], hsel[2][2],seldir). 
        IF autoTRGList[0][HSEL[2][1]][hsel[2][2]] < 0{
          UNTIL autoTRGList[0][HSEL[2][1]][HSEL[2][2]] > -1 OR HSEL[2][2] = selprv{
          SET HSEL[2][2] TO CHANGESEL(HudOpts[2][2][0], hsel[2][2],seldir). 
          }
        }
        SET HSEL[2][3] TO 1.
        SET MtrPrtSel[1] TO 0.
      }
      IF rowval = 1 {
        LOCAL ys TO 0.
        IF mtrcur[7]:length > 0 {IF mtrcur[7][mtrcur[7]:length-1] = -2 SET ys TO 1.}
        IF hsel[2][1] = flytag AND hsel[2][2] = 1 SET ys TO 1.
          IF ys = 1 OR meterpart = 0{
        IF hsel[2][1] = WMGRtag  AND meterlist[0][0] = "weapon"{IF prtlist[hsel[2][1]][hsel[2][2]][hsel[2][3]]:HASMODULE("MissileFire") IF prtlist[hsel[2][1]][hsel[2][2]][hsel[2][3]]:getmodule("MissileFire"):hasaction("next weapon") prtlist[hsel[2][1]][hsel[2][2]][hsel[2][3]]:GETMODULE("MissileFire"):doaction("next weapon", TRUE).}ELSE{
        IF hsel[2][1] = anttag AND meterlist[0][0]:contains("target"){SET anttrgsel TO changesel(trglst[0], anttrgsel,seldir).}ELSE{
        IF hsel[2][1] = ISRUTag {SET ConvRSC TO changesel(isruoptlst[0], ConvRSC,seldir).SET hudopts[1][3] TO ToggleResConv(prtlist[hsel[2][1]][hsel[2][2]][hsel[2][3]],isruoptlst[ConvRSC],ConvRSC,2).
        }ELSE{
        IF hsel[2][1] = scitag {SET scipart TO changesel(SciDsp:length,scipart,seldir).}ELSE{
        IF hsel[2][1] = DcpTag  {SET RscSelection TO CHANGESEL(PRscList:length-1, RscSelection,seldir,0).
        }ELSE{
        IF hsel[2][1] = BDPTag  {adjust_Meter(prtlist[hsel[2][1]][hsel[2][2]], MtrCur[2], seldir, 1, hsel[2][1],  MtrCur[0], MtrCur[1]).}ELSE{
        IF hsel[2][1] = FlyTag  {
          SET HdngSet[0][(axsel)] TO ADDMAX(HdngSet[0][(axsel)],AutoAdjByLst[AUTOHUD[1]], HdngSet[2][(axsel)], HdngSet[1][(axsel)]).
          IF ItmTrg = " SET TRGT " SET anttrgsel TO changesel(trglst[0], anttrgsel,seldir).
          }ELSE{
        IF mks =1{SET forcerefresh TO 2. IF hsel[2][1] = pwrTag  {adjust_thrust(prtlist[hsel[2][1]][hsel[2][2]],0.1,seldir,2).}ELSE{
            IF hsel[2][1] = MksDrlTag  {adjust_thrust(prtlist[hsel[2][1]][hsel[2][2]],0.1,seldir,2).}ELSE{
            }}
        }}}}}}}}//}
        }ELSE{IF MeterPart > 0 {adjust_Meter(prtlist[hsel[2][1]][hsel[2][2]], MtrCur[2], seldir, 4, hsel[2][1],  MtrCur[0], MtrCur[1]).}}
      }} 
      UPDATEHUDOPTS().
      }.SET forcerefresh TO 2. SET BtnActn TO 0.}  buttons:setdelegate(-6,buttonRight@).
    
    FUNCTION buttonEnter{lastin(). IF BtnActn=0{SET BtnActn TO 1. 
        IF HUDOP = 5{
          LOCAL adl TO  abs(AutoSetMode).
          IF adl > 4 AND adl < 8  IF AUTOHUD[0] > 100 SET autohud[0] TO 100.
          IF adl = 6 {SET autoRscList[hsel[2][1]][hsel[2][2]] TO  RscList[RscSelection][0].} 
          IF adl = 14 {SET AUTOHUD[0] TO StsSelection. SET AUTOHUD[2] TO "  OVER ". }
          IF adl = 15 {IF PRscList:length > 0 SET autoRscList[hsel[2][1]][hsel[2][2]] TO  RscSelection.}
            SET AutoValList[hsel[2][1]][hsel[2][2]] TO  AUTOHUD[0].
            SET AutoTRGList[hsel[2][1]][hsel[2][2]] TO AutoSetAct.
            SET autoRstList[hsel[2][1]][hsel[2][2]] TO AutoRstMode.
            SET AutoTRGList[0][hsel[2][1]][hsel[2][2]] TO setdelay.
            LOCAL rmstring TO hsel[2][1]+"-"+hsel[2][2]+"-"+0.
            LOCAL rmstring2 TO hsel[2][1]+"-"+hsel[2][2]+"-"+-1.
            FOR rmstring3 IN LIST(rmstring,rmstring2){
              IF AutoDspList[0][HDItmB][HDTagB]:contains (rmstring3) AutoDspList[0][HDItmB][HDTagB]:REMOVE  (AutoDspList[0][HDItmB][HDTagB]:find(rmstring3)).
              IF AutoDspList[0][HDItm][HDTag]:contains   (rmstring3) AutoDspList[0][HDItm][HDTag]:REMOVE     (AutoDspList[0][HDItm][HDTag]:find(rmstring3)).
            }
            IF dctnmode > 0 {
              SET AutoDspList[hsel[2][1]][hsel[2][2]] TO 0-abs(AutoSetMode).
              IF dctnmode = 2 {IF NOT AutoDspList[0][HDItm][HDTag]:contains(rmstring2) {AutoDspList[0][HDItm][HDTag]:ADD(rmstring2).} SET AutoDspList[hsel[2][1]][hsel[2][2]] TO 1.}
                ELSE{          IF NOT AutoDspList[0][HDItm][HDTag]:contains(rmstring)  {AutoDspList[0][HDItm][HDTag]:ADD(rmstring).}}
              LOCAL mde TO 1-dctnmode.
                SET AutoDspList[0][hsel[2][1]][hsel[2][2]][0] TO HDItm+"-"+HDtag+"-"+mde.
            }
            ELSE{
                SET AutoDspList[hsel[2][1]][hsel[2][2]] TO abs(AutoSetMode).
                SET AutoDspList[0][hsel[2][1]][hsel[2][2]][0] TO 0.
              }
               SET h5mode TO 0.
              SET AutoDspList[0][HDItm][HDTag] TO DEDUP(AutoDspList[0][HDItm][HDTag]).
              SET AutoDspList[0][HDItmB][HDTagB] TO DEDUP(AutoDspList[0][HDItmB][HDTagB]).
            
          IF AUTOHUD[2] = " UNDER " {SET UpDnOut TO 2. SET AutoValList[hsel[2][1]][hsel[2][2]] TO 0-AUTOHUD[0].}ELSE{SET UpDnOut TO 1.  SET AutoValList[hsel[2][1]][hsel[2][2]] TO AUTOHUD[0].}
          IF dbglog > 0{
              log2file("SAVE AUTO TRIGGER:"+ItemList[hsel[2][1]]+":"+prtTagList[hsel[2][1]][hsel[2][2]]).
              logauto(1).
          }
          SaveAutoSettings().
          SETHUD(). 
          UpdateAutoTriggers(UpDnOut,abs(AutoDspList[hsel[2][1]][hsel[2][2]]),hsel[2][1],hsel[2][2],1).
          SET buttonRefresh TO 1. 
          UPDATEHUDOPTS().
        }
        ELSE{
     IF rowval = 1 {
        IF  hsel[2][1] = SciTag{togglegroup(hsel[2][1],hsel[2][2],4).
        }ELSE{
        IF  hsel[2][1] = Flytag{
          IF hsel[2][2] = 1 {
            LOCAL lmt TO 3.
            IF axsel > 3 SET lmt TO AutoAdjByLst[0].
            SET AUTOHUD[1] TO CHANGESEL(lmt,AUTOHUD[1],"+").
          }
        }ELSE{
      IF  MeterPart > 0  {SET MtrCur[5] TO CHANGESEL(MtrCur[4],MtrCur[5],"+",MtrCur[3]). SET ActiveMeter[hsel[2][1]] TO MtrCur[5]. SET newhud TO 2.
        }ELSE{
        IF mks = 1 {
          IF hsel[2][1] = PWRtag {IF HDXT = "BAY " {SET BaySel TO CHANGESEL(BayLst[0],BaySel,"+"). }}
        }}}}
        SET forcerefresh TO 1. 
        UPDATEHUDOPTS().
        }
    }
    }. SET BtnActn TO 0.}  buttons:setdelegate(-1,buttonEnter@).
    
    FUNCTION buttonCancel{lastin(). IF BtnActn=0{SET BtnActn TO 1. 
    IF HUDOP = 5{
      SET AUTOHUD TO AUTOHUDBK. SETHUD().
        IF dbglog > 0{
            log2file("CANCEL EDIT AUTO TRIGGER "+ItemList[hsel[2][1]]+":"+prtTagList[hsel[2][1]][hsel[2][2]]).
            logauto().
            clearto(1,16). 
        }
      }
      ELSE{
        IF hudop < 7 {
          SET HUDOP TO 5.
          SET h5mode TO 0.
          SET RscSelection TO 0.
          SET AUTOHUDBK TO AUTOHUD. clearto(1,14).  clearall().
          SET AUTOHUD[0] TO ABS(AutoValList[hsel[2][1]][hsel[2][2]]).
          IF autoRscList[hsel[2][1]][hsel[2][2]]<>0{SET RscSelection TO safekey(RscNum,autoRscList[hsel[2][1]][hsel[2][2]]) .}
          SET setdelay TO AutoTRGList[0][hsel[2][1]][hsel[2][2]].
          SET AutoSetMode TO abs(AutoDspList[hsel[2][1]][hsel[2][2]]).
          IF AutoDspList[hsel[2][1]][hsel[2][2]] > 0  SET dctnmode TO 0. ELSE  {SET dctnmode TO 1.}
          IF AutoDspList[0][hsel[2][1]][hsel[2][2]][0] <> 0 {
            LOCAL splt TO AutoDspList[0][hsel[2][1]][hsel[2][2]][0]:split("-").
            SET HDItm TO splt[0]:tonumber. SET HDItmB TO HDItm.
            SET HDTag TO splt[1]:tonumber. SET HDTagB TO HDTag.
            IF splt:length = 3 SET dctnmode TO 1.
            IF splt:length = 4 SET dctnmode TO 2.
          }
          SET AutoSetAct TO AutoTRGList[hsel[2][1]][hsel[2][2]].
          SET AutoRstMode TO autoRstList[hsel[2][1]][hsel[2][2]].
          IF AutoValList[hsel[2][1]][hsel[2][2]] > 0 SET UDO TO 1. ELSE SET UDO TO 2.
          ClearAuto(hsel[2][1],hsel[2][2],UDO,AutoSetMode,1).
            IF dbglog > 0{
                log2file("EDIT AUTO TRIGGER "+ItemList[hsel[2][1]]+":"+prtTagList[hsel[2][1]][hsel[2][2]]).
              logauto().
          }
        }ELSE{SET forcerefresh TO 1.
          IF meterpart = 2 {CycleAjdBy(). SET forcerefresh TO 2.}
          IF  hsel[2][1]= Flytag {SET apsel TO CHANGESEL(aplim,apsel,"+"). SET forcerefresh TO 1.}
        }
      }
    SET buttonRefresh TO 1.
    UPDATEHUDOPTS().
    }.SET BtnActn TO 0.}  buttons:setdelegate(-2,buttonCancel@).
    
    FUNCTION button16{lastin(). IF BtnActn=0{SET BtnActn TO 1. SET isDone TO 1.}.SET BtnActn TO 0.}  buttons:setdelegate(13,button16@).
    //#endregion buttons
    LOCAL ch TO "".
    UNTIL isDone > 0 {
      IF kuniverse:timewarp:issettled = TRUE {
        IF WARP > 0 AND WARPMODE = "RAILS" AND SHIP:CONTROL:PILOTMAINTHROTTLE > 0 SET THRTFIX TO 1.
        IF THRTFIX = 1 {
          IF WARP < 1{
            UNTIL SHIP:CONTROL:PILOTMAINTHROTTLE = THRTPREV {SET SHIP:CONTROL:PILOTMAINTHROTTLE TO THRTPREV.}
            SET THRTFIX TO 0.
            IF dbglog > 0 log2file("POST WARP THROTTLE SET TO "+THRTPREV).
            PRINTLINE("PRE-WARP THROTTLE LEVEL RESTORED "+THRTPREV,"WHT").
          }
        }
        ELSE{IF warp = 0 SET THRTPREV TO SHIP:CONTROL:PILOTMAINTHROTTLE.}
      }
      IF PRINTQ:LENGTH > 0 {IF printpause = 0  IF PRINTQ:LENGTH > 1 SET refreshRateSlow TO 2. PrintTheQ().}
      IF LastIn(-5) SET refreshRateSlow TO 1.
      IF TIME:SECONDS - refreshTimer2 > refreshRateSlow-.01{
        UpdateMeterLeft().
        IF saveflag = 1 {
          IF alltagged:length <> SHIP:ALLTAGGEDPARTS():length partcheck(). 
          IF STATUSSAVE:CONTAINS(SHIP:STATUS) OR TIME:SECONDS-checktime > 90 SaveAutoSettings().
          }
        //UPDATEHUDSLOW().
        UPDATESTATUSROW(). 
        SET refreshTimer2 TO TIME:SECONDS.
        SET printpause TO 0.
        IF PRINTQ:LENGTH = 0 SET refreshRateSlow TO RFSBAak.
      }
      LOCAL hdchk TO  HdngSet[3][4]+ HdngSet[3][5]+ HdngSet[3][6].
      IF steeringmanager:enabled = TRUE IF hdchk <> 0 IF abs(SteeringManager:ANGLEERROR) < 5 ap().
      SET VSPDPRV TO SHIP:verticalspeed.
      SET SPDPRV TO SHIP:VELOCITY:SURFACE:MAG.
      SET ALTPRV TO SHIP:ALTITUDE.
    //#region check auto
    IF steeringmanager:enabled = TRUE AND SAS = TRUE UNLOCK STEERING.
    IF AUTOBRAKE = 0 SET BRAKES TO FALSE. ELSE
    IF AUTOBRAKE = 1 SET BRAKES TO TRUE. ELSE
    IF AUTOBRAKE = 2 {
      IF  SHIP:STATUS = "LANDED" OR SHIP:STATUS = "PRELAUNCH"{IF THROTTLE > 0.4999{SET BRAKES TO FALSE.}ELSE{SET BRAKES TO TRUE.}}ELSE{SET BRAKES TO FALSE.}
    }
    IF RunAuto = 0{
      LOCAL SWAP TO 0.
      IF IsPayload[1] = core:part{SET SWAP TO 1.}
      ELSE{IF IsPayload[1]:isdecoupled = TRUE SET SWAP TO 1.}
      IF SWAP = 1 {
        SET RunAuto TO 1.
        SET refreshRateSlow TO autovallist[0][0][4][0].
        SET refreshRateFast TO autovallist[0][0][4][1].        
        FOR i IN range(1,10){PRINTLINE("CONTROL ENABLING IN "+10-I+" SECONDS   ","WHT"). WAIT 1.}
        ISRUcheck().
         PRINTLINE("",0,14).
      }
    }
    ELSE{
      IF HUDOP <> 5 AND RUNAUTO = 1{
        SpeedBoost("on",1).
        LOCAL trg TO 0. 
        //check auto spd.
        IF checkautotrigger(SpdTrgsUP)  <> 0{SET trg TO MIN(SpdTrgsUP[0],SpdTrgsUP[1]).       IF trg = 0 SET trg TO SpdTrgsUP[1]. IF trg <> 0 AND SHIP:VELOCITY:SURFACE:MAG > trg TriggerAuto(AutoitemLst[2][1],2,trg,1,1).}
        IF checkautotrigger(SpdTrgsDN)  <> 0{SET trg TO MAX(SpdTrgsDN[0],SpdTrgsDN[1]).       IF trg = 0 SET trg TO SpdTrgsDN[0]. IF trg <> 0 AND SHIP:VELOCITY:SURFACE:MAG < trg TriggerAuto(AutoitemLst[2][2],2,trg,2,1).}
        //check auto ALT.
        IF checkautotrigger(ALTTrgsUP)  <> 0{SET trg TO MIN(ALTTrgsUP[0],ALTTrgsUP[1]).       IF trg = 0 SET trg TO ALTTrgsUP[1]. IF SHIP:ALTITUDE > trg  TriggerAuto(AutoitemLst[3][1],3,trg,1,1).}
        IF checkautotrigger(ALTTrgsDN)  <> 0{SET trg TO MAX(ALTTrgsDN[0],ALTTrgsDN[1]).       IF trg = 0 SET trg TO ALTTrgsDN[0]. IF SHIP:ALTITUDE < trg TriggerAuto(AutoitemLst[3][2],3,trg,2,1).}
        //check auto AGL.
        IF checkautotrigger(AGLTrgsUP)  <> 0{SET trg TO MIN(AGLTrgsUP[0],AGLTrgsUP[1]).       IF trg = 0 SET trg TO AGLTrgsUP[1]. IF ALT:RADAR > trg  TriggerAuto(AutoitemLst[4][1],4,trg,1,1).}
        IF checkautotrigger(AGLTrgsDN)  <> 0{SET trg TO MAX(AGLTrgsDN[0],AGLTrgsDN[1]).       IF trg = 0 SET trg TO AGLTrgsDN[0]. IF ALT:RADAR < trg TriggerAuto(AutoitemLst[4][2],4,trg,2,1).}
        //check auto EC.
        IF checkautotrigger(ECTrgsUP)   <> 0{SET trg TO MIN(ECTrgsUP[0],ECTrgsUP[1]).         IF trg = 0 SET trg TO ECTrgsUP[1].  IF ROUND(SHIP:ELECTRICCHARGE/ecmax*100,0) > trg  TriggerAuto(AutoitemLst[5][1],5,trg,1,1).}
        IF checkautotrigger(ECTrgsDN)   <> 0{SET trg TO MAX(ECTrgsDN[0],ECTrgsDN[1]).         IF trg = 0 SET trg TO ECTrgsDN[0].  IF ROUND(SHIP:ELECTRICCHARGE/ecmax*100,0) < trg  TriggerAuto(AutoitemLst[5][2],5,trg,2,1).}
        //check auto Rsc.
        IF  checkautotrigger(RscTrgsUP) <> 0{SET trg TO MIN(RscTrgsUP[0],RscTrgsUP[1]).       IF trg = 0 SET trg TO RscTrgsUP[1]. TriggerAuto(AutoitemLst[6][1],6,trg,1,2).}
        IF  checkautotrigger(RscTrgsDN) <> 0{SET trg TO MAX(RscTrgsDN[0],RscTrgsDN[1]).       IF trg = 0 SET trg TO RscTrgsDN[0]. TriggerAuto(AutoitemLst[6][2],6,trg,2,2).}
        //check auto throttle.
        IF  checkautotrigger(ThrtTrgsUP) <>0 {SET trg TO MIN(ThrtTrgsUP[0],ThrtTrgsUP[1]).    IF trg = 0 SET trg TO ThrtTrgsUP[1]. IF THROTTLE > (TRG*.01) TriggerAuto(AutoitemLst[7][1],7,trg,1,1).}
        IF  checkautotrigger(ThrtTrgsDN) <>0 {SET trg TO MAX(ThrtTrgsDN[0],ThrtTrgsDN[1]).    IF trg = 0 SET trg TO ThrtTrgsDN[0]. IF THROTTLE < (TRG*.01) TriggerAuto(AutoitemLst[7][2],7,trg,2,1).}
        //check auto Pressure.
        IF senselist[3] = 1{
          IF  checkautotrigger(PresTrgsUP) <> 0 {SET trg TO MIN(PresTrgsUP[0],PresTrgsUP[1]). IF trg = 0 SET trg TO PresTrgsUP[1]. IF SHIP:SENSORS:PRES > TRG TriggerAuto(AutoitemLst[8][1],8,trg,1,1).  }
          IF  checkautotrigger(PresTrgsDN) <> 0 {SET trg TO MAX(PresTrgsDN[0],PresTrgsDN[1]). IF trg = 0 SET trg TO PresTrgsDN[0]. IF SHIP:SENSORS:PRES < TRG TriggerAuto(AutoitemLst[8][2],8,trg,2,1).  }
        }
        //check auto Sun.
        IF senselist[2] = 1{
          IF  checkautotrigger(SunTrgsUP) <> 0 {SET trg TO MIN(SunTrgsUP[0],SunTrgsUP[1]).    IF trg = 0 SET trg TO SunTrgsUP[1].  IF SHIP:SENSORS:LIGHT > (TRG*.01) TriggerAuto(AutoitemLst[9][1],9,TRG,1,1).  }
          IF  checkautotrigger(SunTrgsDN) <> 0 {SET trg TO MAX(SunTrgsDN[0],SunTrgsDN[1]).    IF trg = 0 SET trg TO SunTrgsDN[0].  IF SHIP:SENSORS:LIGHT < (TRG*.01) TriggerAuto(AutoitemLst[9][2],9,TRG,2,1).  }
        }
        //check auto Temp.
        IF senselist[4] = 1{
          IF checkautotrigger(TempTrgsUP) <> 0 {SET trg TO MIN(TempTrgsUP[0],TempTrgsUP[1]).  IF trg = 0 SET trg TO TempTrgsUP[1]. IF SHIP:SENSORS:TEMP > TRG TriggerAuto(AutoitemLst[10][1],10,trg,1,1).}
          IF checkautotrigger(TempTrgsDN) <> 0 {SET trg TO MAX(TempTrgsDN[0],TempTrgsDN[1]).  IF trg = 0 SET trg TO TempTrgsDN[0]. IF SHIP:SENSORS:TEMP < TRG TriggerAuto(AutoitemLst[10][2],10,trg,2,1).}
        }
        //check auto Grav.
        IF senselist[1] = 1{
          IF checkautotrigger(GravTrgsUP) <> 0 {SET trg TO MIN(GravTrgsUP[0],GravTrgsUP[1]).  IF trg = 0 SET trg TO GravTrgsUP[1]. IF ROUND(SHIP:sensors:grav:MAG,1) > (TRG*.01) TriggerAuto(AutoitemLst[11][1],11,TRG,1,1).}
          IF checkautotrigger(GravTrgsDN) <> 0 {SET trg TO MAX(GravTrgsDN[0],GravTrgsDN[1]).  IF trg = 0 SET trg TO GravTrgsDN[0]. IF ROUND(SHIP:sensors:grav:MAG,1) < (TRG*.01) TriggerAuto(AutoitemLst[11][2],11,TRG,2,1).}
        }
        //check auto ACC.
        IF senselist[0] = 1{
          IF checkautotrigger(ACCTrgsUP) <> 0  {SET trg TO MIN(ACCTrgsUP[0],ACCTrgsUP[1]).    IF trg = 0 SET trg TO ACCTrgsUP[1].  IF ROUND(SHIP:sensors:acc:MAG,1) > (TRG*.01) TriggerAuto(AutoitemLst[12][1],12,TRG,1,1).}
          IF checkautotrigger(ACCTrgsDN) <> 0  {SET trg TO MAX(ACCTrgsDN[0],ACCTrgsDN[1]).    IF trg = 0 SET trg TO ACCTrgsDN[0].  IF ROUND(SHIP:sensors:acc:MAG,1) < (TRG*.01) TriggerAuto(AutoitemLst[12][2],12,TRG,2,1).}
        }
        //check auto TWR.
          IF checkautotrigger(TWRTrgsUP) <> 0  {SET trg TO MIN(TWRTrgsUP[0],TWRTrgsUP[1]).    IF trg = 0 SET trg TO TWRTrgsUP[1].  IF twr > (TRG*.01) TriggerAuto(AutoitemLst[13][1],13,TRG,1,1).}
          IF checkautotrigger(TWRTrgsDN) <> 0  {SET trg TO MAX(TWRTrgsDN[0],TWRTrgsDN[1]).    IF trg = 0 SET trg TO TWRTrgsDN[0].  IF twr < (TRG*.01) TriggerAuto(AutoitemLst[13][2],13,TRG,2,1).}
        //check auto Status. 
          IF SHIP:STATUS <> ShipStatPREV2  OR MAX(StsTrgsUP[0],StsTrgsUP[1])>8{
            IF checkautotrigger(StsTrgsUP) <> 0 {SET trg TO MIN(StsTrgsUP[0],StsTrgsUP[1]).
              IF trg = 0 SET trg TO StsTrgsUP[1].  IF AutoitemLst[14][1]:length > 1 {
                IF StsTrgs:contains(statusopts:find(SHIP:STATUS)) OR MAX(StsTrgsUP[0],StsTrgsUP[1])>8{
                  TriggerAuto(AutoitemLst[14][1],14,TRG,1,3).
                } ELSE{SET ShipStatPREV2 TO SHIP:STATUS.}
              }
            }
          }
        //check Auto fuel 
        IF dcptag <> 0 {IF checkautotrigger(FuelTrgsDN) <> 0 OR checkautotrigger(FuelTrgsUP) <> 0 CheckDcpFuel().}
        SpeedBoost("off").
      } 
      //#endregion
      }
      //#region refresh 
      IF BtnActn = 0 {
      IF loadattempts > 0 AND buttonRefresh > 0 AND TIME:SECONDS-boottime > 30{SET loadattempts TO -1.  sendboot().}
      IF buttonRefresh > 0 updatehudSlow().
      IF BUTTONREFRESH > 1 {IF forcerefresh = 0 SET FORCEREFRESH TO 1.}
      //IF BUTTONREFRESH > 2 {updatehudSlow(). UPDATEHUDOPTS(). SET FORCEREFRESH TO 2. SET refreshTimer2 to TIME:SECONDS.}
      IF BUTTONREFRESH > 2 {updatehudSlow(). SET FORCEREFRESH TO 2. SET refreshTimer2 TO TIME:SECONDS.}
      IF SHIP:STATUS <> ShipStatPREV UPDATEHUDOPTS().
      //if  forcerefresh > 1 {UPDATEHUDOPTS().}
      IF  (forcerefresh > 0 OR newhud > 0) AND ActionWait = 0 {UPDATEHUDOPTS().}
      SET forcerefresh TO 0.
      
}

      IF TIME:SECONDS - refreshTimer > refreshRateFast-.01 OR buttonRefresh > 0 {
        updatehudFast(). 
        IF prtcount <> SHIP:PARTS:LENGTH {SET saveflag TO 1.}.
        SET refreshTimer TO TIME:SECONDS.
        SET buttonRefresh TO 0.
        SET AgState TO LIST(AG1,ag2,ag3,ag4,ag5,ag6,ag7,ag8,ag9,ag10,0,RCS,ABORT,GEAR,LIGHTS,BRAKES).
        CheckAGs().
      }   
      IF ActionQNew:length > 0 {
        LOCAL acqrm TO LIST().
        LOCAL AACQ TO ActionQNew:COPY.
        LOCAL np TO LIST(99,99,99,99).
        FOR n IN AACQ {
          IF n[3] = 0 AND np[3] = 0 AND n[1] = np[1] AND n[2] = np[2] {acqrm:ADD(n).}
          ELSE{
            IF n[0] < TIME:SECONDS{
              SET BtnActn TO 1. 
              ToggleGroup(n[1],n[2],n[3],2).
              acqrm:ADD(n).
              SET BtnActn TO 0. 
            }
          }
          SET np TO n.
        }
        FOR n IN acqrm {IF ActionQNew:contains(n) ActionQNew:REMOVE(ActionQNew:find(n)).}
        UPDATESTATUSROW().
      }
      //#endregion
      //#region terminal
      IF terminal:input:haschar {IF BtnActn = 0 SET ch TO terminal:input:getchar().}
      IF ch = "6"  {buttonRight().SET ch TO "".}
      IF ch = "4"  {buttonLeft().SET ch TO "".}
      IF ch = "8"  {buttonUp().SET ch TO "".}
      IF ch = "2"  {buttonDown().SET ch TO "".}
      IF ch = "7"  {button7().SET ch TO "".}
      IF ch = "1" AND  BtnActn = 0 {button10().SET ch TO "".}
      IF ch = "9"  {button9().SET ch TO "".}
      IF ch = "3" AND  BtnActn = 0 {button11().SET ch TO "".}
      IF ch = "5" AND  BtnActn = 0 {button8().SET ch TO "".}
      IF ch = "+"  {SET ch TO "".}      
      IF ch = "-"  {SET ch TO "".}
      //#endregion terminal
    WAIT 0.001.
    }
    //clearscreen.
	}
}
FUNCTION logauto{
  LOCAL PARAMETER OPT IS 0.
  LOCAL dl TO "".
  LOCAL av TO "".
  LOCAL AT TO "".
  LOCAL ar TO "".
  LOCAL MD TO "".
  IF OPT = 1{
    SET av TO " SET TO "+AUTOHUD[0].
    SET AT TO " SET TO "+AutoSetAct.
    SET ar TO " SET TO "+AutoRstMode.
    SET DL TO " SET TO "+ setdelay.
    SET MD TO " SET TO "+abs(AutoSetMode).
  }
  LOCAL RSCSL TO safekey(RscNum,autoRscList[hsel[2][1]][hsel[2][2]]).
  log2file("    AutoValList[hsel[2][1]][hsel[2][2]](TRG VALUE  ):"+AutoValList[hsel[2][1]][hsel[2][2]]+AV).
  log2file("    AutoTRGList[hsel[2][1]][hsel[2][2]](ACTION     ):"+AutoTRGList[hsel[2][1]][hsel[2][2]]+" - "+actnlist[AutoTRGList[hsel[2][1]][hsel[2][2]]]+AT).
  log2file("    autoRstList[hsel[2][1]][hsel[2][2]](RESET MODE ):"+autoRstList[hsel[2][1]][hsel[2][2]]+" - "+HudRstMdLst[autoRstList[hsel[2][1]][hsel[2][2]]]+AR).
  log2file("    AutoDspList[hsel[2][1]][hsel[2][2]](AUTO MODE  ):"+AutoDspList[hsel[2][1]][hsel[2][2]]+" - "+MODELONG[abs(AutoDspList[hsel[2][1]][hsel[2][2]])]+MD).
  log2file("    AutoTRGList[0][hsel[2][1]][hsel[2][2]](DELAY   ):"+AutoTRGList[0][hsel[2][1]][hsel[2][2]]+dl).
  IF AutoDspList[0][hsel[2][1]][hsel[2][2]][0] <> 0 log2file("    AutoDspList[0][hsel[2][1]][hsel[2][2]][0](WAIT4):"+AutoDspList[0][hsel[2][1]][hsel[2][2]][0]).
  IF AutoDspList[hsel[2][1]][hsel[2][2]] = 6 {
    log2file("    autoRscList[hsel[2][1]][hsel[2][2]](RSC SEL    ):"+autoRscList[hsel[2][1]][hsel[2][2]]+" - "+RscList[RSCSL][0]).
  }
  IF AutoDspList[hsel[2][1]][hsel[2][2]] = 15 AND PRscList:LENGTH > 0{
    log2file("    autoRscList[hsel[2][1]][hsel[2][2]](RSC SEL    ):"+autoRscList[hsel[2][1]][hsel[2][2]]+" - "+PRscList[RSCSL][0]).
  }
  IF AutoDspList[hsel[2][1]][hsel[2][2]] < 0 AND AutoDspList[0][hsel[2][1]][hsel[2][2]][0]:tostring <> "0"{
    IF HDItm <> HDItmB OR HDTag <> HDTagB {
      log2file("    AutoDspList[0][HDItmB][HDTagB](WAIT 4 GRP OUT  ):"+AutoDspList[0][HDItmB][HDTagB]+" - "+REMOVESPECIAL(ItemListHUD[HdItmb]," ")+":"+Prttaglist[HdItmb][hdtagb]).
      log2file("    AutoDspList[0][HDItm][HDTag]( WAIT 4 GROUP IN  ):"+AutoDspList[0][HDItm][HDTag]+ " - "+ REMOVESPECIAL(ItemListHUD[HdItm]," ")+":"+Prttaglist[HdItm][hdtag]).
    }IF AutoDspList[0][hsel[2][1]][hsel[2][2]][0] <> 0 {
    LOCAL splt TO AutoDspList[0][hsel[2][1]][hsel[2][2]][0]:split("-").
    IF splt:length = 3 log2file( "WONT START DETECTION UNTIL AFTER "+REMOVESPECIAL(ItemListHUD[HdItm]," ")+":"+Prttaglist[HdItm][hdtag]+" IS TRIGGERED").
    IF splt:length = 4 log2file( "WILL TRIGGER WHEN "+REMOVESPECIAL(ItemListHUD[HdItm]," ")+":"+Prttaglist[HdItm][hdtag]+" IS TRIGGERED").
    }
  }
}
//#region AP
FUNCTION AP{// if up 2 fast not turning dn
        LOCAL spd TO SHIP:VELOCITY:SURFACE:MAG.
        IF SHIP:verticalspeed > VSPDPRV SET VrtDIR TO 1. ELSE SET VrtDIR TO -1.
        IF spd                >  SPDPRV SET SpdDIR TO 1. ELSE SET SpdDIR TO -1.
        IF SHIP:ALTITUDE      >  ALTPRV SET AltDIR TO 1. ELSE SET AltDIR TO -1.
        IF HdngSet[0][4] > 0 SET HLIM TO HdngSet[0][4]. ELSE SET HLIM TO HLIMSTRT.
        LOCAL altprob TO 0.
        SET AltSet TO HdngSet[0][5].
        IF SHIP:ALTITUDE > AltSet SET altprob TO 1.
        IF SHIP:ALTITUDE < AltSet SET altprob TO -1.
        IF HdngSet[0][6] > 0 SET VLIM TO HdngSet[0][6]. ELSE SET VLIM TO VLIMSTRT.
        IF HdngSet[0][7] > 0 SET plim TO HdngSet[0][7]. ELSE SET plim TO PLIMSTRT.
        IF HdngSet[0][8] > 0 SET LLIM TO HdngSet[0][8]. ELSE SET LLIM TO LLIMSTRT.
        //LOCAL MLT TO min(ABS(SHIP:verticalspeed)/VLIM,1).
        LOCAL mlt TO 1.
        LOCAL PitchCur TO ROUND(compass_and_pitch_for()[1],0).
        LOCAL PitchTrg TO HdngSet[0][2].
        LOCAL plimcur TO plim.//+plimadj.
        LOCAL ptset TO abs(PitchCur)+ABS(flyadj[2]).//+plimadj.
        LOCAL vprob TO 0. IF abs(SHIP:verticalspeed) > VLIM*MLT SET vprob TO 1.
        LOCAL ndir TO 1.     IF PitchCur < 0 SET ndir TO -1.
        LOCAL spdprob TO 0.
        IF SHIP:CONTROL:PILOTMAINTHROTTLE < .05 AND spd > Hlim AND PitchCur < 0 SET spdprob TO 1.
        IF SHIP:CONTROL:PILOTMAINTHROTTLE > .95 AND spd < llim*1.05 AND SpdDIR=-1 SET spdprob TO -1.
        LOCAL plimprob TO 0. IF plimcur < PitchCur SET plimprob TO 1.
        IF HdngSet[3][4] > 0 { //speed
          LOCAL thradj TO 3*(1-(MIN(spd,HLIM)/MAX(spd,HLIM))).
          LOCAL spdclose TO 0.
          IF GetRange(spd, HdngSet[0][4],10) {SET spdclose TO 1. SET thradj TO thradj * 2.}
          IF SpdDIR = 1 {
            IF spd > HLIM Throtadj(SHIP:CONTROL:PILOTMAINTHROTTLE-thradj).
            IF SHIP:CONTROL:PILOTMAINTHROTTLE = 1 AND NOT spdclose = 1 AND PitchCur < plimcur+1 AND spdprob > 0 pitchadj(01).//set plimadj to min(plimadj+1,0).
          }
          ELSE{
            IF SHIP:CONTROL:PILOTMAINTHROTTLE = 1 {IF PitchCur > 0 AND NOT spdclose = 1 AND spdprob <  0 pitchadj(-01).}// set plimadj to plimadj-1.}
            ELSE{ IF spd < HLIM Throtadj(SHIP:CONTROL:PILOTMAINTHROTTLE+thradj).}
          }
        }
        IF HdngSet[3][5] > 0 {//alt          
            LOCAL adj TO 3.
            IF GetRange(SHIP:ALTITUDE, AltSet,2)  {SET adj TO 1. SET plimcur TO plim/10.}ELSE{
            IF GetRange(SHIP:ALTITUDE, AltSet,5)  {SET adj TO 1. SET plimcur TO plim/6.}ELSE{
            IF GetRange(SHIP:ALTITUDE, AltSet,10) {SET adj TO 1. SET plimcur TO plim/3.}ELSE{
            IF GetRange(SHIP:ALTITUDE, AltSet,15) {SET adj TO 2. SET plimcur TO plim/2.}}}}
            SET plim TO CEILING(plim).
            IF plimcur < PitchCur SET plimprob TO 1.
            LOCAL Vprob2 TO 0.
            IF vprob = 1 AND PitchCur > 3 SET Vprob2 TO 1.
            IF altprob = 1 {IF plimprob = 0 AND vprob = 0                     {IF DBGLOG > 1  log2file(" ALT CHK 1 DN"). pitchadj(0-adj).} ELSE {IF DBGLOG > 1  log2file(" ALT CHK 1 UP"). pitchadj(adj).  }}
            IF altprob =-1 {IF plimprob = 0 AND spdprob > -1 AND  Vprob2 = 0 {IF DBGLOG > 1  log2file(" ALT CHK 2 UP"). pitchadj(adj).}   ELSE {IF DBGLOG > 1  log2file(" ALT CHK 2 DN"). pitchadj(0-adj).}}
          }
        IF HdngSet[3][6] > 0 {IF abs(SHIP:verticalspeed) > VLIM pitchadj(-AltDIR).}

        FUNCTION pitchadj{
          LOCAL PARAMETER amt IS 1.
          SET flyadj[2] TO flyadj[2]+amt.
          IF ndir > 0 IF flyadj[2]+PitchTrg > plimcur {  SET flyadj[2] TO plimcur-PitchTrg.   IF DBGLOG > 0  log2file(" LIM ADJ UP").}
          IF ndir < 0 IF flyadj[2]+PitchTrg < 0-plimcur {SET flyadj[2] TO 0-plimcur-PitchTrg. IF DBGLOG > 0  log2file(" LIM ADJ DN").}
          IF DBGLOG > 1 IF amt > 0 LogAP("    PITCH ADJ UP: "+amt). ELSE LogAP("    PITCH ADJ DN:"+amt).
        }
        FUNCTION Throtadj{
          LOCAL PARAMETER st.
          SET SHIP:CONTROL:PILOTMAINTHROTTLE TO st.
          IF DBGLOG > 0 log2file("   THRTL SET TO: "+st).
        }
        FUNCTION LogAP{
          LOCAL PARAMETER str IS "".
          IF str <> "" log2file(str).
          log2file("      THROTTLE:"+SHIP:CONTROL:PILOTMAINTHROTTLE).
          log2file("      SPEED:"+ROUND(spd,0)+" spdlim:"+Hlim+" spdmin:"+LLIM).
          log2file("      ALTITUDE:"+ROUND(SHIP:ALTITUDE,0)+" ALTSET:"+ HdngSet[0][5]).
          log2file("      VERTICAL SPEED:"+ROUND(SHIP:VERTICALSPEED,0)+" VLIM:"+vlim+" MLT:"+ROUND(mlt,2)+" VLIM*MLT:"+ROUND(VLIM*MLT,2)).
          log2file("      VrtDIR:"+VrtDIR+"  SpdDIR:"+SpdDIR+"  AltDIR:"+AltDIR).
          log2file("      PITCH:"+PitchCur+" PLimCur:"+plimcur+" PTSET:"+HdngSet[0][2]+" PADJ:"+FLYADJ[2]).//+" Padj2:"+plimadj).
          log2file("      spdprob:"+spdprob+" vprob:"+vprob+" altprob:"+altprob+" plimprob:"+plimprob).
          log2file("      hdngset[3]:"+LISTTOSTRING(hdngset[3])).
        }
    }
//#endregion
//#region string ops
FUNCTION clearall{
  PRINTLINE("",0,15).  PRINTLINE("",0,16).  PRINTLINE().
}
FUNCTION GetColor{ //GetColor("STR", "RED")
  LOCAL PARAMETER StrIn, clr IS "GRN", opt IS 1.
  IF colorprint = 0  RETURN strin.
  LOCAL colp TO "". LOCAL colpo TO "".
  IF clr = 0 SET clr TO "GRN".
  IF clr = "GRN" AND opt = 2 RETURN strin.
  IF clr = 4 SET clr TO "WHT".
  IF clr = 3 SET clr TO "ORN".
  IF clr = 2 SET clr TO "RED".
  IF clr = 1 SET clr TO "CYN".
    IF FindCl:HASKEY(clr) {
      IF StrIn:LENGTH > widthlim-20 SET OPT TO 0.
      IF opt = 1 OR opt = 2 SET colpo TO "{COLOR}".
      SET colp TO  FindCl[clr].
      IF dbglog > 3 log2file("        GETCOLOR:"+strin+" CLR:"+CLR+" OPT:"+opt+ " OUT:"+colp+StrIn+colpo).
    }ELSE RETURN StrIn.
  RETURN colp+StrIn+colpo.
}
FUNCTION PrintTheQ{
  LOCAL PLN TO PRINTQ:POP:split("<sp>").
  PRINTLINE(PLN[0],PLN[1]).
  IF dbglog > 1 log2file("PRINT:"+PLN[0]).
  SET printpause TO 1.
  SET refreshTimer2 TO TIME:SECONDS.
}
FUNCTION Removespecial{
  LOCAL PARAMETER input, toRemove IS "%".
  IF input:typename = "String"{
    IF toRemove = "%" {SET input TO input:REPLACE(toRemove, " Percent").}ELSE{
    SET input TO input:REPLACE(toRemove, "").}}
  RETURN input.
}
FUNCTION formatTime{
  LOCAL PARAMETER t, OP IS 0.
  IF T < 0 RETURN "PASSED".
  LOCAL h IS 0.
  LOCAL dy IS 0.
  LOCAL FTAns IS "".
  LOCAL m IS FLOOR(t/60). 
  LOCAL s IS FLOOR(t-m*60).
  IF m > 60 {
    SET h TO FLOOR(m/60).
    SET m TO FLOOR(m-(h*60)).
  }
   IF h > 24 {
    SET dy TO FLOOR(h/24).
    SET h TO FLOOR(h-(dy*24)).
  }
    IF dy> 0  SET FTAns TO FTAns+"0"+dy + "DY:".
    IF h > 0  SET FTAns TO FTAns+"0"+h + ":". ELSE IF OP = 1 SET FTAns TO FTAns+ "00:".
    IF FLOOR(m) > 9 SET FTAns TO FTAns+ m. ELSE SET FTAns TO FTAns+ "0" + m.
    IF FLOOR(s) > 9 SET FTAns TO FTAns+ ":" + s. ELSE SET FTAns TO FTAns+ ":0" + s.
  RETURN FTAns.
}
FUNCTION log2file{
  LOCAL PARAMETER str.
  LOG formattime(TIME:SECONDS-boottime,1)+":  "+str TO DebugLog.
}
FUNCTION PRINTLINE{
LOCAL PARAMETER WORD IS "",cl IS 0, line IS 17.
IF CL = "GRN" SET CL TO 0.
IF line <> 14 PRINT BIGEMPTY2 AT (1,line). ELSE PRINT BIGEMPTY AT (1,line).
IF line > heightlim-2 PRINT " " AT (line,widthlim).
IF word <> "" {
  IF colorprint > 0 AND cl <> 0 SET word TO getcolor(word,cl).
  PRINT WORD AT (1,line).}
  IF dbglog > 1{IF word <> "" log2file("   PRINTLINE:"+WORD+" AT("+line+")"). ELSE IF dbglog > 1 log2file("   CLEARLINE:("+line+")").}
}
FUNCTION makehud{
  LOCAL PARAMETER word, lim IS 9.
  UNTIL word:length>lim{SET word TO " "+word+" ".}
  IF word:length>lim SET word TO word:substring(0,lim+1).
  RETURN word.
}
FUNCTION RemoveLetters{
  LOCAL PARAMETER input,toRemove IS "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ%:".
  IF input:istype("scalar") RETURN input:tostring.
  FOR i IN range(0, toRemove:length) {SET input TO input:REPLACE(toRemove[I], "").}
  RETURN input.
}
FUNCTION clearrow{
LOCAL PARAMETER rownum, OPTN IS 1.
      IF OPTN =1 {
      SET HudOpts[rownum][1] TO "                              ".
      SET HudOpts[rownum][2] TO "                    ".
      SET HudOpts[rownum][3] TO "                              ".
      }
      printline("",0,hudstart-rownum).
}
FUNCTION clearto{
  LOCAL PARAMETER st, end.
   FOR i IN range(st, end) {PRINTLINE("",0,i). PRINT " " AT (0,I).}
}
FUNCTION safekey{
  LOCAL PARAMETER lx, ky.
  IF lx:haskey(ky) RETURN lx[ky].
  RETURN 0.
}
FUNCTION glt{
  LOCAL PARAMETER n1,n2, opt IS 0.
  IF opt = 0{
  IF n1 > n2 RETURN "^".
  IF n1 < n2 RETURN "v".
  }ELSE{
  IF n1 > n2 RETURN ">".
  IF n1 < n2 RETURN "<".
  }
  RETURN " ".
}
FUNCTION LISTTOSTRING{
  LOCAL PARAMETER LSTIN3.
  IF NOT lstin3:typename:contains("list") SET lstin3 TO LIST(lstin3).
  LOCAL L2SAns TO "".
  FOR ITM IN LSTIN3:COPY{
    //if itm <> "" 
    SET L2SAns TO L2SAns+itm:tostring+",".
  }
  RETURN L2SAns:tostring.
}
FUNCTION PADMID{
  LOCAL PARAMETER STRING, AMT IS widthlim.
        LOCAL SP TO (AMT-STRING:LENGTH)/2.
        LOCAL sp2 TO 0.
        IF CEILING(sp)>sp {
          SET sp TO FLOOR(sp).
          SET sp2 TO CEILING(sp).
        }
        LOCAL ST TO STRING:PADLEFT(SP+STRING:LENGTH-1).
        SET   ST TO ST:PADRIGHT(SP2+ST:LENGTH+SP).
        RETURN ST.
}
FUNCTION DeDup{
  LOCAL PARAMETER lstin2.
  LOCAL lst2 TO lstin2:COPY.
  LOCAL lstout IS LIST().
  FOR it IN lst2 IF NOT lstout:contains(it) lstout:ADD(it).  
  RETURN lstout.
}
FUNCTION listadd{
  LOCAL PARAMETER lin, ad, OPT IS 0.
  IF NOT ad:typename:contains("list") SET ad TO LIST(ad).
  IF dbglog = 3 log2file("          LISTADD"+LISTTOSTRING(lin)+"+"+LISTTOSTRING(ad)).
  IF OPT = 0{
    FOR i IN ad{
      lin:ADD(i).
    }
  }ELSE{
    FOR i IN ad{
      IF NOT LIN:CONTAINS(AD) lin:ADD(i).
    }
  }
  IF dbglog = 3 log2file("          LISTOUT"+LISTTOSTRING(lin)).
  RETURN lin.
}
FUNCTION FillList{
LOCAL PARAMETER FillInList, lng.
  IF NOT FillInList:typename:contains("list") RETURN FillInList.
  UNTIL FillInList:LENGTH > lng{
    FillInList:ADD("").
  }
  RETURN FillInList:COPY.
}
FUNCTION ReplaceWords{
  LOCAL PARAMETER strin, wrdsin IS ReplWRDS[0], wrdsout IS ReplWRDS[1].
  IF strin:typename()  <> "string" SET strin TO strin:tostring.
  IF wrdsin:typename()  = "string" SET wrdsin  TO wrdsin:split("/").
  IF wrdsout:typename() = "string" SET wrdsout TO wrdsout:split("/").
  IF wrdsin:contains(strin) SET strin TO wrdsout[wrdsin:find(strin)].
  RETURN strin.   
}
FUNCTION StrginAct{
  LOCAL PARAMETER strin.
  LOCAL stroutb IS "".
  IF strin:istype("STRING"){
    SET stroutb TO removeletters(strin:tostring).
    IF stroutb <> "" SET stroutb TO stroutb:tonumber.
    SET strouta TO RemoveLetters(strin:TOSTRING,"0123456789").
    RETURN LIST(strouta,stroutb).
  }
}
FUNCTION splitlist{
  LOCAL PARAMETER SpLstIn ,splopt IS 1.
  IF SpLstIn:contains("/") RETURN SpLstIn:split("/"). ELSE IF splopt = 1 RETURN LIST(SpLstIn). ELSE RETURN SpLstIn.
}
//#endregion
//#region get ops
FUNCTION getstatus{
LOCAL PARAMETER Inum, tagnum, optn IS 1, row IS 1, rnd IS 0, dbglvl IS 2.
LOCAL optn1 TO optn*3-2.
  LOCAL MDL1 TO modulelist[0][inum][optn1].
  LOCAL MDL2 TO modulelist[1][inum][optn1].
  LOCAL Fld TO modulelist[2][inum][optn1].
  
  LOCAL GSAns TO "        ".
  LOCAL p TO  prtlist[Inum][tagnum][getgoodpart(Inum,tagnum,1)].
  IF dbglog > dbglvl log2file("GETSTATUS-"+itemlist[Inum]+":"+prtTagList[Inum][tagnum]+":"+optn1+" row:"+row+" rnd:"+rnd+" MODULE1:"+LISTTOSTRING(MDL1)+" MODULE2:"+LISTTOSTRING(MDL2)+" FIELD:"+LISTTOSTRING(Fld)).
    FOR k IN LIST(MDL1,MDL2){
      IF p:HASMODULE(k){
        IF p:getmodule(k):hasFIELD(Fld){
          SET GSAns TO Removespecial(P:GETMODULE(k):getfield(Fld)). 
          SET HudOpts[row][1] TO Fld. 
          SET HudOpts[row][2] TO ":".
          BREAK.
        }
      }
    }
        IF GSAns <> "        "{
        IF rnd > 0 SET GSAns TO ROUND(GSAns, rnd).
        IF dbglog > dbglvl log2file("    "+" GSAns:"+GSAns).
        IF rnd = -1  RETURN GSAns.
        IF rnd = -2  RETURN ROUND(GSAns, 2).
        IF rnd > -20 AND RND < -9  RETURN ROUND(GSAns,ABS(RND+10)). // RETURN ROUND LAST DIGIT (-11 = ROUND 1)
        IF rnd > -30 AND RND < -19  RETURN Fld+":"+ROUND(GSAns,ABS(RND+20)).// RETURN NANME + ROUND LAST DIGIT (-21 = ROUND 1)
        IF rnd = -30  RETURN Fld+":"+GSAns.// RETURN NANME + GSAns
        }
        
        RETURN GSAns+"                            ".
}
FUNCTION GetMultiModule{
  LOCAL PARAMETER PrtIN, GrabFied, ModName IS "".
  LOCAL count TO 0. LOCAL FLDNM TO "".  LOCAL FLDVL TO "". LOCAL TMPLST TO LIST().
    FOR m IN PrtIN:modules{
      LOCAL GetMod TO PrtIN:GETMODULEBYINDEX(count).
        IF GetMod:ALLFIELDNAMES:empty {}ELSE{
          IF GrabFied = ""{
              SET FLDNM TO GetMod:ALLFIELDNAMES[0].
              IF M:contains(Modname){
                SET FLDVL TO "".
                TMPLST:ADD(LIST(fldnm,FLDVL,count,m)). //fieldname, value, index, module
              }
          }ELSE{
              SET FLDNM TO GetMod:ALLFIELDNAMES[0].
              IF FLDNM:contains(GrabFied){
                SET FLDVL TO GetMod:GETFIELD(FLDNM).
                TMPLST:ADD(LIST(fldnm,FLDVL,count,m)).
              }
            }
      }
      SET count TO count+1.
    }
TMPLST:insert(0,TMPLST:length).
RETURN TMPLST.
}
FUNCTION GetActions{
    LOCAL PARAMETER opt, ModList, inum, tnum, optnin, evac, OpYes, OpNo IS LIST("zzz"),dbglvl IS 0.//return setting,list parts in , inum, tagnum, op 4 list, what to check 1=ac,2=ev,3=fld.
    LOCAL OPTTMP TO OPT.
    LOCAL prtid TO "".
    IF NOT OpYes:istype("list") SET OpYes TO LIST(OpYes).
    IF NOT OpNo:istype("list") SET OpNo TO LIST(OpNo).
    IF opt:istype("string"){ LOCAL tmpopt TO StrginAct(opt). SET opt TO tmpopt[0].SET prtid TO tmpopt[1].}
     IF DbgLog > dbglvl {IF inum <> 0{ log2file("               GETACTIONS:"+ItemList[inum]+":"+prttaglist[inum][tnum]+" EVAC"+evac).}
      IF DbgLog > MIN(dbglvl+1,2) {        log2file("                optIN:"+OPTTMP+" inum:"+inum).
        IF opt = "OnOff" {                 log2file("                  On:"+LISTTOSTRING(OpYes)+" Off:"+LISTTOSTRING(OpNo)).}
        ELSE{                              log2file("                  OpYes:"+LISTTOSTRING(OpYes)+" OpNo :"+LISTTOSTRING(OpNo)+ "ModList:"+LISTTOSTRING(ModList) ).
        }
      }
     }
      LOCAL RtnAns TO 0.
      LOCAL LM TO 0.
      IF EVAC = 0 {SET LM TO 1. SET evac TO 3.}
      IF EVAC = 5 {SET LM TO 3. SET evac TO 2.}
      IF EVAC = 6 {SET LM TO 3. SET evac TO 3.}
      LOCAL optn3 TO optnin*3.
      LOCAL optn2 TO optn3-1.
      LOCAL optn1 TO optn3-2.
      LOCAL pm TO "".
      LOCAL mdl TO "".
      LOCAL opout1 TO "".
      LOCAL opout2 TO "".
      LOCAL evmin TO evac.
      LOCAL evmax TO evac.
      LOCAL p TO "".
      IF evac = 3 {SET evmin TO 1. SET evmax TO 2.}
      IF inum = 0 SET p TO tnum. ELSE {IF PRTID = "" SET prtid TO getgoodpart(Inum,tnum,2,ModList). SET p TO PrtList[inum][tnum][prtid].}
      IF prtid = 0 {IF dbglog > 0 log2file("              NO GOOD PART"). SET modlist TO LIST().}ELSE{IF dbglog > 0 log2file("               PART("+prtid+"):"+p).}
      FOR e IN range(evmin,evmax+1){IF dbglog > dbglvl+1  log2file("                         EV:("+e+")").
        IF RtnAns > 0 BREAK.
        IF e > evmax BREAK.
        LOCAL dbthr IS 2. // SET TO LOWER TO ADD MORE DEBUG
        SET evac TO e.
        FOR md IN ModList:COPY{IF dbglog > dbglvl+1  log2file("                           MD:("+md+")").
          IF MD:istype("STRING") {
            IF SHIP:modulesnamed(md):length > 0 {
              IF p:HASMODULE(md){
                IF evac = 1 SET pm TO p:getmodule(md):AllEventNames.
                IF evac = 2 SET pm TO p:getmodule(md):AllActionNames.
                IF evac = 4 SET pm TO p:getmodule(md):AllfieldNames.
                IF dbglog > dbglvl+1  log2file("                          AllItems:("+LISTTOSTRING(PM)+")").//dddd
                FOR k IN pm{
                  IF RtnAns > lm BREAK.
                  FOR op IN opyes{
                    IF RtnAns > 0 BREAK.
                    IF op <>"" {IF dbglog > dbglvl+1  log2file("                                IF-ON :("+k+")"+"CONTAINS:("+op+")"). 
                      IF (k:contains(op) OR k = op) {IF dbglog > dbglvl+1  log2file("                             (YES)").  
                        IF getEvAct(p,md,k,e,-1,DBTHR) {IF dbglog > dbglvl+1  log2file("                              (PROCESSED)").  
                          IF EVAC = 4 SET opout2 TO p:getmodule(md):GETFIELD(K).
                            SET opout1 TO k. 
                            SET RtnAns TO 1.
                            SET mdl TO md.
                          BREAK.
                        }
                      }
                    }
                  }
                  IF EVAC <> 4 {
                    FOR op IN opno{
                      IF RtnAns > LM BREAK.
                      IF op <> "" {IF dbglog > dbglvl+1  log2file("                                 IF-OFF:("+k+")"+"CONTAINS:("+op+")").  
                        IF (k:contains(op) OR k = op){
                          IF getEvAct(p,md,k,e,-1,DBTHR) {IF dbglog > dbglvl+1  log2file("                              (PROCESSED)").  
                            SET opout2 TO k.
                            SET RtnAns TO RtnAns+2.
                            SET mdl TO md.
                            BREAK.
                          }
                        }
                      }
                    }
                  }
                }IF RtnAns > 0 BREAK.
              }IF RtnAns > 0 BREAK.
            }IF RtnAns > 0 BREAK.
          }ELSE{IF MD = 0 RETURN 0.}
        }
      }
      IF DbgLog > MIN(dbglvl+1,2) log2file( "                       mdl:"+mdl+" op out1:"+opout1+" op out2:"+opout2+" RtnAns:"+RtnAns+" evac:"+evac+" PrtId:"+prtid+" PM:"+LISTTOSTRING(PM)).
      IF opt = 1 {SET modulelist[0][inum][optn1] TO mdl. SET modulelist[0][inum][optn2] TO opout1. SET modulelist[0][inum][optn3] TO opout2. RETURN RtnAns.}
      IF opt = 2 OR opt = "Actions"{RETURN LIST(mdl,opout1,opout2,RtnAns,evac).}
      IF opt = 3 OR opt = "Modules" RETURN PM.
      IF opt = 4 OR opt = "OnOff" {IF dbglog > dbglvl  log2file("                       OnOff:("+RtnAns+")"). RETURN RtnAns.}
      IF opt = 5 {SET modulelist[0][inum][optn1] TO mdl. SET modulelist[0][inum][optn2] TO opout1. SET modulelist[0][inum][optn3] TO opout2. RETURN LIST(mdl,opout1,opout2,RtnAns,evac).}
   }
FUNCTION getEvAct{
  LOCAL PARAMETER p,m,ev, mode, val IS 0, dbt IS 2.
  IF p:istype("list"){
    SET pl TO p:COPY.
    FOR pl2 IN pl { IF  NOT BadPart(pl2) {SET p TO pl2. BREAK.}
    }
  }
  IF BadPart(p) AND VAL <> -1 RETURN FALSE.
  LOCAL GTAns TO "".
  LOCAL tname TO "".
  IF NOT ev:istype("string") SET ev TO ev:tostring.
  IF mode < 30 AND val > 0  SET dbt TO MIN(val,3).
  IF dbglog > dbt log2file("              GETEVACT:"+mode+" PART:"+p+" MODULE:"+m+" EVENT:"+EV+".").
  IF NOT p:HASMODULE(m) {IF dbglog > dbt log2file("                       NO MODULE:"+m). RETURN FALSE.}ELSE{
  LOCAL pm TO p:getmodule(m).
  IF mode = 1  {SET GTAns TO pm:hasevent(ev).  IF dbglog > dbt-1{SET tname TO listtostring(pm:AllEventNames) +":"+p+"("+m+")"+"hasevent:"+EV.}}ELSE{
  IF mode = 2  {SET GTAns TO pm:hasaction(ev). IF dbglog > dbt-1{SET tname TO listtostring(pm:AllActionNames)+":"+p+"("+m+")"+"hasaction:"+EV.}}ELSE{
  IF mode = 3  {SET GTAns TO pm:hasfield(ev).  IF dbglog > dbt-1{SET tname TO listtostring(pm:AllfieldNames) +":"+p+"("+m+")"+"hasfield:"+EV.}}ELSE{
  IF mode = 4  {SET GTAns TO pm:hasfield(ev).  IF dbglog > dbt-1{SET tname TO listtostring(pm:AllfieldNames) +":"+p+"("+m+")"+"hasfield:"+EV.}}ELSE{
  IF mode = 10 {IF  pm:hasevent(ev){pm:doevent(ev).        }IF dbglog > dbt-1{SET tname TO "doevent:"+EV. SET GTAns TO pm:hasevent(ev). }}ELSE{
  IF mode = 20 {IF pm:hasaction(ev){pm:doaction(ev, TRUE). }IF dbglog > dbt-1{SET tname TO "doaction:"+EV. SET GTAns TO pm:hasaction(ev).}}ELSE{
  IF mode = 30 {IF  pm:hasfield(ev){SET GTAns TO pm:GETFIELD(ev).}IF dbglog > dbt-1{SET tname TO "getfield:"+EV.}}ELSE{
  IF mode = 40 {IF  pm:hasfield(ev){pm:SETFIELD(ev,val). SET GTAns TO pm:GETFIELD(ev).}IF dbglog > dbt-1{SET tname TO "setfield:"+EV+" TO:"+val.}}
  }}}}}}}}
  IF MODE = 30 AND VAL > -1 AND GTAns:TYPENAME = "SCALAR" SET GTAns TO ROUND(GTAns,VAL).
  IF dbglog > dbt-1 log2file("                "+tname+" GTAns:"+GTAns).
  RETURN GTAns.
}
FUNCTION CheckTrue{
    LOCAL PARAMETER md, pt, MDL, FLD, ValTrue, ValFalse, vx IS 0, dbglvl IS 2.
    IF md <> 40 {
    IF getEvAct(pt,MDL,FLD,md,vx,dbglvl)  = FALSE SET CTAns TO ValFalse. ELSE SET CTAns TO ValTrue.
    }ELSE{
    IF getEvAct(pt,MDL,FLD,30,vx,dbglvl)  =  TRUE {
      FOR p1 IN pl getEvAct(p1,MDL,FLD,40,FALSE).
      SET CTAns TO ValFalse. 
      }ELSE {
        FOR p1 IN pl getEvAct(p1,MDL,FLD,40,TRUE).
        SET CTAns TO ValTrue. 
      }
    }
    RETURN CTAns.
}
FUNCTION checkDcp{
LOCAL PARAMETER Prt, Word.
LOCAL p TO PRT:DECOUPLER.
LOCAL DCPAns TO 0.
LOCAL pt TO "".
IF p <> "none"{
  IF p:TAG:tostring:contains(word){SET DCPAns TO 1. SET pt TO p.}ELSE{
    UNTIL DCPAns=1 OR p = "None"{
      SET p TO p:parent:decoupler.
      IF p <> "none"{IF p:TAG:tostring:contains(word) SET DCPAns TO 1. SET pt TO p.}
    }
  }
}
RETURN LIST(DCPAns,pt).
}
FUNCTION getRTVesselTargets {
  IF dbglog > 0 log2file("GET VESSEL TARGETS").
  LOCAL PARAMETER opt IS 1.
  LOCAL availableTargets TO LIST("no-target","active-vessel").
  IF opt = 1{availableTargets:ADD("Mission Control").
  LIST targets IN allTargets.
  FOR v IN allTargets {SET targetName TO v:NAME.
      IF targetName:contains("Ast.") SET targetName TO "". 
      IF targetName:contains("Debris") SET targetName TO "". 
          IF targetName <>"" {availableTargets:ADD(targetName).}
      }
        LIST BODIES IN bodList.
        FOR v IN bodList {availableTargets:ADD(v:NAME).}
}
  availableTargets:insert(0,availableTargets:length).
  IF dbglog > 1 log2file("    "+LISTTOSTRING(availableTargets)).
  RETURN availableTargets.
}
FUNCTION GetRange{//returns TRUE if within (percent) percent of (val), 0 = return true/false, 1 = return high/low value
  LOCAL PARAMETER val, comp, percent, opt IS 1.
    LOCAL GRAns IS FALSE.
    IF val < comp*(1+(percent/100)) AND val > comp*(1-(percent/100)) SET GRAns TO TRUE.
    IF val = comp  SET GRAns TO TRUE.
    IF opt = 1 RETURN GRAns.
    IF opt = 2 RETURN LIST(comp*(1-(percent/100)), comp*(1+(percent/100))).
}
FUNCTION getgoodpart{ // verifies tags are equal
    LOCAL PARAMETER Iin, Tin, opt IS 0, mds IS "", flds IS "".
    IF MeterList[1][Iin][0] = 0 SET opt TO 0.
    IF dbglog > 2 log2file("                        GetGoodPart:Item:"+iin+" TAG:"+tin+" OPT:"+opt).
    IF opt = 0 {
  FOR p IN range (0,PrtList[Iin][Tin][0]) {IF NOT BadPart(PrtList[Iin][Tin][p+1], prttaglist[Iin][Tin]) RETURN p+1.} RETURN 0.
    }ELSE{
      IF mds  = "" SET mds  TO MeterList[1][iin].
      IF flds = "" SET flds TO MeterList[2][iin][0].
      IF NOT flds:typename:contains("list") SET flds TO LIST(flds).
          IF dbglog > 2 log2file("                          mds:"+LISTTOSTRING(mds)+" flds:"+LISTTOSTRING(flds)).
    IF opt > 0 LOCAL modcnt TO LIST().
    LOCAL addlst TO LIST(-1,0).
    UNTIL addlst:length > PrtList[Iin][Tin][0] addlst:ADD(0).
    FOR ggm IN mds{
      FOR p IN range (0,PrtList[Iin][Tin][0]) { 
        LOCAL p1 TO p+1.
        LOCAL pt TO PrtList[Iin][Tin][p1].
        IF  pt:HASMODULE(ggm) {
          IF NOT BadPart(pt, prttaglist[Iin][Tin]) { 
            SET addlst[p1] TO addlst[p1]+1.
            IF opt = 1 {IF flds:length > 1 FOR f IN flds{IF pt:getmodule(ggm):ALLFIELDNAMES:contains(f) SET addlst[p1] TO addlst[p1]+1.}} //    if MeterList[1][Iin][0] = 0 set opt to 0.
          }
        }
      }
    }
      LOCAL mx TO 0. LOCAL mxo TO 1.
      FOR i IN range(0,addlst:length) {IF addlst[i] > mx {SET mx TO addlst[i]. SET mxo TO i.}}
      IF dbglog > 2 log2file("                          :PRT:"+mxo+" HAS "+MX+" MODULES/FIELDS"). 
      RETURN MAX(mxo,1).
    }
}
FUNCTION BoolNum{//bool to number
LOCAL PARAMETER NumIn, opt IS 0.
IF dbglog > 2 log2file("              BoolNum:"+Numin).
IF opt = 0{
  IF numin="true" RETURN 1.
  IF numin="false" RETURN 0.
}
SET NumTst TO removeletters(numin).
IF numtst:length = numin:tostring:length{
  IF numin:HASSUFFIX("tonumber") RETURN numin:tonumber. ELSE  RETURN numin.
}ELSE{RETURN LIST(numin).}
}
//#endregion
//#region file and part ops
FUNCTION sendboot{
  IF dbglog > 0 log2file("BOOTLOOPCHECK").
     LOCAL P TO PROCESSOR(CORE:PART:TAG).
      IF loadattempts < 0 {
        UNTIL CORE:MESSAGES:EMPTY{
          SET RECEIVED TO CORE:MESSAGES:POP.
        }
      IF P:CONNECTION:SENDMESSAGE(loadattempts).}
      ELSE{IF P:CONNECTION:SENDMESSAGE(loadattempts).}
    }
FUNCTION SaveAutoSettings{
  LOCAL PARAMETER OP IS 1, op2 IS 1.
  IF op2 = 1 partcheck().
  LOCAL loadp TO 20.  IF colorprint > 0{ SET loadp TO loadp+9. PRINT " " AT (80,LNstp-1).}
  IF op2 = 2 {SET loadp TO loadp+1. PRINT "." AT (loadp,LNstp-1).}
  IF dbglog > 0 log2file("SAVE AUTO SETTINGS").
  SET saveflag TO 0.
  IF prtcount <> SHIP:PARTS:LENGTH SET prtcount TO SHIP:PARTS:LENGTH.
  file_exists().
  SET autovallist[0][0][2] TO HEIGHT.
  SET autovallist[0][0][1] TO HdngSet.
  SET autoRstList[0][0][0] TO AUTOLOCK.
  IF DEFINED (HSel) SET AutoDspList[0][0][0] TO hsel[2][1]. ELSE SET  AutoDspList[0][0][0] TO 1.
  IF DEFINED (hsel) SET AutoDspList[0][0][1] TO hsel[2][2]. ELSE SET  AutoDspList[0][0][1] TO 1.
  IF loadattempts = -1 {IF autovallist[0][0][0] > 1001 SET autovallist[0][0][0] TO 1001.}
  IF debug > 2 {
    log2file(LISTTOSTRING("AutoDspList:"+AutoDspList)).
    log2file(LISTTOSTRING("autovallist:"+autovallist)).
    log2file(LISTTOSTRING("itemlist:"+itemlist)).
    log2file(LISTTOSTRING("prttaglist:"+prttaglist)).
    log2file(LISTTOSTRING("prtlist:"+prtlist)).
    log2file(LISTTOSTRING("autoRstList:"+autoRstList)).
    log2file(LISTTOSTRING("AutoRscList:"+AutoRscList)).
    log2file(LISTTOSTRING("AutoTRGList:"+AutoTRGList)).
  }
  LOCAL listout TO LIST(AutoDspList, autovallist,itemlist,prttaglist, prtlist, autoRstList, AutoRscList ,AutoTRGList, MONITORID).
  IF op = 1 WRITEJSON(listout, SubDirSV + autofile).
  IF op = 2 WRITEJSON(listout, SubDirSV + AutofileBAK).
}
FUNCTION BootLoopFix{
  IF dbglog > 0 log2file("BOOTLOOPFIX").
  desktop().
  SET line TO 2.
    LOCAL refreshTimer TO TIME:SECONDS.
    LOCAL isdone TO 0.
    sendboot().
        PRINT  "                     IT SEEMS LIKE YOU'RE IN A BOOT LOOP.           " AT (1,line).SET line TO line+1.
        PRINT  "                     WOULD YOU LIKE TO DELETE AUTO FILE?            " AT (1,line).SET line TO line+1.
        PRINT "                                                                     " AT (1,line).SET line TO line+1.   
        PRINT "                                    _____                            " AT (1,line).SET line TO line+1.
        PRINT "                                    |- -|                            " AT (1,line).SET line TO line+1.
        PRINT "                                    |O|O|                            " AT (1,line).SET line TO line+1.
        PRINT "                                    | | |                            " AT (1,line).SET line TO line+1.
        PRINT "                                    | | |                            " AT (1,line).SET line TO line+1.
        PRINT "                                    | |_|                            " AT (1,line).SET line TO line+1.
        PRINT "                                    |___                             " AT (1,line).SET line TO line+1.
        PRINT "                                                   " AT (1,line).SET line TO line+1.           
        PRINT "                   SELECTING LOAD WILL PAUSE AUTO TRIGGERS           " AT (1,line).SET line TO line+1.  
        PRINT getcolor(  "  DELETE  |   LOAD   |" ,"RED",0)AT (0,heightlim).
        IF file_exists(autofileBAK) PRINT getcolor("| lOAD BKP  |") AT (42,heightlim).
      FUNCTION button7{PRINT "Settings discarded."AT (1,line+1).SET line TO line+1. WAIT 1. SET isDone TO 1. SET loadattempts TO -1. sendboot(). IF file_exists(autofile) DELETEPATH(SubDirSV +autofile). SET LOADBKP TO 0.}buttons:setdelegate(7,button7@).
      FUNCTION button8{SET isDone TO 1. IF loadattempts > 3 {SET loadattempts TO -1. sendboot().} SET RunAuto TO 3.}buttons:setdelegate(8,button8@).
      FUNCTION button10{
        SET loadattempts TO -1. sendboot().
        SET LOADBKP TO 2.
        SET isDone TO 1.
        SET refreshTimer TO TIME:SECONDS+1000000.
        }buttons:setdelegate(10,button10@).
      UNTIL isDone > 0 {
      IF loadattempts > 3 {
        PRINT "Auto Deleting in " + ROUND((10- (TIME:SECONDS - refreshTimer)),0) + " SECONDS      " AT (1,17).
        IF TIME:SECONDS - refreshTimer > 10 {button7().}}
      ELSE{
          PRINT "                 ONE MORE CYCLE WILL TRIGGER AUTO DELETE OPTION      " AT (1,4).
        PRINT "Selecting No and Resetting Monitor Selection in" + ROUND((10- (TIME:SECONDS - refreshTimer)),0) + " SECONDS      " AT (1,17).
        IF TIME:SECONDS - refreshTimer > 10 {SET monitorselected TO 0. setmonvis().button8().}
      }
      }
    }
FUNCTION file_exists{
  PARAMETER fileName IS " ".
  cd(proot).
  IF NOT exists(SubDirSV) CREATEDIR(SubDirSV).
  IF filename <> "" {
      cd(SubDirSV).
      LOCAL fileList IS LIST().
      LOCAL found IS FALSE.
      LIST files IN fileList.
      FOR file IN fileList {IF file = fileName SET found TO TRUE.}
      IF dbglog > 0 log2file("    FILE EXIST?: "+fileName + ": "+found).
    RETURN found.
  }
}
FUNCTION partcheck{
  LOCAL loadp TO 27. IF colorprint > 0{ SET loadp TO loadp+9. PRINT " " AT (80,LNstp-1).}
  LOCAL PARAMETER opt IS 1.
  LOCAL GR TO 0. 
   SET checktime TO TIME:SECONDS.
   IF CheckPartLists() = 1 SET gr TO 1. ELSE SET  PrtListcur TO SetPartList(SHIP:ALLTAGGEDPARTS(),1).
     IF DbgLog > 0 log2file("PARTCHECK:"+opt).
      FOR i IN range (1,itemlist[0]+1){
        LOCAL ItemName TO ITEMLIST[I]:tostring..
        LOCAL cnt1 TO 0.
        //IF I = itemlist[0]+1 BREAK.
        IF DbgLog > 2 log2file("    Item:"+I ).
       IF opt > 1 { SET loadp TO loadp+1. PRINT "." AT (loadp,LNstp-1).}
        FOR t IN range (1,prtTAGList[I][0]+1){
            IF OPT = 1 IF I = FLYTAG OR I = AGTAG OR (i = CMDTag AND t > cmdln) BREAK.
            LOCAL TgName TO PRTTAGLIST[I][T]:tostring.
          //IF t = prtTAGList[I][0]+1 BREAK.
          SET cnt TO 0.
          IF DbgLog > 2 log2file("        Tag:"+T ).
          FOR p IN range (1,prtList[I][T][0]+1){
            IF badpart(prtList[I][T][P], prtTagList[i][t]) SET prtList[I][T][P] TO core:part.
            LOCAL ChkPart TO prtList[I][T][P]:tostring.
            IF DbgLog > 2 log2file("          Part:"+P ).
            IF prtList[I][T]:length < p+1 prtList[I][T]:ADD(CORE:PART).
            //IF p = prtList[I][T][0]+1 BREAK.
            LOCAL validpart TO 1.
            IF i <> agtag AND i <> flyTag AND NOT (i = CMDTag AND t > cmdln){
              IF prtList[I][T][P]:typename = "String" {SET validpart TO 0. 
                IF DbgLog > 0 AND NOT lostparts:contains(ChkPart+"-"+CNT) {log2file("        "+ItemName+":"+TgName+" REMOVED - IS STRING" ). 
                lostparts:ADD(ChkPart+"-"+CNT).}
              }ELSE{
              IF prtList[I][T][P]:TAG = ""{SET validpart TO 0.
                SET prtList[I][T][P] TO CORE:PART.
                IF DbgLog > 0 AND NOT lostparts:contains(ChkPart+"-"+CNT) log2file("       "+ItemName+":"+TgName+" REMOVED - PART GONE" ).
                lostparts:ADD(ChkPart+"-"+CNT).
              }ELSE{
              IF ChkPart = core:part:tostring {
                IF NOT ChkPart:contains("tag="+TgName) {SET validpart TO 0.
                  IF DbgLog > 0 AND NOT lostparts:contains(ChkPart+"-"+CNT) log2file("        "+ItemName+":"+TgName+" REMOVED - NOT FOUND" ) .
                  lostparts:ADD(ChkPart+"-"+CNT).
                  }
                }
              }}}
            IF dbglog > 1{log2file("   "+ItemName+"("+i+")"+TgName+"("+t+")"+PRTLIST[i][t][p]+"("+p+")-"+validpart ).}
            IF CheckPartLists() = 1 SET gr TO 1.
            IF prtList[I][T][P]:TAG = "" {SET prtList[I][T][P] TO CORE:PART. SET ChkPart TO CORE:PART. SET gr TO 1. SET validpart TO 0.}
            IF validpart = 1 AND SHIP:alltaggedparts():tostring:contains(ChkPart){
              SET cnt1 TO 1.
              IF opt > 1 {

                IF t > autoTRGList[0][I]:length-1 {
                  IF DbgLog > 2 log2file(i+"-"+t+"-"+p).
                  UNTIL autoTRGList[0][I]:length-1 > t autoTRGList[0][I]:ADD(0). //workaround, never found the bugm but it works now
                }
                
                IF autoTRGList[0][I][T] < 0{
                  IF DbgLog > 0 log2file("     "+ItemName+":"+TgName+" SET TO RUN").
                  SET AutoDspList[I][T] TO abs(AutoDspList[I][T]).
                  SET autoTRGList[0][I][T] TO 0.
                }
              }
            }
            ELSE{
              SET gr TO 1.
              IF prtList[I][T][P]:TAG = "" {SET prtList[I][T][P] TO CORE:PART.}
              ELSE{
                IF ChkPart <> CORE:PART:tostring.{
                    IF NOT lostparts:contains(ChkPart+"-"+CNT) AND validpart = 1{
                      SET validpart TO 0.
                      IF DbgLog > 0  log2file("        "+ItemName+":"+TgName+" REMOVED - NO TAG ="+TgName:tostring ).
                      lostparts:ADD(prtList[I][T][P]:tostring+"-"+CNT).
                    }
                }
              }
              SET cnt TO cnt+1.
              SET prtList[I][T][P] TO CORE:PART.
            }
            IF i = agtag OR i = flyTag OR (i = CMDTag AND t > cmdln) SET CNT TO 0.
            LOCAL PCNT TO prtList[I][T][0].
            IF PCNT:typename = "String" SET PCNT TO PCNT:TONUMBER.
            SET PCNT TO PCNT-1.
            IF cnt > PCNT AND autoTRGList[0][I][T] > -1{
              SET gr TO 1.
              IF DbgLog > 0 log2file("          TAG:"+ItemName+":"+TgName+" SET TO SKIP").
              SET autoTRGList[0][I][T] TO 0-abs(AutoDspList[I][T])-1.
              SET AutoDspList[I][T] TO 0-abs(AutoDspList[I][T]).
            }
          }
      }
      IF i = agtag OR i = flyTag OR (i = CMDTag) SET CNT1 TO 1.
      IF cnt1 = 0 AND AutoRscList[0][I] <> 2{
         IF DbgLog > 0 log2file("           ITEM:"+ItemName+" SET TO SKIP").
        SET AutoRscList[0][I] TO 0.
        }

      IF opt > 1 AND cnt1 = 1 AND AutoRscList[0][I] = 0 {
         IF DbgLog > 0 log2file("           ITEM:"+ItemName+" SET TO RUN").
        SET AutoRscList[0][I] TO 1.
        }
    }
    IF gr=1 {
      LOCAL rscl TO getRSCList(SHIP:RESOURCES,1).
      SET rsclist TO rscl[0].
      SET RscNum TO rscl[1].
      SET rsclist2 TO rscl[2].
    }
}
FUNCTION addlist{ //delete me when done with old files
IF dbglog > 0 log2file("ADDLIST****************").
  FOR i IN range(1,itemlist[0]+1){
  AutoDspList[0]:ADD(LIST(0)).
    FOR t IN range(1,prtTAGList[I][0]+1){
      AutoDspList[0][I]:ADD(LIST(0)).
      WAIT 0.001.
    }
  }
  IF AutoValList[0][0]:length = 1 AutoValList[0][0]:ADD(LIST(3,0,0,0,0,0,0)).
  IF AutoValList[0][0]:length = 2 AutoValList[0][0]:ADD(HEIGHT).
  IF AutoValList[0][0]:length = 3 AutoValList[0][0]:ADD(LIST(15,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1)).
  IF AutoValList[0][0]:length = 4 AutoValList[0][0]:ADD(LIST(refreshRateSlow,refreshRateFast,debug,dbglog,HLon,SPEEDSET[0],SPEEDSET[1],SPEEDSET[1],SPEEDSET[1],0,0,0,0,0,0,0,0,0,0,0,0)).
  RETURN.
}
FUNCTION CheckPartLists{
  LOCAL pf TO 0.
  IF alltagged:length <> SHIP:ALLTAGGEDPARTS():length {
  fixpl(). 
  SET pf TO 1.
  IF dbglog > 0 log2file("    ALLTAGGED list off - FIXING").
  }
  RETURN pf.
}
FUNCTION fixpl{
  IF DbgLog > 2 log2file("       FIXPL" ).
  SET PrtListcur TO SetPartList(SHIP:ALLTAGGEDPARTS(),1). 
  SET alltagged TO SHIP:ALLTAGGEDPARTS(). 
}
FUNCTION CheckAttached{
  LOCAL PARAMETER lin1, opt IS 0.
  IF NOT (DEFINED prtlistcur) RETURN lin1.
  IF DbgLog > 2 log2file("       CHECKATTACHED"+listtostring(lin1)).
  FOR check IN range (0,lin1:length) {
    IF opt = 0 {
      IF lin1[check]:HASSUFFIX("tag"){IF lin1[check]:TAG = "" SET lin1[check] TO CORE:PART.} ELSE SET lin1[check] TO CORE:PART.
      IF lin1[check]:HASSUFFIX("ALLTAGGEDPARTS"){IF lin1[check]:ALLTAGGEDPARTS:LENGTH < 1 SET lin1[check] TO CORE:PART.} ELSE SET lin1[check] TO CORE:PART.
    }ELSE{
      IF NOT lin1[check]:HASSUFFIX("tag") SET lin1[check] TO CORE:PART.
    }
  }
  RETURN lin1.
}
FUNCTION BadPart{ //checks if tags are equal and that a tag exists
  LOCAL PARAMETER Pin, TagTarg IS "".
  IF Pin:HASSUFFIX("tag"){IF tagtarg <> "" {IF pin:tag <> tagTarg RETURN TRUE.}IF Pin:TAG = "" RETURN TRUE.}ELSE RETURN TRUE.
  IF Pin:HASSUFFIX("ALLTAGGEDPARTS"){IF Pin:ALLTAGGEDPARTS:LENGTH < 1 RETURN TRUE.} ELSE RETURN TRUE.
  RETURN FALSE.
}
FUNCTION TrimModules{
  LOCAL PARAMETER lstin, TmPrt IS SHIP, tmopt IS 0.
  IF DbgLog > 2 log2file("       TrimModules:"+LISTTOSTRING(lstin)).
  LOCAL lstout TO lstin:COPY.
    FOR m IN lstin{IF TmPrt:modulesnamed(m):length = 0 lstout:REMOVE(lstout:find(m)).}
  IF DbgLog > 2 log2file("    TrimmedModules:"+LISTTOSTRING(lstout)).
  IF lstout:length = 0 AND tmopt = 1 SET lstout TO LIST(0).
  RETURN lstout:COPY.
}
FUNCTION TrimFields{
  LOCAL PARAMETER tmpl, modulesin, itemnum IS hsel[2][1],tagnum IS hsel[2][2], BotFields IS LIST().
  LOCAL mde TO 0.
  LOCAL fnd TO 0.
  IF ModulesIn:LENGTH = 1 AND ModulesIn[0]:contains("/") SET modulesin TO splitlist(ModulesIn[0]).
  IF NOT tmpl[0]:typename:contains("list") {SET tmpl TO LIST(tmpl). SET mde TO 1.}
  FOR i IN tmpl[0] IF i <> "" {SET fnd TO 1. BREAK.}
  IF fnd = 1 {
    IF DbgLog > 2 log2file("       TrimFields:"+LISTTOSTRING(tmpl[0])+" Modules:"+LISTTOSTRING(modulesin)+" MODE:"+mde).
    LOCAL fndlist TO lexicon().
    LOCAL FL TO tmpl[0]:COPY.
    IF mde = 0 AND itemnum <> -1 SET FL TO FL:sublist(1, FL:length).
    IF itemnum = -1 SET itemnum TO HSel[2][1].
    FOR f IN FL fndlist:ADD(f,0).
    LOCAL cnt TO 0.
    LOCAL botlstAlt TO FL:COPY.
      IF BotFields:length > 0 AND mde = 1{LOCAL cnt TO 0. IF DbgLog > 2 log2file("       KeepFieldsinBBB:").
        FOR j IN BotFields{IF DbgLog > 2 log2file("       KeepFieldsinCCC:").
          IF j[0]:tonumber < mtrcur[5]+1 {IF DbgLog > 2 log2file("       KeepFieldsinDDD:").
            SET botlstAlt TO BotFields[cnt]:COPY:sublist(1,BotFields[cnt]:length).
            //if DbgLog > 2 log2file("       KeepFieldsin:"+LISTTOSTRING(BotFields[cnt]:COPY:sublist(1,BotFields[cnt]:length))).
          } SET cnt TO cnt+1.}
      }
        IF DbgLog > 2 log2file("       KeepFields:"+LISTTOSTRING(botlstAlt)).
    FOR m IN ModulesIn{//if DbgLog > 2 log2file("            MODULE:"+M).
      FOR p IN range (0,PrtList[itemnum][tagnum][0]) {
        LOCAL pt TO PrtList[itemnum][tagnum][p+1]. //if DbgLog > 2 log2file("             part("+p+"):"+PT).
          IF  pt:HASMODULE(m){   //if DbgLog > 2 log2file("               HASMOD:"+m).
          FOR f IN FL{IF cnt = fl:length BREAK. 
            LOCAL F2 TO  F:TOSTRING:REPLACE("\","/"). //if DbgLog > 2 log2file("                  FIND-NAME:"+F+" - NAMECLEAN-"+F2).
            IF fndlist[F] = 0 {
              IF pt:getmodule(m):ALLFIELDNAMES:contains(F2) {//if DbgLog > 2 log2file("                   FOUND:"+F2+"-ALLFIELDNAMES").
                IF botlstAlt:contains(f){//if DbgLog > 2 log2file("                   FOUND:"+F+"-BOTLISTALT").
                  SET fndlist[F] TO 1. 
                  SET cnt TO cnt+1.}
                }
            }
          }
        }
      }
    }
    FOR k IN FL{
      IF fndlist[k] = 0 {
        IF tmpl[0]:find(k) > -1 {
        LOCAL FNDA TO tmpl[0]:find(k).
        LOCAL lng TO tmpl:length.
        LOCAL skp TO 0.
        IF DBGLOG > 2 log2file("        FNDA:"+K+" = "+FNDA+"  LENGTH:"+LNG+" ALTFND:"+tmpl[0]:find(k)).
          IF tmpl:length > 1 IF tmpl[1][FNDA]:contains("/"){LOCAL tmpspl TO tmpl[1][FNDA]:split("/").IF tmpspl[tmpspl:length-1] = "-2" SET skp TO 1.}
            IF skp = 0{
              FOR j IN range(0,MAX(1,lng)){ 
                IF tmpl[j]:length > MAX(1-mde,FNDA-1) {
                  IF DBGLOG > 2 log2file("          J:"+J+" "+tmpl[j][FNDA]+" REMOVED").
                  tmpl[j]:REMOVE(FNDA).
                }
              }
            }
        }
      }
    }
  }
  IF DbgLog > 2 log2file("    TrimmedFields:"+LISTTOSTRING(tmpl[0])).
  IF mde = 0 RETURN tmpl:COPY. ELSE RETURN tmpl[0]:COPY.
}
FUNCTION TrimModules2{
  LOCAL PARAMETER lstin, itemnum IS hsel[2][1],tagnum IS hsel[2][2]..
  IF DbgLog > 2 log2file("       TrimModules2:"+LISTTOSTRING(lstin)).
  LOCAL lstout TO lstin:COPY.
  LOCAL listMid IS LIST().
  FOR m IN lstin{FOR p IN range (0,PrtList[itemnum][tagnum][0]) {LOCAL pt TO PrtList[itemnum][tagnum][p+1].IF pt:HASMODULE(m) {listmid:ADD(m).BREAK.}}}
  FOR m IN lstin IF NOT listmid:contains(m) lstout:REMOVE(lstout:find(m)).
  IF DbgLog > 2 log2file("    TrimmedModules2:"+LISTTOSTRING(lstout)).
  RETURN lstout.
}
FUNCTION CleanList{
  LOCAL PARAMETER lsin, TagNameIn.
  IF dbglog > 1 log2file("        CLEANLIST:"+TagNameIn+":"+LISTTOSTRING(lsin)).
  LOCAL lsout TO LIST().
  FOR itm IN lsin {IF itm:typename = "Part" IF itm:tag = TagNameIn lsout:ADD(itm).} 
  RETURN lsout.
}
FUNCTION SpeedBoost{
  LOCAL PARAMETER onoff IS "on", silent IS 0.
  IF SHIP:ELECTRICCHARGE < 50 SET ONOFF TO "off".
  IF onoff = "on"  {SET CPUSPD TO SPEEDSET[1]. IF silent = 0 PRINT "*" AT (widthlim,heightlim-1).}
  ELSE {SET CPUSPD TO SPEEDSET[0].  IF silent = 0 PRINT " " AT (widthlim,heightlim-1).} 
  SET config:ipu TO Speeds[1][CPUSPD].
  IF BtnActn = 1   PRINT "*" AT (0,heightlim-1).
}
FUNCTION LastIn{
  LOCAL PARAMETER amt IS 0.
  IF amt = 0 {SET LastInput TO TIME:SECONDS. SET pscnt TO 0.}
  ELSE {IF amt < 0 {IF ROUND(TIME:SECONDS-lastinput,0) < abs(amt) RETURN TRUE. ELSE RETURN FALSE.}
  ELSE {            IF ROUND(TIME:SECONDS-lastinput,0) > abs(amt) RETURN TRUE. ELSE RETURN FALSE.}}
    IF LastIn(60) {
        PRINTQ:PUSH(" POWER SAVE MODE DEACTIVATED"+"<sp>"+"WHT"). 
        SET CPUSPD TO SPEEDSET[0].
    }
}
//#endregion
//#region Borrowed 
FUNCTION setmonvis{
  IF dbglog > 0  log2file("SETMONITOR").
  LOCAL refreshTimer TO TIME:SECONDS-2.
  //Initialize local variables
  LOCAL isDone TO 0.
  LOCAL ch TO "".
  LOCAL totalMonitors TO ADDONS:kpm:getmonitorcount().
 
  FUNCTION selectedMonitor
  {
    LOCAL PARAMETER index.
    SET buttons:currentmonitor TO index.
    SET id TO ADDONS:kpm:getguidshort(index).
    SET monitorGUID TO ADDONS:kpm:getguidshort(index).
    SET monitorselected TO 1.
  }
  //Main loop
  FUNCTION setmonvismain{
    //buttons:setdelegate(7,button7@).
    LOCAL FUNCTION button13{SET isDone TO 1. SET MONITORID TO monitorGUID.}
    LOCAL FUNCTION button11{SET isDone TO 1. SET MONITORID TO "0000000"+ monitorIndex.}
        //buttons:setdelegate(13,button13@).
    CLEARSCREEN.
    ///print UI layout
    PRINT "          |          |   SELECT MONITOR    |          |          |XXXXXXXXXX|" AT (0,0).
    PRINT "|          |          |          |          |FORCE NUM |          |  SELECT  |" AT (0,20).
    PRINT "TOTAL MONITORS: " + totalMonitors AT (2,1).
    PRINT "INSTRUCTIONS: ALLOW PROGRAM TO CYCLE THROUGH MONITORS, CLICK SELECY"AT (1,5). 
    PRINT "WHEN THE CORRECT MONITOR IS SELECTED THE PROGRAM WILL PROCEED. "AT (1,6).
    PRINT "YOU CAN USE NUMPAD 4 AND 6 TO MANUALLY CYCLE IF KOS WINDOW IS OPEN. "AT (1,7).
    PRINT "SELECT FORCE NUM TO FORCE THIS SHIP TO ALWAYS USE THIS MONITOR NUMBER." AT (1,8).
    IF FORCEMON > 0 PRINT "AUTOSELECT SET TO MONITOR "+(ForceMon-1) AT (1,12).
    //Sub loop
    UNTIL isDone > 0 
    { 
      IF MonAutoCyc = 1 {
        PRINT "CYCLING TO NEXT MONITOR IN " + ROUND((3- (TIME:SECONDS - refreshTimer)),0) + " SECONDS      " AT (1,17).

      IF TIME:SECONDS - refreshTimer > 3 OR forcemon > 0{
             IF forcemon > 0  OR totalMonitors = 1{
            IF monitorIndex = forcemon-1 OR totalMonitors = 1{
              IF totalMonitors = 1 SET monitorindex TO 0.
              SET monitorGUID TO ADDONS:kpm:getguidshort(monitorIndex). 
              SET buttons:currentmonitor TO monitorIndex.
              SET id TO ADDONS:kpm:getguidshort(monitorIndex).
              SET monitorselected TO 1. 
              PRINT "MONITOR FORCED TO MON "+monitorIndex. BREAK.
            }}
    IF totalMonitors = 0{CLEARSCREEN. 
    PRINT "CLICK STBY TWICE TO CYCLE SCRIPT." AT (1,1). 
    PRINT "CLICK STBY TWICE TO CYCLE SCRIPT." AT (1,2). 
    PRINT "CLICK STBY TWICE TO CYCLE SCRIPT." AT (1,3).
    PRINT "   CLICK THIS BUTTON TWICE!!!!." AT (1,15). PRINT "<-----------------------" AT (1,16).}
        SET refreshTimer TO TIME:SECONDS.
        IF monitorIndex < totalMonitors-1{
        SET monitorIndex TO monitorIndex + 1.
        selectedMonitor(monitorIndex).
        buttons:setdelegate(11,button11@).
        buttons:setdelegate(13,button13@).
        PRINT "              " AT (32,17).
        }ELSE{SET monitorIndex TO 0.}
      }
      }
      PRINT "CURRENT MONITOR: " + monitorIndex + "     " AT (2,2).
      PRINT "MONITOR ID: " + id+"    " AT (2,3).
      //Numpad listener
      IF terminal:input:haschar{SET ch TO terminal:input:getchar().}
      IF ch = "8"{SET ch TO "".}
      IF ch = "2"{SET ch TO "".}
      IF ch = "4"{ SET refreshTimer TO TIME:SECONDS.
        SET MonAutoCyc TO 0.
        IF monitorIndex > 0{
          SET monitorIndex TO monitorIndex - 1.
          selectedMonitor(monitorIndex).
          PRINT "              " AT (32,17).
        }
         PRINT "AUTO CYCLE CANCELED                              " AT (0,4).
        SET ch TO "".
      }
      IF ch = "6"{ SET refreshTimer TO TIME:SECONDS.
        SET MonAutoCyc TO 0.
        IF monitorIndex < totalMonitors-1{
          SET monitorIndex TO monitorIndex + 1.
          selectedMonitor(monitorIndex).
          PRINT "              " AT (32,17).
        }
         PRINT "AUTO CYCLE CANCELED                              " AT (0,4).
        SET ch TO "".
      }
      WAIT 0.001.
    }
  CLEARSCREEN.
  }
  setmonvismain().
}  
FUNCTION east_for {
  PARAMETER ves IS SHIP.

  RETURN VCRS(ves:UP:vector, ves:NORTH:vector).
}
FUNCTION compass_for {
  PARAMETER ves IS SHIP,thing IS "default".
  LOCAL pointing IS ves:FACING:FOREVECTOR.
  IF NOT thing:istype("string") {
    SET pointing TO type_to_vector(ves,thing).
  }
  LOCAL east IS east_for(ves).
  LOCAL trig_x IS VDOT(ves:NORTH:vector, pointing).
  LOCAL trig_y IS VDOT(east, pointing).
  LOCAL result IS arctan2(trig_y, trig_x).
  IF result < 0 {
    RETURN 360 + result.
  } ELSE {
    RETURN result.
  }
}
FUNCTION pitch_for {
  PARAMETER ves IS SHIP,thing IS "default".
  LOCAL pointing IS ves:FACING:FOREVECTOR.
  IF NOT thing:istype("string") {
    SET pointing TO type_to_vector(ves,thing).
  }
  RETURN 90 - VANG(ves:UP:vector, pointing).
}
FUNCTION roll_for {
  PARAMETER ves IS SHIP,thing IS "default".

  LOCAL pointing IS ves:FACING.
  IF NOT thing:istype("string") {
    IF thing:istype("vessel") OR pointing:istype("part") {
      SET pointing TO thing:FACING.
    } ELSE IF thing:istype("direction") {
      SET pointing TO thing.
    } ELSE {
      PRINT "type: " + thing:typename + " is not reconized by roll_for".
	}
  }
  LOCAL trig_x IS VDOT(pointing:topvector,ves:UP:vector).
  IF abs(trig_x) < 0.0035 {//this is the dead zone for roll when within 0.2 degrees of vertical
    RETURN 0.
  } ELSE {
    LOCAL vec_y IS VCRS(ves:UP:vector,ves:FACING:FOREVECTOR).
    LOCAL trig_y IS VDOT(pointing:topvector,vec_y).
    RETURN arctan2(trig_y,trig_x).
  }
}
FUNCTION compass_and_pitch_for {
  PARAMETER ves IS SHIP,thing IS "default".
  LOCAL pointing IS ves:FACING:FOREVECTOR.
  IF NOT thing:istype("string") {
    SET pointing TO type_to_vector(ves,thing).
  }
  LOCAL east IS east_for(ves).
  LOCAL trig_x IS VDOT(ves:NORTH:vector, pointing).
  LOCAL trig_y IS VDOT(east, pointing).
  LOCAL trig_z IS VDOT(ves:UP:vector, pointing).
  LOCAL compass IS arctan2(trig_y, trig_x).
  IF compass < 0 {
    SET compass TO 360 + compass.
  }
  LOCAL pitch IS arctan2(trig_z, sqrt(trig_x^2 + trig_y^2)).
  RETURN LIST(compass,pitch).
}
FUNCTION bearing_between {
  PARAMETER ves,thing_1,thing_2.
  LOCAL vec_1 IS type_to_vector(ves,thing_1).
  LOCAL vec_2 IS type_to_vector(ves,thing_2).
  LOCAL fake_north IS vxcl(ves:UP:vector, vec_1).
  LOCAL fake_east IS VCRS(ves:UP:vector, fake_north).
  LOCAL trig_x IS VDOT(fake_north, vec_2).
  LOCAL trig_y IS VDOT(fake_east, vec_2).
  RETURN arctan2(trig_y, trig_x).
}
FUNCTION type_to_vector {
  PARAMETER ves,thing.
  IF thing:istype("vector") {
    RETURN thing:normalized.
  } ELSE IF thing:istype("direction") {
    RETURN thing:FOREVECTOR.
  } ELSE IF thing:istype("vessel") OR thing:istype("part") {
    RETURN thing:FACING:FOREVECTOR.
  } ELSE IF thing:istype("geoposition") OR thing:istype("waypoint") {
    RETURN (thing:position - ves:position):normalized.
  } ELSE {
    PRINT "type: " + thing:typename + " is not recognized by lib_navball".
  }
}
FUNCTION vertical_aoa {
  LOCAL srfVel IS VXCL(SHIP:FACING:STARVECTOR,SHIP:VELOCITY:SURFACE).//surface velocity excluding any yaw component 
  RETURN VANG(SHIP:FACING:FOREVECTOR,srfVel).
}
//#endregion 