# Cold Settings per core mask, one fresh boot each, with a long window and a final screenshot. Temp boot only; writes no partition.
param([string[]]$Masks = @('ff', 'f9', 'ff', 'f9'))
foreach ($m in $Masks) {
  "mask $m"
  $s = "ready 250; wait 20; home; wait 5; cores $m; wait 3; opentime settings 225 300 25; shot settings; home; wait 3; opentime notes 313 300 8; home; wait 3; opentime appstore 135 300 12; shot appstore"
  & 'E:\DSH-Fuxi\dump\wsl\ctl-run.ps1' -Name 't50-auto-g7cpu' -Steps $s -Timeout 400 | Where-Object { $_ -match 'ready=|FALLBACK|retrying|not answered|back in|open |shot-' }
}
