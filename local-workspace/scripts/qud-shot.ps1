# Temp boots an auto-resetting image, takes screenshots over the USB control channel at the given seconds after boot, then sends REBOOT, which returns the phone to fastboot.
# Usage: qud-shot.ps1 -Name <image without .img> [-At 110,150] [-Timeout 480]. Writes logs\shot-<name>-<time>-<n>.txt and .bin, read by decode-shot.py.
# -Installed boots what is flashed in boot_b (fastboot reboot) instead of temp booting the image.
param([string]$Name, [int[]]$At = @(110), [int]$Timeout = 480, [switch]$Installed)
$f = 'E:\DSH-Fuxi\tools\platform-tools\fastboot.exe'
$img = "E:\DSH-Fuxi\$Name.img"
if (-not (Test-Path $img)) { "no $img"; exit 1 }
if (-not (& $f devices)) { 'phone not in fastboot'; exit 1 }
function Get-Crc([string]$text) {
  [long]$crc = 4294967295
  foreach ($b in [Text.Encoding]::ASCII.GetBytes($text)) {
    $crc = $crc -bxor [long]$b
    for ($i = 0; $i -lt 8; $i++) { if ($crc -band 1) { $crc = ($crc -shr 1) -bxor 3988292384 } else { $crc = $crc -shr 1 } }
  }
  return ($crc -bxor 4294967295)
}
function Get-Frame([string]$verb, [string]$session, [long]$seq) {
  $body = 'SXNU1 {0} {1:x8} {2}' -f $session, $seq, $verb
  return ('{0} {1:x8}' -f $body, (Get-Crc $body)) + "`n"
}
$script:buf = ''; $script:log = $null
function Read-Reply([string]$verb, [long]$seq, [int]$ms) {
  # Log text and replies share the port; a reply is one SXNU1R line ending in a newline.
  $until = (Get-Date).AddMilliseconds($ms)
  $pattern = 'SXNU1R \w{16} ' + ('{0:x8}' -f $seq) + ' ' + $verb + ' [^\r\n]*\n'
  while ((Get-Date) -lt $until) {
    $chunk = $port.ReadExisting()
    if ($chunk) { [IO.File]::AppendAllText($script:log, $chunk); $script:buf += $chunk }
    $m = [regex]::Match($script:buf, $pattern)
    if ($m.Success) { $script:buf = $script:buf.Substring($m.Index + $m.Length); return $m.Value.Trim() }
    if ($script:buf.Length -gt 200000) { $script:buf = $script:buf.Substring($script:buf.Length - 4000) }
  }
  return $null
}
$null = cmd /c "`"$f`" set_active b 2>&1"
Start-Sleep 2
$start = Get-Date; $stamp = $start.ToString('HHmmss')
"boot $Name at " + $start.ToString('HH:mm:ss')
if ($Installed) { & $f reboot 2>&1 | Select-Object -Last 1 } else { & $f boot $img 2>&1 | Select-Object -Last 1 }
$script:log = "E:\DSH-Fuxi\logs\com3-$Name-$stamp.log"
$end = $start.AddSeconds($Timeout); $port = $null
while (-not $port -and (Get-Date) -lt $end) {
  if ([IO.Ports.SerialPort]::GetPortNames() -contains 'COM3') {
    try { $port = New-Object IO.Ports.SerialPort 'COM3', 115200, 'None', 8, 'One'; $port.DtrEnable = $true; $port.ReadTimeout = 300; $port.WriteTimeout = 2000; $port.Open() } catch { $port = $null; Start-Sleep 1 }
  } else { Start-Sleep 1 }
}
if (-not $port) { "NO COM3 within $Timeout s: the phone may be stuck, hold vol-down+power"; exit 2 }
'COM3 open after ' + [int]((Get-Date) - $start).TotalSeconds + ' s'
$session = '0000000000000000'; [long]$seq = 0; $n = 0
foreach ($sec in $At) {
  $n++
  while (((Get-Date) - $start).TotalSeconds -lt $sec) { $c = $port.ReadExisting(); if ($c) { [IO.File]::AppendAllText($script:log, $c) }; Start-Sleep -Milliseconds 200 }
  $r = $null
  foreach ($try in 1..3) {
    $port.Write((Get-Frame 'HELLO' '0000000000000000' 0))
    $r = Read-Reply 'HELLO' 0 5000
    if ($r) { break }
  }
  if ($r -notmatch 'session=(\w{16}) last_seq=(\w+)') { "shot ${n}: no HELLO reply"; continue }
  $session = $Matches[1]; $seq = [Convert]::ToInt64($Matches[2], 16)
  $seq++; $port.Write((Get-Frame 'SCREENSHOT' $session $seq))
  $r = Read-Reply 'SCREENSHOT' $seq 30000
  "[{0,4}s] {1}" -f [int]((Get-Date) - $start).TotalSeconds, $r
  if ($r -notmatch 'state=ready') { continue }
  $null = $r -match 'encoded=(\d+)'; $total = [int]$Matches[1]
  $base = "E:\DSH-Fuxi\logs\shot-$Name-$stamp-$n"
  [IO.File]::WriteAllText("$base.txt", $r)
  $data = New-Object IO.MemoryStream; $t0 = Get-Date; $bad = $null
  while ($data.Length -lt $total) {
    $seq++; $port.Write((Get-Frame 'SHOTNEXT' $session $seq))
    $r = Read-Reply 'SHOTNEXT' $seq 5000
    if ($r -notmatch ('offset=' + $data.Length + ' data=([0-9a-fA-F]+)')) { $bad = "at $($data.Length) of ${total}: $r"; break }
    $hex = $Matches[1]
    for ($i = 0; $i -lt $hex.Length; $i += 2) { $data.WriteByte([Convert]::ToByte($hex.Substring($i, 2), 16)) }
  }
  [IO.File]::WriteAllBytes("$base.bin", $data.ToArray())
  $took = [int]((Get-Date) - $t0).TotalSeconds
  if ($bad) { "shot $n STOPPED $bad" } else { "shot $n done: $total bytes in $took s -> $base.bin" }
}
$seq++; $port.Write((Get-Frame 'REBOOT' $session $seq))
'REBOOT sent, reply: ' + (Read-Reply 'REBOOT' $seq 3000)
# Keep reading until the port goes away, so the kernel's last output drains.
$sent = Get-Date
try { while ((Get-Date) -lt $end -and $port.IsOpen -and ([IO.Ports.SerialPort]::GetPortNames() -contains 'COM3')) { $c = $port.ReadExisting(); if ($c) { [IO.File]::AppendAllText($script:log, $c) }; Start-Sleep -Milliseconds 100 } } catch {}
try { $port.Close() } catch {}
$back = $null
while ((Get-Date) -lt $end) { if (& $f devices) { $back = (Get-Date) - $start; break }; Start-Sleep 1 }
if ($back) { 'BACK in fastboot after ' + [int]$back.TotalSeconds + ' s, ' + [int]((Get-Date) - $sent).TotalSeconds + ' s after REBOOT' } else { "NOT back within $Timeout s" }
$null = cmd /c "`"$f`" set_active b 2>&1"
Get-ChildItem "E:\DSH-Fuxi\logs\shot-$Name-$stamp-*.bin" -ErrorAction SilentlyContinue | ForEach-Object {
  $p = ($_.FullName -replace '\.bin$', '') -replace '\\', '/' -replace '^E:', '/mnt/e'
  wsl.exe -u root -- python3 -I /mnt/e/DSH-Fuxi/dump/wsl/decode-shot.py $p
}
