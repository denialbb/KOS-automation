@LAZYGLOBAL OFF.

GLOBAL SettingsL TO LIST().

// Index                   Setting
//   0                     thickness of markers
//   1                     data sampling time interval
//   2                     track sampling time interval
//   3                     x resolution (40 or 80 characters)
FUNCTION riempiSettings {
	
	SettingsL:ADD(0.2). 
	SettingsL:ADD(2.0).
	SettingsL:ADD(5.0).
	SettingsL:ADD(80).

}