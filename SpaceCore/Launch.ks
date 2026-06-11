DECLARE PARAMETER FairingDeployment IS FALSE, TargetAltitudeKm IS 75,RelativeInclinationDegr IS 0, FairingDeploymentAltitudeKm IS 60.

RUNPATH("0:/SpaceCore/Countdown").

RUNPATH("0:/SpaceCore/Liftoff").

RUNPATH("0:/SpaceCore/Ascent",FairingDeployment,TargetAltitudeKm,RelativeInclinationDegr,FairingDeploymentAltitudeKm).

RUNPATH("0:/SpaceCore/CircToAp").