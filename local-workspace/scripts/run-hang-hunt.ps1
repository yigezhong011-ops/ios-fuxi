# After the REBOOT and store tests: temp boot the fast-log image until a Mi-logo hang, pulling the log of the first good boot and of the hang. Flashes nothing.
param([string]$Name = 't50-auto-hanglog', [int]$Tries = 12, [string]$LastStart = '12:15')
$f = 'E:\DSH-Fuxi\tools\platform-tools\fastboot.exe'
$session = 'E:\DSH-Fuxi\dump\wsl\qud-session.ps1'
$limit = [datetime]::ParseExact($LastStart, 'HH:mm', $null)
function Get-Others { @(Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" | Where-Object { $_.CommandLine -match 'qud-(retry|session)\.ps1|run-storefix-chain\.ps1' -and $_.ProcessId -ne $PID }).Count }
while ((Get-Others) -gt 0) { if ((Get-Date) -gt $limit) { "RESULT stopped at $LastStart while earlier tests still waited"; exit 3 }; Start-Sleep 10 }
$goodPulled = $false
for ($n = 1; $n -le $Tries; $n++) {
  while (-not (& $f devices)) { if ((Get-Date) -gt $limit) { "RESULT stopped at $LastStart with the phone not in fastboot, before try $n"; exit 2 }; Start-Sleep 5 }
  if ((Get-Date) -gt $limit) { "RESULT stopped at $LastStart, before try $n"; exit 2 }
  "=== try $n of $Tries at " + (Get-Date).ToString('HH:mm:ss')
  $out = & $session -Name $Name -Timeout 300 -AskAfter 999 -Verbs PING
  $out
  $serial = $out -match 'COM3 open after'
  $back = $out -match 'BACK in fastboot'
  if (-not $back) { "RESULT try $n did not return to fastboot; serial seen: $([bool]$serial)"; exit 1 }
  if ($serial -and -not $goodPulled) { Start-Sleep 5; & 'E:\DSH-Fuxi\dump\wsl\pull-log-only.ps1' -Name 'hanglog-good'; $goodPulled = $true }
  if (-not $serial) { Start-Sleep 5; & 'E:\DSH-Fuxi\dump\wsl\pull-log-only.ps1' -Name 'hanglog-hang'; "RESULT hang on try $n; logs in logs\carve-hanglog-hang"; exit 0 }
}
"RESULT no hang in $Tries tries"
exit 0
