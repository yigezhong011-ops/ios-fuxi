# Top up the plugin A/B until each image has N valid runs, then summarize.
# Reuses the CSV format of run-plugin-ab.ps1 so the two can be mixed.
param([int]$Target = 3, [int]$MaxRuns = 8, [string]$ImageList = 't50-auto-g7f9sb,t50-auto-m2vsb', [int]$Timeout = 420)
$csv = 'E:\DSH-Fuxi\logs\plugin-ab-1108.csv'
if (-not (Test-Path $csv)) { Set-Content -Path $csv -Value 'round,image,valid,desk_bytes,probe_crcs,sub_first,sub_last,sub_delta,calls_first,calls_last,g,url' }
$one = 'swipe 300 400 60 400 1000; wait 6; probe a{n}; swipe 60 400 300 400 1000; wait 6; probe b{n}'
$sw = for ($i = 1; $i -le 3; $i++) { $one.Replace('{n}', $i) }
$Steps = 'ready 250; wait 20; home; wait 6; home; wait 6; shot desk; ' + ($sw -join '; ') + '; shot end'
$images = @($ImageList -split ',' | Where-Object { $_ })

function Valid-Count([string]$img) {
  $rows = Import-Csv $csv | Where-Object { $_.image -eq $img -and $_.valid -eq 'True' }
  return @($rows).Count
}
$round = 10
$runs = 0
while ($runs -lt $MaxRuns) {
  $pending = $images | Where-Object { (Valid-Count $_) -lt $Target }
  if (-not $pending) { break }
  foreach ($img in $pending) {
    if ($runs -ge $MaxRuns) { break }
    $runs++
    Write-Output ("=== top-up run $runs image $img ===")
    $null = & 'E:\DSH-Fuxi\dump\wsl\ctl-run.ps1' -Name $img -Steps $Steps -Timeout $Timeout
    $runFile = Get-ChildItem 'E:\DSH-Fuxi\logs' -Filter 'run-*.txt' | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    $text = Get-Content $runFile.FullName -Raw
    $valid = -not ($text -match 'FALLBACK')
    $desk = if ($text -match 'shot desk (\d+) bytes') { [int]$Matches[1] } else { 0 }
    $probes = [regex]::Matches($text, 'probe [ab]\d .*?([0-9a-f]{8})\s*$', 'Multiline') | ForEach-Object { $_.Groups[1].Value }
    $uniq = ($probes | Sort-Object -Unique).Count
    $com = Get-ChildItem 'E:\DSH-Fuxi\logs' -Filter "com3-$img-*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    $subFirst = 0; $subLast = 0; $callsFirst = 0; $callsLast = 0; $gear = ''
    if ($com) {
      $vals = foreach ($l in (Select-String -Path $com.FullName -Pattern 'FUXI120S' | ForEach-Object { $_.Line })) {
        if ($l -match 'g=(\d+) .*calls=(\d+) .*sub=(\d+)') { [pscustomobject]@{ g = $Matches[1]; calls = [int64]$Matches[2]; sub = [int64]$Matches[3] } }
      }
      $vals = @($vals)
      if ($vals.Count -gt 0) { $subFirst = $vals[0].sub; $subLast = $vals[-1].sub; $callsFirst = $vals[0].calls; $callsLast = $vals[-1].calls; $gear = $vals[0].g }
    }
    Add-Content -Path $csv -Value ("{0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11}" -f $round, $img, $valid, $desk, $uniq, $subFirst, $subLast, ($subLast - $subFirst), $callsFirst, $callsLast, $gear, $runFile.Name)
    Write-Output ("    valid=$valid desk=$desk probes=$uniq sub=$($subLast - $subFirst) calls=$($callsLast - $callsFirst) g=$gear")
  }
}
Write-Output '=== 汇总 ==='
Import-Csv $csv | Where-Object { $_.round } | Group-Object image | ForEach-Object {
  $rows = @($_.Group | Where-Object { $_.valid -eq 'True' })
  $d = @($rows | ForEach-Object { [int]$_.sub_delta })
  $p = @($rows | ForEach-Object { [int]$_.probe_crcs })
  $med = { param($a) if ($a.Count) { ($a | Sort-Object)[[int](($a.Count - 1) / 2)] } else { 'n/a' } }
  Write-Output ("{0}: 有效 {1}/{2}  sub 增量 {3}  画面变化 {4}" -f $_.Name, $rows.Count, @($_.Group).Count, (& $med $d), (& $med $p))
}
