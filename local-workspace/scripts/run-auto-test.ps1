# One unattended test: temp boot an auto-resetting image, capture the USB serial until the phone is back in fastboot.
# Usage: run-auto-test.ps1 <image name without .img> <timeout seconds>
param([string]$Name, [int]$Timeout = 420)
$f = 'E:\DSH-Fuxi\tools\platform-tools\fastboot.exe'
$img = "E:\DSH-Fuxi\$Name.img"
if (-not (Test-Path $img)) { "no $img"; exit 1 }
$dev = & $f devices
if (-not $dev) { 'phone not in fastboot'; exit 1 }
& $f getvar current-slot 2>&1 | Select-String 'current-slot'
& $f getvar slot-retry-count:b 2>&1 | Select-String 'retry'
$start = Get-Date
"boot $Name at " + $start.ToString('HH:mm:ss')
& $f boot $img 2>&1 | Select-Object -Last 2
$out = "E:\DSH-Fuxi\logs\com3-$Name-" + $start.ToString('HHmmss') + '.log'
$end = $start.AddSeconds($Timeout)
$gone = $false; $port = $null; $seen = $null; $back = $null
while ((Get-Date) -lt $end) {
  if (-not $port -and ([System.IO.Ports.SerialPort]::GetPortNames() -contains 'COM3')) {
    try {
      $port = New-Object System.IO.Ports.SerialPort 'COM3', 115200, 'None', 8, 'One'
      $port.DtrEnable = $true; $port.ReadTimeout = 500; $port.Open()
      $seen = (Get-Date) - $start
      "COM3 open after " + [int]$seen.TotalSeconds + " s"
    } catch { $port = $null }
  }
  if ($port) {
    try { [System.IO.File]::AppendAllText($out, $port.ReadExisting()) } catch { try { $port.Close() } catch {}; $port = $null }
  }
  $d = & $f devices
  if (-not $d) { $gone = $true }
  if ($gone -and $d) { $back = (Get-Date) - $start; break }
  Start-Sleep -Milliseconds 700
}
if ($port) { try { $port.Close() } catch {} }
if ($back) { "BACK in fastboot after " + [int]$back.TotalSeconds + " s" } else { "NOT back in fastboot within $Timeout s (left the bootloader: $gone)" }
if (Test-Path $out) {
  "serial log $out bytes " + (Get-Item $out).Length
  Select-String -Path $out -Pattern 'FUXI120' | ForEach-Object { $_.Line.Trim() } | Select-Object -First 40
  foreach ($pat in 'panic', 'jetsam') { "{0}: {1}" -f $pat, @(Select-String -Path $out -SimpleMatch $pat).Count }
}
