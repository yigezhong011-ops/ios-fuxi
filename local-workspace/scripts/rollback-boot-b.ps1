# User asked on 2026-11-06 to roll back: waits for fastboot, flashes the daily image to boot_b, reboots, watches for COM3.
param([int]$WaitSeconds = 1500)
$f = 'E:\DSH-Fuxi\tools\platform-tools\fastboot.exe'
$img = 'E:\DSH-Fuxi\t50-mine-gpu-fix.img'
$want = 'E8C24CB5709EB42B'
$h = (Get-FileHash $img -Algorithm SHA256).Hash.Substring(0, 16)
"image $h"
if ($h -ne $want) { 'STOP daily image hash differs'; exit 1 }
$start = Get-Date
while (-not (& $f devices)) {
  if (((Get-Date) - $start).TotalSeconds -gt $WaitSeconds) { 'STOP phone did not reach fastboot'; exit 2 }
  Start-Sleep -Seconds 2
}
'fastboot seen at ' + (Get-Date).ToString('HH:mm:ss')
Start-Sleep -Seconds 1
cmd /c "`"$f`" flash boot_b `"$img`" 2>&1"
"flash exit $LASTEXITCODE"
if ($LASTEXITCODE -ne 0) { 'STOP flash failed; boot_b unchanged or partial'; exit 1 }
cmd /c "`"$f`" set_active b 2>&1"
cmd /c "`"$f`" reboot 2>&1"
$s = Get-Date; $gone = $false
while (((Get-Date) - $s).TotalSeconds -lt 180) {
  $t = [int]((Get-Date) - $s).TotalSeconds
  if ([System.IO.Ports.SerialPort]::GetPortNames() -contains 'COM3') { "COM3 up at $t s"; exit 0 }
  $d = & $f devices
  if (-not $d) { $gone = $true }
  if ($gone -and $d) { "BACK in fastboot at $t s, no COM3"; exit 3 }
  Start-Sleep -Seconds 1
}
'no COM3 within 180 s'
exit 4
