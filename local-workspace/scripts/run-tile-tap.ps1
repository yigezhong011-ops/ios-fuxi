# Tap into gallery tiles on both grant images. Temp boots only; writes no partition. Starts and ends in fastboot on slot b.
$S = 'E:\DSH-Fuxi\dump\wsl'
$Steps = 'at 100; press 180 400 1000; wait 6; tap 316 740; wait 12; swipe 180 650 180 150 400; wait 4; tap 292 465; wait 25; shot k3; tap 45 55; wait 5; tap 68 750; wait 25; shot pride; tap 45 55; wait 5; swipe 180 650 180 150 400; wait 4; tap 68 370; wait 25; shot hello; wait 3'
foreach ($n in 't50-auto-g7grant', 't50-auto-g7plugrant') {
  "=== $n  $(Get-Date -Format HH:mm:ss)"
  & "$S\ctl-run.ps1" -Name $n -Steps $Steps -Timeout 420 | Select-Object -Last 12
}
"=== finished $(Get-Date -Format HH:mm:ss)"
