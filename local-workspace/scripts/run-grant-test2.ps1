# Long stop on the blank gallery tiles, longer grant, new plugin then old. Temp boots and reads only; writes no partition. Starts and ends in fastboot on slot b.
$S = 'E:\DSH-Fuxi\dump\wsl'; $Lg = 'E:\DSH-Fuxi\logs'
$Steps = 'at 120; press 180 400 1000; wait 6; tap 316 740; wait 12; swipe 180 650 180 150 400; wait 90; shot unity; swipe 180 650 180 150 400; wait 60; shot hello; wait 20'
Remove-Item -LiteralPath "$Lg\carve-plugrant\lscan.txt", "$Lg\carve-ab2-t50-auto-gpu7tap\lscan.txt", "$Lg\carve-ab2-t50-auto-g7plug\lscan.txt" -Confirm:$false -ErrorAction SilentlyContinue
foreach ($n in 't50-auto-g7plugrant', 't50-auto-g7grant') {
  "=== $n  $(Get-Date -Format HH:mm:ss)"
  & "$S\ctl-run.ps1" -Name $n -Steps $Steps -Timeout 420 | Select-Object -Last 9
  $tag = "long-$n"
  & "$S\pull-wall.ps1" -Name $tag | Select-Object -Last 1
  wsl.exe -u root -- bash -c "tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/read-stretch.sh > /tmp/rs.sh; bash /tmp/rs.sh $tag"
  $com = Get-ChildItem $Lg -Filter "com3-$n-*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
  "--- $($com.Name) GPU denials"
  Select-String -LiteralPath $com.FullName -Pattern 'AGXDeviceUserClient failed MACF in process pid \d+, (\S+)' | ForEach-Object { $_.Matches[0].Groups[1].Value } | Group-Object | ForEach-Object { '{0,5} {1}' -f $_.Count, $_.Name }
}
"=== finished $(Get-Date -Format HH:mm:ss)"
