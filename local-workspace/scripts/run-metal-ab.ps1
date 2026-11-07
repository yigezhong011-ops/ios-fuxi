# Old plugin then new plugin, the same gestures, unified log captured after each. Temp boots and reads only; writes no partition.
# Starts and ends in fastboot on slot b. Each capture is reduced to a count file, then its large text is removed.
param([string[]]$Names = @('t50-auto-gpu7tap', 't50-auto-g7plug'))
$S = 'E:\DSH-Fuxi\dump\wsl'; $W = '/mnt/e/DSH-Fuxi/dump/wsl'; $L = '/mnt/e/DSH-Fuxi/logs'
$Steps = 'at 110; home; wait 3; tap 225 300; wait 6; shot settings; home; wait 3; tap 47 300; wait 6; shot photos; home; wait 3; tap 47 625; wait 6; shot health; home; wait 3; shot end'
function Count([string]$dir) {
  wsl.exe -u root -- python3 -I "$W/metal-kinds.py" count "$L/carve-$dir/lscan.txt" "$L/carve-$dir/kinds.json"
}
Count 'g7plug'
Remove-Item -LiteralPath 'E:\DSH-Fuxi\logs\carve-g7plug\lscan.txt' -Confirm:$false
$prev = 'g7plug'
foreach ($n in $Names) {
  "=== $n  $(Get-Date -Format HH:mm:ss)"
  & "$S\ctl-run.ps1" -Name $n -Steps $Steps -Timeout 520 | Select-Object -Last 14
  $tag = "ab-$n"
  & "$S\pull-wall.ps1" -Name $tag | Select-Object -Last 3
  Count $tag
  Remove-Item -LiteralPath "E:\DSH-Fuxi\logs\carve-$tag\lscan.txt" -Confirm:$false
  "--- growth during $n"
  wsl.exe -u root -- python3 -I "$W/metal-kinds.py" diff "$L/carve-$prev/kinds.json" "$L/carve-$tag/kinds.json"
  $prev = $tag
}
"=== finished $(Get-Date -Format HH:mm:ss)"
