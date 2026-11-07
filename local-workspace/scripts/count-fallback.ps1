# Read only: boots and fall-throughs per image, from the COM3 logs and control run logs written today.
$L = 'E:\DSH-Fuxi\logs'; $today = (Get-Date).Date
$rows = Get-ChildItem $L -File -Filter 'ctl-*' -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -ge $today } | Sort-Object LastWriteTime
'control logs ' + @($rows).Count
$sum = @{}
foreach ($f in $rows) {
  $t = Get-Content -LiteralPath $f.FullName -Raw -ErrorAction SilentlyContinue
  if ($f.Name -match '^ctl-(.+)-\d{6}') { $n = $Matches[1] } else { $n = $f.Name }
  $b = [regex]::Matches([string]$t, '\bboot t\d+').Count
  $x = [regex]::Matches([string]$t, 'FALLBACK').Count
  if (-not $sum.ContainsKey($n)) { $sum[$n] = @(0, 0, 0) }
  $sum[$n][0]++; $sum[$n][1] += $b; $sum[$n][2] += $x
}
$sum.GetEnumerator() | Sort-Object Name | ForEach-Object { '{0,-24} runs {1,3} boots {2,3} fell {3,3}' -f $_.Name, $_.Value[0], $_.Value[1], $_.Value[2] }
Get-ChildItem $L -File | Where-Object { $_.LastWriteTime -ge $today -and $_.Name -match 't50-auto-m2vs' -and $_.Name -notmatch '^(shot|com3)' } | Select-Object -First 4 Name
