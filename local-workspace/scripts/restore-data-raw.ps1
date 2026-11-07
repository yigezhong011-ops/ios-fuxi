# From fastboot: TWRP, write logs\data-raw.img back over the 16 GiB Data window, 256 MiB at a time. A piece that already matches is skipped, every written piece is
# read back and compared. Only that window is written: blocks 54282042 .. 54282042 + 4194304 of userdata. Back to fastboot on slot b at the end.
$adb = 'E:\DSH-Fuxi\tools\platform-tools\adb.exe'; $fb = 'E:\DSH-Fuxi\tools\platform-tools\fastboot.exe'
$img = 'E:\DSH-Fuxi\logs\data-raw.img'; $piece = 'E:\DSH-Fuxi\logs\restore-piece.bin'
$first = 54282042; $blocks = 4194304; $step = 65536   # 4K blocks; 65536 = 256 MiB
$dev = '/dev/block/by-name/userdata'
if (-not (& $fb devices)) { 'phone not in fastboot'; exit 1 }
$fs = [IO.File]::OpenRead($img)
if ($fs.Length -lt $blocks * 4096) { 'copy too short'; $fs.Close(); exit 1 }
$m = New-Object byte[] 8; [void]$fs.Seek(1024 * 4096, 'Begin'); [void]$fs.Read($m, 0, 8)
if ([Text.Encoding]::ASCII.GetString($m) -ne 'SHNGDATA') { 'copy has no SHNGDATA at block 1024: REFUSED'; $fs.Close(); exit 1 }
cmd /c "`"$fb`" set_active a 2>&1"; cmd /c "`"$fb`" reboot recovery 2>&1"
$up = $false
foreach ($i in 1..40) { Start-Sleep 3; if ((& $adb devices) -match '\srecovery') { $up = $true; break } }
"recovery up=$up"
if (-not $up) { & $adb devices; $fs.Close(); exit 2 }
$sectors = ((cmd /c "`"$adb`" shell blockdev --getsize64 $dev 2>&1") -join '').Trim()
"userdata bytes $sectors"
if ([int64]$sectors -lt ($first + $blocks) * 4096) { 'window outside userdata: REFUSED'; $fs.Close(); exit 3 }
function PhoneSha([int64]$skip, [int64]$count) { (((cmd /c "`"$adb`" shell `"dd if=$dev bs=4096 skip=$skip count=$count 2>/dev/null | sha256sum`" 2>&1") -join ' ').Trim() -split '\s+')[0] }
$sha = [Security.Cryptography.SHA256]::Create()
$buf = New-Object byte[] ($step * 4096)
$wrote = 0; $same = 0; $bad = 0
[void]$fs.Seek(0, 'Begin')
for ($i = 0; $i * $step -lt $blocks; $i++) {
  $got = 0; while ($got -lt $buf.Length) { $n = $fs.Read($buf, $got, $buf.Length - $got); if ($n -le 0) { break }; $got += $n }
  if ($got -ne $buf.Length) { "short read at piece $i"; $bad++; break }
  $want = ([BitConverter]::ToString($sha.ComputeHash($buf))).Replace('-', '').ToLower()
  $seek = $first + $i * $step
  if ((PhoneSha $seek $step) -eq $want) { $same++; continue }
  [IO.File]::WriteAllBytes($piece, $buf)
  cmd /c "`"$adb`" push `"$piece`" /tmp/piece.bin 2>&1" | Out-Null
  $tmp = ((cmd /c "`"$adb`" shell sha256sum /tmp/piece.bin 2>&1") -split '\s+')[0]
  if ($tmp -ne $want) { "piece $i corrupt on the way: stopped"; $bad++; break }
  cmd /c "`"$adb`" shell `"dd if=/tmp/piece.bin of=$dev bs=4096 seek=$seek conv=notrunc,fsync 2>/dev/null; rm /tmp/piece.bin`" 2>&1" | Out-Null
  if ((PhoneSha $seek $step) -ne $want) { "piece $i read back different: stopped"; $bad++; break }
  $wrote++
  if ($wrote % 8 -eq 0) { "written $wrote same $same of 64 at " + (Get-Date).ToString('HH:mm:ss') }
}
$fs.Close()
Remove-Item -LiteralPath $piece -ErrorAction SilentlyContinue
cmd /c "`"$adb`" shell sync 2>&1"
"written $wrote same $same bad $bad"
cmd /c "`"$adb`" reboot bootloader 2>&1"
foreach ($i in 1..30) { Start-Sleep 2; if ((cmd /c "`"$fb`" devices 2>&1") -match 'fastboot') { break } }
cmd /c "`"$fb`" set_active b 2>&1"
cmd /c "`"$fb`" getvar current-slot 2>&1" | Select-Object -First 1
if ($bad) { 'RESULT failed'; exit 4 }
'RESULT restored'
