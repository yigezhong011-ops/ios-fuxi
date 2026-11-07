# Builds t50-auto-g7f9 and t50-daily-g7f9 (grant, old plugin, core mask 0xf9 applied by the kernel), then checks the auto one with no CPU verb. Temp boot only; writes no partition.
wsl.exe -u root -- bash -c "tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/make-t50-tap.sh > /tmp/mt9.sh; AUTO_CORES=0xf9 bash /tmp/mt9.sh t50-auto-g7f9 420 /root/fuxi/grant-t50-auto-g7grant 2>&1 | tail -6"
if (-not $?) { 'build failed'; exit 1 }
wsl.exe -u root -- bash -c "tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/make-t50-daily-g7grant.sh > /tmp/md9.sh; bash /tmp/md9.sh t50-auto-g7f9 t50-daily-g7f9 2>&1 | tail -5"
if (-not $?) { 'daily build failed'; exit 1 }
$one = 'probe a; swipe 300 400 60 400 1000; wait 1; probe b; swipe 60 400 300 400 1000; wait 1'
$block = ($one, $one, $one) -join '; '
$Steps = "ready 250; wait 45; home; wait 5; shot desk; $block; press 180 400 1000; wait 2; shot end"
& 'E:\DSH-Fuxi\dump\wsl\ctl-run.ps1' -Name 't50-auto-g7f9' -Steps $Steps -Timeout 400 | Where-Object { $_ -match 'ready=|FALLBACK|retrying|shot-|done|not answered|back in|panic' }
$com = Get-ChildItem 'E:\DSH-Fuxi\logs' -Filter 'com3-t50-auto-g7f9-*.log' | Sort-Object LastWriteTime -Descending | Select-Object -First 1
$p = '/mnt/e/DSH-Fuxi/logs/' + $com.Name
wsl.exe -u root -- python3 -I /mnt/e/DSH-Fuxi/dump/wsl/swipe-rate-simple.py $p
