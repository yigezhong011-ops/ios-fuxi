# Waits for fastboot, temp boots a 120 Hz auto-reset image while the user swipes, then pulls the log window and counts frames. Flashes nothing.
param([string]$Name = 't50-auto-120clock-p', [string]$Log = 'swipe-120', [int]$WaitSeconds = 1500, [int]$Timeout = 480)
$f = 'E:\DSH-Fuxi\tools\platform-tools\fastboot.exe'
$start = Get-Date
while (-not (& $f devices)) {
  if (((Get-Date) - $start).TotalSeconds -gt $WaitSeconds) { 'STOP phone did not reach fastboot'; exit 2 }
  Start-Sleep -Seconds 2
}
cmd /c "`"$f`" set_active b 2>&1"
Start-Sleep -Seconds 1
$out = & 'E:\DSH-Fuxi\dump\wsl\run-auto-test.ps1' -Name $Name -Timeout $Timeout
$out
if (-not ($out -match 'BACK in fastboot')) { 'STOP phone did not return to fastboot; log not pulled'; exit 1 }
Start-Sleep -Seconds 5
& 'E:\DSH-Fuxi\dump\wsl\pull-log-only.ps1' -Name $Log
wsl.exe -u root -- bash -c "d=`$(ls -d /root/fuxi/hang/$Log/*/ | head -1); tail -n 40 `$d/latest.txt | grep -E 'coherence|clocks|fence wait|scanout wait' | cut -c1-170; tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/fps-by-id.py > /tmp/fbi.py; python3 -I /tmp/fbi.py `$d 30"
"RESULT log in logs\carve-$Log"
