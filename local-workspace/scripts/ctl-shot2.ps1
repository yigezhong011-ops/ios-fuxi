# End-to-end: boot an image, take two screenshots over the control channel, decode both, then REBOOT.
# Each SCREENSHOT also makes the patched cave tap once, so the two pictures show before/after the tap.
# Usage: ctl-shot2.ps1 -Name t50-auto-touch [-At 110,150] [-Timeout 260]
param([string]$Name, [string]$At = "110", [int]$Timeout = 260)
$f = 'E:\DSH-Fuxi\tools\platform-tools\fastboot.exe'
$img = "E:\DSH-Fuxi\$Name.img"
$start = Get-Date; $stamp = $start.ToString('HHmmss')
$out = "E:\DSH-Fuxi\logs\ctl-$Name-$stamp.txt"
$ser = "E:\DSH-Fuxi\logs\com3-$Name-$stamp.log"
New-Item -ItemType File -Force $out | Out-Null
function W([string]$s) { $line = ('{0,7:N1}s {1}' -f ((Get-Date) - $start).TotalSeconds, $s); Add-Content -Path $out -Value $line; Write-Output $line }
function Get-Crc([string]$text) {
  [long]$crc = 4294967295
  foreach ($b in [Text.Encoding]::ASCII.GetBytes($text)) {
    $crc = $crc -bxor [long]$b
    for ($i = 0; $i -lt 8; $i++) { if ($crc -band 1) { $crc = ($crc -shr 1) -bxor 3988292384 } else { $crc = $crc -shr 1 } }
  }
  return ($crc -bxor 4294967295)
}
function Frame([string]$verb, [string]$session, [long]$seq) {
  $body = 'SXNU1 {0} {1:x8} {2}' -f $session, $seq, $verb
  return ('{0} {1:x8}' -f $body, (Get-Crc $body)) + "`n"
}
if (-not (Test-Path $img)) { W "no $img"; exit 1 }
if (-not (& $f devices)) { W 'phone not in fastboot'; exit 1 }
$null = cmd /c "`"$f`" set_active b 2>&1"
W "boot $Name"
& $f boot $img 2>&1 | Select-Object -Last 1 | ForEach-Object { W $_ }
$end = $start.AddSeconds($Timeout)
$port = $null
while (-not $port -and (Get-Date) -lt $end) {
  if ([IO.Ports.SerialPort]::GetPortNames() -contains 'COM3') {
    try {
      $port = New-Object IO.Ports.SerialPort 'COM3', 115200, 'None', 8, 'One'
      $port.DtrEnable = $true; $port.ReadTimeout = 200; $port.WriteTimeout = 2000
      $port.Open(); W ("COM3 open (" + [int]((Get-Date) - $start).TotalSeconds + " s)")
    } catch { $port = $null; Start-Sleep 1 }
  } else { Start-Sleep 1 }
}
if (-not $port) { W 'no COM3'; exit 2 }
$buf = ''
function Pump([int]$ms) {
  $until = (Get-Date).AddMilliseconds($ms)
  while ((Get-Date) -lt $until) {
    $c = $port.ReadExisting()
    if ($c) { [IO.File]::AppendAllText($ser, $c); $script:buf += $c }
    Start-Sleep -Milliseconds 50
  }
}
function Wait-Reply([string]$verb, [long]$seq, [int]$ms) {
  $until = (Get-Date).AddMilliseconds($ms)
  $sx = '{0:x8}' -f $seq
  while ((Get-Date) -lt $until) {
    $idx = $script:buf.IndexOf("SXNU1R ")
    if ($idx -ge 0) {
      $nl = $script:buf.IndexOf("`n", $idx)
      if ($nl -gt $idx) {
        $line = $script:buf.Substring($idx, $nl - $idx).Trim()
        $script:buf = $script:buf.Substring($nl + 1)
        $parts = $line -split ' '
        if ($parts.Count -ge 4 -and $parts[2] -eq $sx -and $parts[3] -eq $verb) { return $line }
        continue
      }
    }
    $c = $port.ReadExisting()
    if ($c) { [IO.File]::AppendAllText($ser, $c); $script:buf += $c } else { Start-Sleep -Milliseconds 50 }
  }
  return $null
}
$session = $null; [long]$seq = 0
for ($i = 1; $i -le 10 -and -not $session; $i++) {
  $port.Write((Frame 'HELLO' '0000000000000000' 0))
  $r = Wait-Reply 'HELLO' 0 4000
  if ($r -and $r -match 'session=(\w{16}) last_seq=(\w+)') {
    $session = $Matches[1]; $seq = [Convert]::ToInt64($Matches[2], 16)
    W ("HELLO ok session=$session last_seq=$($Matches[2]) control=" + ($r -replace '.*control=(\d+).*', '$1'))
  }
}
if (-not $session) { W 'HELLO never answered'; exit 3 }
$n = 0
foreach ($sec in ($At -split ',')) {
  $n++
  while (((Get-Date) - $start).TotalSeconds -lt $sec) { Pump 300 }
  $seq++
  W "SCREENSHOT #$n at $([int]((Get-Date) - $start).TotalSeconds) s, seq $seq"
  $port.Write((Frame 'SCREENSHOT' $session $seq))
  $r = Wait-Reply 'SCREENSHOT' $seq 30000
  W ("  reply: " + $r)
  if (-not ($r -match 'encoded=(\d+)')) { W '  no encoded size'; continue }
  $total = [int]$Matches[1]
  $ms = New-Object IO.MemoryStream
  $bad = $null
  while ($ms.Length -lt $total) {
    $seq++
    $port.Write((Frame 'SHOTNEXT' $session $seq))
    $r = Wait-Reply 'SHOTNEXT' $seq 8000
    if (-not ($r -match 'offset=(\d+) data=([0-9a-fA-F]+)')) { $bad = "at $($ms.Length)/$total : $r"; break }
    if ([int]$Matches[1] -ne $ms.Length) { $bad = "offset jump $($Matches[1]) vs $($ms.Length)"; break }
    $hex = $Matches[2]
    for ($i = 0; $i -lt $hex.Length; $i += 2) { $ms.WriteByte([Convert]::ToByte($hex.Substring($i, 2), 16)) }
  }
  $base = "E:\DSH-Fuxi\logs\shot-$Name-$stamp-$n"
  [IO.File]::WriteAllBytes("$base.bin", $ms.ToArray())
  if ($bad) { W "  frame $n stopped: $bad" } else { W "  frame $n complete: $total bytes" }
}
$seq++
$port.Write((Frame 'REBOOT' $session $seq))
W ('REBOOT reply: ' + (Wait-Reply 'REBOOT' $seq 4000))
Start-Sleep -Seconds 2
try { $port.Close() } catch {}
for ($i = 0; $i -lt 40; $i++) { if (& $f devices) { W ('back in fastboot after ' + [int]((Get-Date) - $start).TotalSeconds + ' s'); break }; Start-Sleep 1 }
$null = cmd /c "`"$f`" set_active b 2>&1"
Get-ChildItem "E:\DSH-Fuxi\logs\shot-$Name-$stamp-*.bin" -ErrorAction SilentlyContinue | ForEach-Object {
  $p = ($_.FullName -replace '\.bin$', '') -replace '\\', '/' -replace '^E:', '/mnt/e'
  W ('decode ' + $_.Name)
  wsl.exe -u root -- python3 -I /mnt/e/DSH-Fuxi/dump/wsl/decode-shot.py $p 2>&1 | ForEach-Object { W ("  $_") }
}
W 'done'
