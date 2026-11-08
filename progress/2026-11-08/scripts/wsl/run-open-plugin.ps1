# App open time per image (plugin A/B): cold = round 1, warm = rounds 2-3.
param([string]$ImageList = 't50-auto-g7f9sb,t50-auto-m2vsb', [int]$Timeout = 420)
$csv = 'E:\DSH-Fuxi\logs\open-plugin-1108.csv'
if (-not (Test-Path $csv)) { Set-Content -Path $csv -Value 'image,app,round,first,last,polls' }
$Apps = @(@('settings', 225, 300), @('notes', 313, 300), @('photos', 47, 300), @('health', 47, 625))
foreach ($img in ($ImageList -split ',')) {
  $s = 'ready 250; wait 20; home; wait 5; cores f9; wait 3'
  foreach ($round in 1..3) {
    foreach ($app in $Apps) {
      $s += "; opentime $($app[0])-$round $($app[1]) $($app[2]) 6; home; wait 3"
    }
  }
  $s += '; shot end'
  Write-Output ("=== image $img ===")
  $out = & 'E:\DSH-Fuxi\dump\wsl\ctl-run.ps1' -Name $img -Steps $s -Timeout $Timeout
  $valid = -not (($out | Select-String -SimpleMatch 'FALLBACK') -or ($out -match 'FALLBACK'))
  foreach ($line in $out) {
    if ("$line" -match 'open (\w+)-(\d) first=([-\d.]+) last=([-\d.]+) polls=(\d+)') {
      Add-Content $csv ("{0},{1},{2},{3},{4},{5}" -f $img, $Matches[1], [int]$Matches[2], $Matches[3], $Matches[4], $Matches[5])
    }
  }
  Write-Output ("    valid=$valid")
}
Write-Output '=== 汇总（last = 最后一次画面变化，秒）==='
function Median($v) { $s = @($v | Sort-Object); if ($s.Count) { $s[[int][math]::Floor($s.Count / 2)] } else { 'n/a' } }
Import-Csv $csv | Group-Object image | ForEach-Object {
  $rows = $_.Group
  $cold = @($rows | Where-Object { [int]$_.round -eq 1 } | ForEach-Object { [double]$_.last })
  $warm = @($rows | Where-Object { [int]$_.round -gt 1 } | ForEach-Object { [double]$_.last })
  Write-Output ("{0}: cold {1}  warm {2}  n={3}" -f $_.Name, (Median $cold), (Median $warm), @($rows).Count)
}
