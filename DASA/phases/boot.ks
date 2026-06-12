@LAZYGLOBAL OFF.

setStage("Booting").

IF NOT EXISTS("0:/telemetry/vessel_structure.json") {
    logMsg("No existing vessel structure found. Forcing scan...").
    WAIT 1.
    RUNPATH("0:/DASA/VesselScan.ks").
}

PRINT "Scan vessel structure? (y/n)".
LOCAL scanChoice IS "".
UNTIL scanChoice = "y" OR scanChoice = "n" {
    SET scanChoice TO terminal:input:getchar().
}
IF scanChoice = "y" {
    RUNPATH("0:/DASA/VesselScan.ks").
} ELSE {
    logMsg("Skipping vessel scan. Dashboard will use existing vessel structure.").
    WAIT 0.2.
}
