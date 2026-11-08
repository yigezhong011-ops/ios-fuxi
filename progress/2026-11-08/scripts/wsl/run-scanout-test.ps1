# Compare display paths (sheng-dpu-scanout values): same swipe block, records scanout timeouts.
param([string]$ImageList = 't50-auto-m2vsb,t50-auto-m2vsb-so1,t50-auto-m2vsb-so2', [int]$Rounds = 2, [int]$Timeout = 420)
$csv = 'E:\DSH-Fuxi\logs\scanout-1108.csv'
if (-not (Test-Path $csv)) { Set-Content -Path $csv -Value 'round,image,valid,desk_bytes,probe_crcs,to_first,to_last,to_delta,calls_delta,sub_delta,g,url' }
$one = 'swipe 300 400 60 400 1000; wait 6; probe a{n}; swipe 60 400 300 400 1000; wait 6; probe b{n}'
$sw = for ($i = 1; $i -le 3; $i++) { $one.Replace('{n}', $i) }
$Steps = 'ready 250; wait 20; home; wait 6; home; wait 6; shot desk; ' + ($sw -join '; ') + '; shot end'
$images = @($ImageList -split ',' | Where-Object { $_ })
foreach ($round in 1..$Rounds) {
  foreach ($img in $images) {
    Write-Output ("=== round $round image $img ===")
    $null = & 'E:\DSH-Fuxi\dump\wsl\ctl-run.ps1' -Name $img -Steps $Steps -Timeout $Timeout
    $runFile = Get-ChildItem 'E:\DSH-Fuxi\logs' -Filter 'run-*.txt' | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    $text = Get-Content $runFile.FullName -Raw
    $valid = -not ($text -match 'FALLBACK')
    $desk = if ($text -match 'shot desk (\d+) bytes') { [int]$Matches[1] } else { 0 }
    $probes = [regex]::Matches($text, 'probe [ab]\d .*?([0-9a-f]{8})\s*$', 'Multiline') | ForEach-Object { $_.Groups[1].Value }
    $uniq = ($probes | Sort-Object -Unique).Count
    $com = Get-ChildItem 'E:\DSH-Fuxi\logs' -Filter "com3-$img-*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    $toF = 0; $toL = 0; $cF = 0; $cL = 0; $sF = 0; $sL = 0; $gear = ''
    if ($com) {
      $vals = @(foreach ($l in (Select-String -Path $com.FullName -Pattern 'FUXI120S' | ForEach-Object { $_.Line })) {
        if ($l -match 'g=(\d+) .*calls=(\d+) to=(\d+) sub=(\d+)') {
          [pscustomobject]@{ g = $Matches[1]; calls = [int64]$Matches[2]; to = [int64]$Matches[3]; sub = [int64]$Matches[4] }
        }
      })
      if ($vals.Count -gt 0) { $toF = $vals[0].to; $toL = $vals[-1].to; $cF = $vals[0].calls; $cL = $vals[-1].calls; $sF = $vals[0].sub; $sL = $vals[-1].sub; $gear = $vals[0].g }
    }
    Add-Content -Path $csv -Value ("{0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11}" -f $round, $img, $valid, $desk, $uniq, $toF, $toL, ($toL - $toF), ($cL - $cF), ($sL - $sF), $gear, $runFile.Name)
    Write-Output ("    valid=$valid desk=$desk probes=$uniq to=[+$($toL-$toF)] calls=[+$($cL-$cF)] sub=[+$($sL-$sF)] g=$gear")
  }
}
Write-Output '=== 汇总 ==='
Import-Csv $csv | Where-Object { $_.round } | Group-Object image | ForEach-Object {
  $rows = @($_.Group | Where-Object { $_.valid -eq 'True' })
  Write-Output ("{0}: 有效 {1}/{2}  to 增量 {3}  calls 增量 {4}  sub 增量 {5}" -f $_.Name, $rows.Count, @($_.Group).Count,
    (@($rows | ForEach-Object { [int]$_.to_delta }) -join '/'),
    (@($rows | ForEach-Object { [int]$_.calls_delta }) -join '/'),
    (@($rows | ForEach-Object { [int]$_.sub_delta }) -join '/'))
}
