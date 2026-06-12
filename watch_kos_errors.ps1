param (
    [int]$Lines = 200
)

$LogPath = "c:\Program Files (x86)\Steam\steamapps\common\Kerbal Space Program\KSP.log"

if (Test-Path $LogPath) {
    Get-Content -Path $LogPath -Tail $Lines | Select-String -Pattern "(?i)kos" | Select-String -Pattern "(?i)error|exception|\[exc\]"
} else {
    Write-Output "KSP.log not found at $LogPath"
}
