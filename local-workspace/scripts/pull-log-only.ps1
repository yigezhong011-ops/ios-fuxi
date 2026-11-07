# From fastboot: TWRP, copy only the boot log window, back to fastboot on slot b. Reads Data only. Decodes into logs\carve-<Name>\log.
param([Parameter(Mandatory = $true)][string]$Name)
$adb = "E:\DSH-Fuxi\tools\platform-tools\adb.exe"; $fb = "E:\DSH-Fuxi\tools\platform-tools\fastboot.exe"
$dir = "E:\DSH-Fuxi\logs\carve-$Name"; New-Item -ItemType Directory -Force $dir | Out-Null
cmd /c "`"$fb`" set_active a 2>&1"; cmd /c "`"$fb`" reboot recovery 2>&1"
$up = $false
foreach ($i in 1..40) { Start-Sleep 3; if ((& $adb devices) -match "\srecovery") { $up = $true; break } }
Write-Output "recovery up=$up"
if (-not $up) { & $adb devices; exit 2 }
cmd /c "`"$adb`" shell dd if=/dev/block/by-name/userdata of=/tmp/log.bin bs=4096 skip=58731451 count=8192 2>&1"
cmd /c "`"$adb`" pull /tmp/log.bin $dir\log.bin 2>&1"
cmd /c "`"$adb`" shell rm -f /tmp/log.bin 2>&1"
cmd /c "`"$adb`" reboot bootloader 2>&1"
foreach ($i in 1..30) { Start-Sleep 2; if ((cmd /c "`"$fb`" devices 2>&1") -match "fastboot") { break } }
cmd /c "`"$fb`" set_active b 2>&1"
cmd /c "`"$fb`" getvar current-slot 2>&1" | Select-Object -First 1
wsl.exe -u root -- python3 -I /mnt/e/DSH-Fuxi/unixnu-build/fuxi/scripts/read-sheng-log.py --decode "/mnt/e/DSH-Fuxi/logs/carve-$Name/log.bin" --out "/root/fuxi/hang/$Name" 2>&1 | Select-Object -Last 3
