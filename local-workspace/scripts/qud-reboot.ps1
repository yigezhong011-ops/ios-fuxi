# Sends REBOOT over the USB control channel of a running system and waits for fastboot. Writes no partition.
$f = 'E:\DSH-Fuxi\tools\platform-tools\fastboot.exe'
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
$port = New-Object IO.Ports.SerialPort 'COM3', 115200, 'None', 8, 'One'; $port.DtrEnable = $true; $port.ReadTimeout = 300; $port.WriteTimeout = 2000; $port.Open()
$buf = ''
function Wait-Reply([string]$pattern, [int]$ms) {
  $until = (Get-Date).AddMilliseconds($ms)
  while ((Get-Date) -lt $until) { $script:buf += $port.ReadExisting(); $m = [regex]::Match($script:buf, $pattern); if ($m.Success) { return $m }; Start-Sleep -Milliseconds 50 }
  return $null
}
# The first HELLO after opening the port has gone unanswered twice; send up to three.
$m = $null
foreach ($try in 1..3) {
  $port.Write((Get-Frame 'HELLO' '0000000000000000' 0))
  $m = Wait-Reply 'session=(\w{16}) last_seq=(\w+)' 5000
  if ($m) { break }
}
if (-not $m) { 'no HELLO reply'; $port.Close(); exit 1 }
$session = $m.Groups[1].Value; [long]$seq = [Convert]::ToInt64($m.Groups[2].Value, 16) + 1
$buf = ''; $port.Write((Get-Frame 'REBOOT' $session $seq))
$r = Wait-Reply ' REBOOT [^\r\n]*\n' 3000
if ($r) { 'REBOOT reply: ' + $r.Value.Trim() } else { 'REBOOT sent, no reply seen' }
$t0 = Get-Date
try { while ($port.IsOpen -and ([IO.Ports.SerialPort]::GetPortNames() -contains 'COM3') -and ((Get-Date) - $t0).TotalSeconds -lt 30) { $null = $port.ReadExisting(); Start-Sleep -Milliseconds 100 } } catch {}
try { $port.Close() } catch {}
foreach ($i in 1..40) { if (& $f devices) { 'BACK in fastboot after ' + [int]((Get-Date) - $t0).TotalSeconds + ' s'; $null = cmd /c "`"$f`" set_active b 2>&1"; exit 0 }; Start-Sleep 1 }
'NOT back in fastboot'; exit 2
