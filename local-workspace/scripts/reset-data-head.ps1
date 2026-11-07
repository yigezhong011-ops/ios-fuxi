# From fastboot: TWRP, back up the Data store's 64 MiB head to E:, check the SHNGDATA magic, zero the head, read it back, return to fastboot on slot b.
# Only these 64 MiB are written: the OS volumes and the rest of userdata stay. The next boot starts Data over from the seed, with that image's identity.
$adb = 'E:\DSH-Fuxi\tools\platform-tools\adb.exe'; $fb = 'E:\DSH-Fuxi\tools\platform-tools\fastboot.exe'
$block = 54283066; $count = 16384
$bak = 'E:\DSH-Fuxi\logs\data-head-before-reset-' + (Get-Date).ToString('yyyyMMdd-HHmmss') + '.bin'
if (-not (& $fb devices)) { 'phone not in fastboot'; exit 1 }
cmd /c "`"$fb`" set_active a 2>&1"; cmd /c "`"$fb`" reboot recovery 2>&1"
$up = $false
foreach ($i in 1..40) { Start-Sleep 3; if ((& $adb devices) -match '\srecovery') { $up = $true; break } }
"recovery up=$up"
if (-not $up) { & $adb devices; exit 2 }
function Back-To-Fastboot {
  cmd /c "`"$adb`" shell rm -f /tmp/head.bin 2>&1"
  cmd /c "`"$adb`" reboot bootloader 2>&1"
  foreach ($i in 1..30) { Start-Sleep 2; if ((cmd /c "`"$fb`" devices 2>&1") -match 'fastboot') { break } }
  cmd /c "`"$fb`" set_active b 2>&1"
  cmd /c "`"$fb`" getvar current-slot 2>&1" | Select-Object -First 1
}
cmd /c "`"$adb`" shell dd if=/dev/block/by-name/userdata of=/tmp/head.bin bs=4096 skip=$block count=$count 2>&1"
cmd /c "`"$adb`" pull /tmp/head.bin `"$bak`" 2>&1"
$size = (Get-Item $bak).Length
"backup $bak bytes $size"
$fs = [IO.File]::OpenRead($bak); $b = New-Object byte[] 8; $null = $fs.Read($b, 0, 8); $fs.Close()
$magic = [Text.Encoding]::ASCII.GetString($b)
"magic '$magic'"
$phoneSha = ((cmd /c "`"$adb`" shell sha256sum /tmp/head.bin 2>&1") -split '\s+')[0]
$localSha = (Get-FileHash $bak -Algorithm SHA256).Hash.ToLower()
"backup sha match: " + ($phoneSha -eq $localSha)
if ($magic -ne 'SHNGDATA' -or $size -ne ($count * 4096) -or $phoneSha -ne $localSha) { 'REFUSED: nothing written'; Back-To-Fastboot; exit 3 }
cmd /c "`"$adb`" shell dd if=/dev/zero of=/dev/block/by-name/userdata bs=4096 seek=$block count=$count conv=notrunc,fsync 2>&1"
cmd /c "`"$adb`" shell sync 2>&1"
$after = ((cmd /c "`"$adb`" shell `"dd if=/dev/block/by-name/userdata bs=4096 skip=$block count=$count 2>/dev/null | sha256sum`" 2>&1") -split '\s+')[0]
$zero = ((cmd /c "`"$adb`" shell `"dd if=/dev/zero bs=4096 count=$count 2>/dev/null | sha256sum`" 2>&1") -split '\s+')[0]
"head zeroed: " + ($after -eq $zero)
Back-To-Fastboot
if ($after -ne $zero) { 'RESULT head not zero'; exit 4 }
'RESULT reset done'
