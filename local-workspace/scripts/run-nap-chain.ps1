# Unattended while the user sleeps: temp boot the high-slot log image, pulling the log window after every try, until enough odd boots are caught; then the wallpaper test.
# Flashes nothing. Stops and waits if the phone does not come back; nothing here can force it.
param([int]$Tries = 16, [int]$WantOdd = 3, [int]$GoodWithin = 140, [string]$Image = 't50-auto-hanghigh', [switch]$NoWallpaper)
$f = 'E:\DSH-Fuxi\tools\platform-tools\fastboot.exe'
$session = 'E:\DSH-Fuxi\dump\wsl\qud-session.ps1'
$res = 'E:\DSH-Fuxi\logs\nap-chain-results.txt'
function Note([string]$s) { $line = (Get-Date).ToString('HH:mm:ss') + ' ' + $s; $line; Add-Content -Path $res -Value $line -Encoding UTF8 }
Note 'chain start'
$odd = 0
for ($n = 1; $n -le $Tries -and $odd -lt $WantOdd; $n++) {
  while (-not (& $f devices)) { Start-Sleep 3 }
  $tag = 'hh-' + (Get-Date).ToString('HHmmss')
  Note "try $n as $tag"
  $out = & $session -Name $Image -Timeout 7200 -AskAfter 9999 -Verbs PING
  $out | ForEach-Object { "  $_" }
  $m = [regex]::Match(($out -join "`n"), 'BACK in fastboot after (\d+) s')
  if (-not $m.Success) { Note "try $n did not return within 2 h; stopping"; exit 1 }
  $secs = [int]$m.Groups[1].Value; $com = [bool]($out -match 'COM3 open after')
  $isOdd = ($secs -gt $GoodWithin) -or (-not $com)
  if ($isOdd) { $odd++ }
  Note "try $n back after $secs s, COM3 $com, odd $isOdd"
  Start-Sleep 3
  & 'E:\DSH-Fuxi\dump\wsl\pull-log-only.ps1' -Name $tag | Select-Object -Last 1
  Start-Sleep 3
}
Note "hunt done: $odd odd boots"
if (-not $NoWallpaper) {
  & 'E:\DSH-Fuxi\dump\wsl\run-storefix-chain.ps1' -Tries 3 -LastStart '23:59'
  Note "storefix exit $LASTEXITCODE"
}
while (-not (& $f devices)) { Start-Sleep 3 }
cmd /c "`"$f`" set_active b 2>&1"
Note 'chain end; phone in fastboot on slot b'
