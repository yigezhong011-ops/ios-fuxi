# App open time per core mask, one fresh boot per mask, so round 1 is a cold start. Temp boot only; writes no partition. Starts and ends in fastboot on slot b.
param([string]$Name = 't50-auto-g7cpu', [string[]]$Masks = @('ff', 'f8', 'f9', 'ff'))
$Apps = @(@('settings', 225, 300), @('notes', 313, 300), @('photos', 47, 300), @('health', 47, 625))
$rows = New-Object System.Collections.ArrayList
foreach ($m in $Masks) {
  $s = "ready 250; wait 20; home; wait 5; cores $m; wait 3"
  foreach ($round in 1..3) {
    foreach ($app in $Apps) {
      $s += "; opentime $($app[0])-$round $($app[1]) $($app[2]) 6; home; wait 3"
    }
  }
  $s += '; shot end'
  'mask ' + $m
  $out = & 'E:\DSH-Fuxi\dump\wsl\ctl-run.ps1' -Name $Name -Steps $s -Timeout 400
  foreach ($line in $out) {
    if ("$line" -match 'open (\w+)-(\d) first=([-\d.]+) last=([-\d.]+) polls=(\d+)') {
      $null = $rows.Add([pscustomobject]@{ Mask = $m; App = $Matches[1]; Round = [int]$Matches[2]; First = [double]$Matches[3]; Last = [double]$Matches[4]; Polls = [int]$Matches[5] })
      "$line"
    } elseif ("$line" -match 'ready=|FALLBACK|retrying|not answered|back in|shot-') { "$line" }
  }
}
$rows | Export-Csv 'E:\DSH-Fuxi\logs\open-ab.csv' -NoTypeInformation -Encoding utf8
function Median($v) { $s = @($v | Sort-Object); if ($s.Count) { $s[[int][math]::Floor($s.Count / 2)] } else { -1 } }
'summary: seconds, median of the last screen change; Polls is captures per open'
foreach ($pos in 0..($Masks.Count - 1)) {
  $m = $Masks[$pos]
  $mine = @($rows | Where-Object { $_.Mask -eq $m })
  $cold = @($mine | Where-Object { $_.Round -eq 1 })
  $warm = @($mine | Where-Object { $_.Round -gt 1 })
  "{0}: cold first {1} last {2}  warm first {3} last {4}  n {5}" -f $m, (Median $cold.First), (Median $cold.Last), (Median $warm.First), (Median $warm.Last), $mine.Count
}
