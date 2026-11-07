# Core masks inside one boot: ff, f8, f9, ff again, six desktop swipes each. Temp boot only; writes no partition. Starts and ends in fastboot on slot b.
param([string]$Name = 't50-auto-g7cpu')
$Masks = 'ff', 'f8', 'f9', 'ff'
$one = 'probe a; swipe 300 400 60 400 1000; wait 1; probe b; swipe 60 400 300 400 1000; wait 1'
$block = ($one, $one, $one) -join '; '
$parts = foreach ($m in $Masks) { "cores $m; wait 3; $block" }
$Steps = "ready 250; wait 20; home; wait 5; shot desk; " + ($parts -join '; ') + "; shot end"
& 'E:\DSH-Fuxi\dump\wsl\ctl-run.ps1' -Name $Name -Steps $Steps -Timeout 400 | Where-Object { $_ -match 'ready=|FALLBACK|retrying|shot-|done|not answered|back in' }
$com = Get-ChildItem 'E:\DSH-Fuxi\logs' -Filter "com3-$Name-*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
$p = '/mnt/e/DSH-Fuxi/logs/' + $com.Name
wsl.exe -u root -- python3 -I /mnt/e/DSH-Fuxi/dump/wsl/swipe-rate.py $p ($Masks -join ',')
