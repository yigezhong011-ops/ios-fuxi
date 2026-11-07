# Does the GPU stall after cold Settings, home, Notes? Alternates g7grant (all cores) and g7f9 (core mask f9), one boot per try. Temp boot only; writes no partition.
param([int]$Rounds = 4)
$cycle = 'tap 225 300; wait 4; probe s; home; wait 3; tap 313 300; wait 4; probe n; home; wait 3; probe h'
$Steps = "ready 250; wait 45; home; wait 5; probe d; $cycle; $cycle; $cycle"
foreach ($r in 1..$Rounds) {
  foreach ($name in 't50-auto-g7grant', 't50-auto-g7f9') {
    $null = & 'E:\DSH-Fuxi\dump\wsl\ctl-run.ps1' -Name $name -Steps $Steps -Timeout 400
    $com = Get-ChildItem 'E:\DSH-Fuxi\logs' -Filter "com3-$name-*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    $text = [IO.File]::ReadAllText($com.FullName)
    $m = [regex]::Matches($text, 'FUXI120S g=\d+ hid=(\d+) seq=\d+ calls=(\d+) to=\d+ sub=(\d+) done=(\d+) ibs=(\d+)')
    if ($m.Count) {
      $l = $m[$m.Count - 1]
      $sub = [int]$l.Groups[3].Value; $done = [int]$l.Groups[4].Value; $ibs = [int]$l.Groups[5].Value
      # A stall: fences stop while the submission counter runs far ahead of them.
      $stuck = ($ibs - $sub) -gt 1000
      $panics = [regex]::Matches($text, 'panic[(]').Count
      "round $r $name rows $($m.Count) sub=$sub done=$done ibs=$ibs stalled=$stuck panic=$panics log=$($com.Name)"
    } else { "round $r $name no rows log=$($com.Name)" }
  }
}
