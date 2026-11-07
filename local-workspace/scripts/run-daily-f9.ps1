# Temp boots a daily image, or attaches to the flashed one, and measures: about 218 GPU submissions per swipe means the f9 kernel, about 120 the old one. Writes no partition.
param([string]$Name = 't50-daily-g7f9', [switch]$Attach)
$one = 'probe a; swipe 300 400 60 400 1000; wait 1; probe b; swipe 60 400 300 400 1000; wait 1'
$Steps = "ready 250; wait 45; home; wait 5; shot desk; $one; $one; $one; tap 225 300; wait 4; shot settings; home; wait 3; tap 313 300; wait 4; shot notes; home; wait 3; shot end"
if ($Attach) {
  & 'E:\DSH-Fuxi\dump\wsl\ctl-run.ps1' -Attach -Steps $Steps -Timeout 400 -NoArgCheck | Where-Object { $_ -match 'ready=|shot-|done|not answered|back in|NO REPLY' }
  $label = 'attach'
} else {
  & 'E:\DSH-Fuxi\dump\wsl\ctl-run.ps1' -Name $Name -Steps $Steps -Timeout 400 -NoArgCheck | Where-Object { $_ -match 'ready=|shot-|done|not answered|back in|NO REPLY' }
  $label = $Name
}
$com = Get-ChildItem 'E:\DSH-Fuxi\logs' -Filter "com3-$label-*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
wsl.exe -u root -- python3 -I /mnt/e/DSH-Fuxi/dump/wsl/swipe-rate-simple.py ('/mnt/e/DSH-Fuxi/logs/' + $com.Name)
