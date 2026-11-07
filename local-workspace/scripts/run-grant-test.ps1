# Poster gallery on the longer grant, old plugin then new. Temp boots only; writes no partition. Starts and ends in fastboot on slot b.
$S = 'E:\DSH-Fuxi\dump\wsl'; $Lg = 'E:\DSH-Fuxi\logs'
$Steps = 'at 120; press 180 400 1000; wait 6; tap 316 740; wait 12; shot gallery; swipe 180 650 180 150 400; wait 25; shot gallery2; swipe 180 650 180 150 400; wait 25; shot gallery3'
foreach ($n in 't50-auto-g7grant', 't50-auto-g7plugrant') {
  "=== $n  $(Get-Date -Format HH:mm:ss)"
  & "$S\ctl-run.ps1" -Name $n -Steps $Steps -Timeout 400 | Select-Object -Last 7
  $com = Get-ChildItem $Lg -Filter "com3-$n-*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
  "--- $($com.Name) GPU denials"
  Select-String -LiteralPath $com.FullName -Pattern 'AGXDeviceUserClient failed MACF in process pid \d+, (\S+)' -AllMatches | ForEach-Object { $_.Matches[0].Groups[1].Value } | Group-Object | ForEach-Object { '{0,5} {1}' -f $_.Count, $_.Name }
  $panics = @(Select-String -LiteralPath $com.FullName -Pattern 'panic[(]cpu').Count
  'panic lines: ' + $panics
}
"=== finished $(Get-Date -Format HH:mm:ss)"
