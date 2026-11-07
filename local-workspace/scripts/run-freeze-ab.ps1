# Old plugin against branch plugin, same steps: open a Metal wallpaper, go back, open another. Does the GPU stop? Temp boots only; writes no partition.
param([int]$Rounds = 3)
$Out = 'E:\DSH-Fuxi\logs\freeze-ab-1107.txt'; $Fb = 'E:\DSH-Fuxi\tools\platform-tools\fastboot.exe'
$Steps = 'at 125; home; wait 6; home; wait 6; tap 225 305; wait 10; swipe 180 700 180 200 400; wait 3; swipe 180 150 180 500 400; wait 3; tap 180 511; wait 8; tap 180 511; wait 10; swipe 180 650 180 150 400; wait 5; tap 143 730; wait 25; swipe 300 400 60 400 300; wait 8; swipe 60 400 300 400 300; wait 8; swipe 300 400 60 400 300; wait 8; swipe 60 400 300 400 300; wait 8; swipe 300 400 60 400 300; wait 8; wait 1'
foreach ($r in 1..$Rounds) {
  foreach ($n in 't50-auto-g7f9', 't50-auto-m2vs') {
    foreach ($i in 1..60) { if (& $Fb devices) { break }; Start-Sleep 5 }
    $t = Get-Date -Format HH:mm:ss
    $lines = & 'E:\DSH-Fuxi\dump\wsl\ctl-run.ps1' -Name $n -Steps $Steps -Timeout 400 2>$null | Where-Object { $_ -match 'FALLBACK|shot-|NO REPLY|NO COM3|not in fastboot' }
    $com = Get-ChildItem 'E:\DSH-Fuxi\logs' -Filter "com3-$n-*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    $text = [IO.File]::ReadAllText($com.FullName)
    $rows = $text -split "`n" | Where-Object { $_ -match 'FUXI120S' }
    $last = $rows | Select-Object -Last 4 | ForEach-Object { if ($_ -match 'calls=(\d+)') { $Matches[1] } }
    $flat = ($last | Select-Object -Unique).Count -eq 1
    $rej = ($text -split "`n" | Where-Object { $_ -match 'FUXI120R' } | Select-Object -Last 1)
    $shots = ($lines | Where-Object { $_ -match 'shot-' } | ForEach-Object { if ($_ -match '(shot-\S+\.png).*encoded (\d+)') { $Matches[1] + ' ' + $Matches[2] } }) -join ' | '
    $fall = @($lines | Where-Object { $_ -match 'FALLBACK' }).Count
    $pan = [regex]::Matches($text, 'panic[(]').Count
    $row = '{0} round {1} {2} fallback={3} panics={4} rows={5} lastcalls={6} GPU_STOPPED={7} log={8} {9} {10}' -f $t, $r, $n, $fall, $pan, $rows.Count, ($last -join ','), $flat, $com.Name, $rej, $shots
    Add-Content -LiteralPath $Out -Value $row
    Write-Output $row
  }
}
"finished $(Get-Date -Format HH:mm:ss)"
