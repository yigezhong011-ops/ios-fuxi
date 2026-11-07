# Temp boot: what the display validator recorded about the refused swaps. Writes no partition.
param([string]$Name = 't50-auto-m2vrej')
& 'E:\DSH-Fuxi\dump\wsl\ctl-run.ps1' -Name $Name -Steps 'at 90; probe; wait 10; probe; wait 20; shot end; wait 3' -Timeout 300 | Where-Object { $_ -match 'FALLBACK|retrying|not answered|shot-|NO REPLY' }
$com = Get-ChildItem 'E:\DSH-Fuxi\logs' -Filter "com3-$Name-*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
$text = [IO.File]::ReadAllText($com.FullName)
"panics " + [regex]::Matches($text, 'panic[(]').Count + " rejected lines " + [regex]::Matches($text, 'verify_swap failed').Count + " log " + $com.Name
$text -split "`n" | Where-Object { $_ -match 'FUXI120[SRQPO]' } | Select-Object -Last 10
