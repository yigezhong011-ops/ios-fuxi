# From fastboot: TWRP, stream the 16 GiB Data window to E:, compare hashes, back to fastboot on slot b. Reads the device only. The result stays local: never upload it.
param([switch]$Replace)  # -Replace writes over the earlier copy of the same window; no space is needed for a second one
$adb = "E:\DSH-Fuxi\tools\platform-tools\adb.exe"; $fb = "E:\DSH-Fuxi\tools\platform-tools\fastboot.exe"
$out = "E:\DSH-Fuxi\logs\data-raw.img"
$free = (Get-PSDrive E).Free
Write-Output "free GiB $([math]::Round($free / 1GB, 1))"
if ((Test-Path $out) -and -not $Replace) { Write-Output "REFUSE: $out exists"; exit 4 }
if (-not (Test-Path $out) -and $free -lt 17.5GB) { Write-Output "NOT ENOUGH SPACE"; exit 3 }
cmd /c "`"$fb`" set_active a 2>&1"; cmd /c "`"$fb`" reboot recovery 2>&1"
$up = $false
foreach ($i in 1..40) { Start-Sleep 3; if ((& $adb devices) -match "\srecovery") { $up = $true; break } }
Write-Output "recovery up=$up"
if (-not $up) { & $adb devices; exit 2 }
$dd = "dd if=/dev/block/by-name/userdata bs=1048576 iflag=skip_bytes,count_bytes skip=$(54282042 * 4096) count=$(4194304 * 4096)"
cmd /c "`"$adb`" exec-out $dd 2>nul > `"$out`""
Write-Output "local bytes $((Get-Item $out).Length) expected $(4194304 * 4096)"
$h = (cmd /c "`"$adb`" shell `"$dd 2>/dev/null | sha256sum`"") -join ' '
Write-Output "phone sha $h"
Write-Output "local sha $((Get-FileHash $out -Algorithm SHA256).Hash.ToLower())"
cmd /c "`"$adb`" reboot bootloader 2>&1"
foreach ($i in 1..30) { Start-Sleep 2; if ((cmd /c "`"$fb`" devices 2>&1") -match "fastboot") { break } }
cmd /c "`"$fb`" set_active b 2>&1"
cmd /c "`"$fb`" getvar current-slot 2>&1" | Select-Object -First 1
