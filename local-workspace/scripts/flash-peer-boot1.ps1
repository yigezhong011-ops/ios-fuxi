# User asked on 2026-11-06 to flash the shared image to boot_b. Flashes boot_b only, then reboots and watches for 150 s.
$f = 'E:\DSH-Fuxi\tools\platform-tools\fastboot.exe'
$img = 'E:\DSH-Fuxi\peer-boot1.img'
$orig = 'C:\Users\USER\Downloads\boot (1).img'
$daily = 'E:\DSH-Fuxi\t50-mine-gpu-fix.img'
if (-not (& $f devices)) { 'STOP phone not in fastboot'; exit 1 }
$a = (Get-FileHash $img -Algorithm SHA256).Hash; $b = (Get-FileHash $orig -Algorithm SHA256).Hash
"image $($a.Substring(0,16)) original $($b.Substring(0,16))"
if ($a -ne $b) { 'STOP image differs from the original'; exit 1 }
if (-not (Test-Path $daily)) { 'STOP fallback image missing'; exit 1 }
"fallback $((Get-FileHash $daily -Algorithm SHA256).Hash.Substring(0,16))"
$vars = cmd /c "`"$f`" getvar partition-size:boot_b 2>&1"; $vars | Select-Object -First 1
$cur = cmd /c "`"$f`" getvar current-slot 2>&1"; $cur | Select-Object -First 1
$m = [regex]::Match(($vars -join ' '), 'partition-size:boot_b:\s*(0x[0-9a-fA-F]+)')
if (-not $m.Success) { 'STOP cannot read boot_b size'; exit 1 }
$size = [Convert]::ToInt64($m.Groups[1].Value.Substring(2), 16)
"boot_b $size bytes, image $((Get-Item $img).Length) bytes"
if ((Get-Item $img).Length -gt $size) { 'STOP image larger than boot_b'; exit 1 }
cmd /c "`"$f`" flash boot_b `"$img`" 2>&1"
"flash exit $LASTEXITCODE"
if ($LASTEXITCODE -ne 0) { 'STOP flash failed'; exit 1 }
cmd /c "`"$f`" set_active b 2>&1"
cmd /c "`"$f`" reboot 2>&1"
$start = Get-Date; $gone = $false; $com = $false
while (((Get-Date) - $start).TotalSeconds -lt 150) {
  $t = [int]((Get-Date) - $start).TotalSeconds
  if (-not $com -and ([System.IO.Ports.SerialPort]::GetPortNames() -contains 'COM3')) { $com = $true; "COM3 seen at $t s" }
  if ($com -and -not ([System.IO.Ports.SerialPort]::GetPortNames() -contains 'COM3')) { $com = $false; "COM3 gone at $t s" }
  $d = & $f devices
  if (-not $d) { if (-not $gone) { "left fastboot at $t s" }; $gone = $true }
  if ($gone -and $d) { "BACK in fastboot at $t s"; break }
  Start-Sleep -Milliseconds 500
}
'state:'; & $f devices
Get-PnpDevice -PresentOnly | Where-Object { $_.InstanceId -match 'VID_18D1|VID_1209|VID_05C6|VID_05AC' } | ForEach-Object { "$($_.Status) $($_.FriendlyName) $($_.InstanceId)" }
