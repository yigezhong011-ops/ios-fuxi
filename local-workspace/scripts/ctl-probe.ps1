# Minimal control-channel probe: boot an image, then talk to COM3 with visible progress in the log.
# Usage: ctl-probe.ps1 -Name t50-auto-touch [-ShotAt 120] [-Timeout 240]
param([string]$Name, [int]$ShotAt = 120, [int]$Timeout = 240)
$f = 'E:\DSH-Fuxi\tools\platform-tools\fastboot.exe'
$img = "E:\DSH-Fuxi\$Name.img"
$start = Get-Date
$stamp = $start.ToString('HHmmss')
$out = "E:\DSH-Fuxi\logs\probe-$Name-$stamp.txt"
$ser = "E:\DSH-Fuxi\logs\com3-$Name-$stamp.log"
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
      $port.DtrEnable = $true; $port.ReadTimeout = 300; $port.WriteTimeout = 2000
      $port.Open(); W ("COM3 open (" + [int]((Get-Date) - $start).TotalSeconds + " s)")
    } catch { $port = $null; W ("COM3 open failed: " + $_.Exception.Message); Start-Sleep 2 }
  } else { Start-Sleep 1 }
}
if (-not $port) { W 'no COM3'; exit 2 }
$buf = ''
$session = $null; [long]$seq = 0
$shotDone = $false
while ((Get-Date) -lt $end) {
  $chunk = $port.ReadExisting()
  if ($chunk) { [IO.File]::AppendAllText($ser, $chunk); $buf += $chunk }
  $lines = $buf -split "`n"
  if ($lines.Count -gt 1) {
    foreach ($l in $lines[0..($lines.Count - 2)]) { if ($l -match 'SXNU1R') { W ("reply: " + $l.Trim()) } }
    $buf = $lines[-1]
  }
  if ($buf.Length -gt 100000) { $buf = $buf.Substring($buf.Length - 4000) }
  if (-not $session) {
    $port.Write((Frame 'HELLO' '0000000000000000' 0))
    Start-Sleep -Milliseconds 2000
    if ($buf -match 'session=(\w{16}) last_seq=(\w+)') {
      $session = $Matches[1]; $seq = [Convert]::ToInt64($Matches[2], 16)
      W ("HELLO ok, session $session last_seq $($Matches[2])")
    } else { W 'no HELLO reply yet' }
    continue
  }
  $elapsed = ((Get-Date) - $start).TotalSeconds
  if (-not $shotDone -and $elapsed -ge $ShotAt) {
    $seq++
    W "send SCREENSHOT seq $seq"
    $port.Write((Frame 'SCREENSHOT' $session $seq))
    Start-Sleep -Seconds 8
    if ($buf -match 'state=ready') { W 'SCREENSHOT ready'; $shotDone = $true }
    else { W ('SCREENSHOT reply: ' + ($buf -replace "`r?`n", ' ').Trim()) }
    continue
  }
  Start-Sleep -Milliseconds 300
}
$seq++
W "send REBOOT seq $seq"
try { $port.Write((Frame 'REBOOT' $session $seq)) } catch {}
Start-Sleep -Seconds 5
try { $port.Close() } catch {}
W 'done'
