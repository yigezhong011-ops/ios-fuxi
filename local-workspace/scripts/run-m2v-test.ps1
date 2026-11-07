# The branch plugin on the older kernel: does the desktop draw, and what do the Metal wallpapers do. Temp boot only; writes no partition.
param([string]$Name = 't50-auto-m2v', [int]$At = 100)
$s = "at $At; shot desk; press 180 400 1000; wait 6; shot lock; tap 316 740; wait 12; swipe 180 650 180 150 400; wait 4; tap 292 465; wait 25; shot k3; tap 45 55; wait 5; tap 68 750; wait 25; shot pride; tap 45 55; wait 5; swipe 180 650 180 150 400; wait 4; tap 68 370; wait 25; shot hello; wait 3"
& 'E:\DSH-Fuxi\dump\wsl\ctl-run.ps1' -Name $Name -Steps $s -Timeout 400 | Where-Object { $_ -match 'ready=|FALLBACK|retrying|not answered|shot-|NO REPLY' }
$com = Get-ChildItem 'E:\DSH-Fuxi\logs' -Filter "com3-$Name-*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
$text = [IO.File]::ReadAllText($com.FullName)
"panics " + [regex]::Matches($text, 'panic[(]').Count + " log " + $com.Name
$text -split "`n" | Where-Object { $_ -match 'FUXI120S' } | Select-Object -Last 4
$text -split "`n" | Where-Object { $_ -match 'Adreno|adreno|Turnip|turnip|vulkan|NativeAdrenoMetal' } | Select-Object -Last 25
