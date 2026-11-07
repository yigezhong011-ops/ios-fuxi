# From fastboot: read the log window and the export region below it out of userdata through TWRP, then back to fastboot on slot b.
# Reads only. Usage: pull-diag.ps1 <name>   Output: E:\DSH-Fuxi\logs\twrp-<name>.bin and twrp-<name>-export.bin
param([Parameter(Mandatory = $true)][string]$Name)
$fb = "E:\DSH-Fuxi\tools\platform-tools\fastboot.exe"
$adb = "E:\DSH-Fuxi\tools\platform-tools\adb.exe"
$window = 58731451
$region = $window - 65536
if (-not ((& $fb devices) -match "fastboot")) { Write-Output "NOT IN FASTBOOT"; exit 1 }
$null = cmd /c "`"$fb`" set_active a 2>&1"
$null = cmd /c "`"$fb`" reboot recovery 2>&1"
$up = $false
for ($i = 0; $i -lt 40; $i++) {
    Start-Sleep -Seconds 2
    if ($i -eq 20) { $null = cmd /c "`"$adb`" kill-server 2>&1"; $null = cmd /c "`"$adb`" start-server 2>&1" }
    if ((& $adb devices) -match "\srecovery") { $up = $true; break }
}
if (-not $up) { Write-Output "TWRP ADB NOT UP: replug the cable, slot a is active"; exit 2 }
$null = cmd /c "`"$adb`" shell dd if=/dev/block/by-name/userdata of=/tmp/log.bin bs=4096 skip=$window count=8192 2>&1"
$null = cmd /c "`"$adb`" shell dd if=/dev/block/by-name/userdata of=/tmp/export.bin bs=4096 skip=$region count=65536 2>&1"
cmd /c "`"$adb`" pull /tmp/log.bin E:\DSH-Fuxi\logs\twrp-$Name.bin 2>&1"
cmd /c "`"$adb`" pull /tmp/export.bin E:\DSH-Fuxi\logs\twrp-$Name-export.bin 2>&1"
$null = cmd /c "`"$adb`" shell rm -f /tmp/log.bin /tmp/export.bin 2>&1"
$null = cmd /c "`"$adb`" reboot bootloader 2>&1"
for ($i = 0; $i -lt 30; $i++) { Start-Sleep -Seconds 2; if ((& $fb devices) -match "fastboot") { break } }
cmd /c "`"$fb`" set_active b 2>&1" | Select-String "OKAY|FAILED"
cmd /c "`"$fb`" getvar current-slot 2>&1" | Select-String "current-slot"
cmd /c "`"$fb`" getvar slot-retry-count:b 2>&1" | Select-String "retry"
Get-ChildItem "E:\DSH-Fuxi\logs\twrp-$Name*.bin" | Select-Object Name, Length | Format-Table -AutoSize | Out-String
