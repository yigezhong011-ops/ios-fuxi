# Cold Settings with and without udid-version=2, same kernel, one fresh boot each, alternating. Temp boot only; writes no partition.
param([int]$Rounds = 2)
$s = 'ready 250; wait 45; home; wait 5; opentime settings 225 300 25; shot settings; home; wait 3; opentime notes 313 300 8; home; wait 3; opentime photos 47 300 10; shot photos; home; wait 3; shot end'
foreach ($r in 1..$Rounds) {
  foreach ($name in 't50-auto-g7f9u', 't50-auto-g7f9') {
    "round $r $name"
    & 'E:\DSH-Fuxi\dump\wsl\ctl-run.ps1' -Name $name -Steps $s -Timeout 400 | Where-Object { $_ -match 'ready=|FALLBACK|retrying|not answered|open |shot-|NO REPLY' }
    $com = Get-ChildItem 'E:\DSH-Fuxi\logs' -Filter "com3-$name-*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    $text = [IO.File]::ReadAllText($com.FullName)
    "panics " + [regex]::Matches($text, 'panic[(]').Count + " log " + $com.Name
  }
}
