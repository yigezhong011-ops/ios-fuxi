# Attach to the running system over COM3 and take screenshots without rebooting.
# Each SCREENSHOT also taps once (the patched cave), so consecutive frames show before/after.
# Usage: ctl-attach.ps1 -Count 2 [-Gap 8]
param([int]$Count = 2, [int]$Gap = 8)
$stamp = (Get-Date).ToString('HHmmss')
$out = "E:\DSH-Fuxi\logs\attach-$stamp.txt"
$ser = "E:\DSH-Fuxi\logs\attach-serif-$stamp.log"
$start = Get-Date
New-Item -ItemType File -Force $out | Out-Null
function W([string]$s) { $line = ('{0,6:N1}s {1}' -f ((Get-Date) - $start).TotalSeconds, $s); Add-Content -Path $out -Value $line; Write-Output $line }
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
if (-not ([IO.Ports.SerialPort]::GetPortNames() -contains 'COM3')) { W 'no COM3'; exit 2 }
$port = New-Object IO.Ports.SerialPort 'COM3', 115200, 'None', 8, 'One'
$port.DtrEnable = $true; $port.ReadTimeout = 200; $port.WriteTimeout = 2000
$port.Open(); W 'COM3 open'
$buf = ''
function Wait-Reply([string]$verb, [long]$seq, [int]$ms) {
  $until = (Get-Date).AddMilliseconds($ms)
  $sx = '{0:x8}' -f $seq
  while ((Get-Date) -lt $until) {
    $idx = $script:buf.IndexOf('SXNU1R ')
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
for ($i = 1; $i -le 8 -and -not $session; $i++) {
  $port.Write((Frame 'HELLO' '0000000000000000' 0))
  $r = Wait-Reply 'HELLO' 0 3000
  if ($r -and $r -match 'session=(\w{16}) last_seq=(\w+)') { $session = $Matches[1]; $seq = [Convert]::ToInt64($Matches[2], 16); W "HELLO ok $session last_seq $($Matches[2])" }
}
if (-not $session) { W 'HELLO failed'; exit 3 }
for ($n = 1; $n -le $Count; $n++) {
  $seq++
  W "SCREENSHOT #$n seq $seq (taps once first)"
  $port.Write((Frame 'SCREENSHOT' $session $seq))
  $r = Wait-Reply 'SCREENSHOT' $seq 30000
  $meta = $r
  W ("  " + $r)
  if (-not ($r -match 'encoded=(\d+)')) { continue }
  $total = [int]$Matches[1]
  $ms = New-Object IO.MemoryStream
  $bad = $null
  while ($ms.Length -lt $total) {
    $seq++
    $port.Write((Frame 'SHOTNEXT' $session $seq))
    $r = Wait-Reply 'SHOTNEXT' $seq 8000
    if (-not ($r -match 'offset=(\d+) data=([0-9a-fA-F]+)')) { $bad = "at $($ms.Length)/$total : $r"; break }
    $hex = $Matches[2]
    for ($i = 0; $i -lt $hex.Length; $i += 2) { $ms.WriteByte([Convert]::ToByte($hex.Substring($i, 2), 16)) }
  }
  $base = "E:\DSH-Fuxi\logs\attach-$stamp-$n"
  [IO.File]::WriteAllBytes("$base.bin", $ms.ToArray())
  [IO.File]::WriteAllText("$base.txt", $meta)
  W $(if ($bad) { "  stopped $bad" } else { "  complete $total bytes -> $base.bin" })
  if ($n -lt $Count) { Start-Sleep -Seconds $Gap }
}
try { $port.Close() } catch {}
Get-ChildItem "E:\DSH-Fuxi\logs\attach-$stamp-*.bin" -ErrorAction SilentlyContinue | ForEach-Object {
  $p = ($_.FullName -replace '\.bin$', '') -replace '\\', '/' -replace '^E:', '/mnt/e'
  W ('decode ' + $_.Name)
  wsl.exe -u root -- python3 -I /mnt/e/DSH-Fuxi/dump/wsl/decode-shot.py $p 2>&1 | ForEach-Object { W ("  $_") }
}
W 'done'
