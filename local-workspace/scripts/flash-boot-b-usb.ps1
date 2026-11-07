# From fastboot: back up boot_b through TWRP, flash t50-daily-usb.img to boot_b only, read it back and compare, finish in fastboot on slot b.
$adb = 'E:\DSH-Fuxi\tools\platform-tools\adb.exe'; $fb = 'E:\DSH-Fuxi\tools\platform-tools\fastboot.exe'
$new = 'E:\DSH-Fuxi\t50-daily-usb.img'; $old = 'E:\DSH-Fuxi\t50-mine-gpu-fix.img'; $dev = '/dev/block/by-name/boot_b'
$backup = 'E:\DSH-Fuxi\logs\boot_b-before-usb-' + (Get-Date).ToString('HHmmss') + '.img'
if (-not (& $fb devices)) { 'phone not in fastboot'; exit 1 }
function FileSha($p) { (Get-FileHash -Algorithm SHA256 $p).Hash.ToLower() }
function ToRecovery { cmd /c "`"$fb`" set_active a 2>&1" | Out-Null; cmd /c "`"$fb`" reboot recovery 2>&1" | Out-Null; foreach ($i in 1..40) { Start-Sleep 3; if ((& $adb devices) -match '\srecovery') { return $true } }; return $false }
function ToFastboot { cmd /c "`"$adb`" reboot bootloader 2>&1" | Out-Null; foreach ($i in 1..30) { Start-Sleep 2; if ((cmd /c "`"$fb`" devices 2>&1") -match 'fastboot') { return $true } }; return $false }
function PartSha([long]$bytes) { $n = [math]::Ceiling($bytes / 4096); (((cmd /c "`"$adb`" shell `"dd if=$dev bs=4096 count=$n 2>/dev/null | head -c $bytes | sha256sum`" 2>&1") -join ' ').Trim() -split '\s+')[0] }
if (-not (ToRecovery)) { 'no recovery'; exit 2 }
$size = [long]((cmd /c "`"$adb`" shell blockdev --getsize64 $dev 2>&1") -join '').Trim()
$newLen = (Get-Item $new).Length; $oldLen = (Get-Item $old).Length
"boot_b bytes $size, new image $newLen"
if ($newLen -gt $size) { 'image larger than boot_b: REFUSED'; ToFastboot | Out-Null; cmd /c "`"$fb`" set_active b 2>&1" | Out-Null; exit 3 }
cmd /c "`"$adb`" pull $dev `"$backup`" 2>&1" | Select-Object -Last 1
if ((Get-Item $backup).Length -ne $size) { "backup size wrong: $((Get-Item $backup).Length)"; ToFastboot | Out-Null; cmd /c "`"$fb`" set_active b 2>&1" | Out-Null; exit 4 }
$is = (PartSha $oldLen) -eq (FileSha $old)
"backup $backup; current boot_b is t50-mine-gpu-fix: $is"
if (-not (ToFastboot)) { 'no fastboot after backup'; exit 5 }
cmd /c "`"$fb`" flash boot_b `"$new`" 2>&1" | Select-Object -Last 2
if (-not (ToRecovery)) { 'no recovery after flash'; exit 6 }
$ok = (PartSha $newLen) -eq (FileSha $new)
"read back matches t50-daily-usb: $ok"
if (-not (ToFastboot)) { 'no fastboot after verify'; exit 7 }
cmd /c "`"$fb`" set_active b 2>&1" | Out-Null
cmd /c "`"$fb`" getvar current-slot 2>&1" | Select-Object -First 1
if ($ok) { 'RESULT flashed' } else { 'RESULT mismatch'; exit 8 }
