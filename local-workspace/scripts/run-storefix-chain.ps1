# Unattended, after qud-retry.ps1: temp boot the store fix image until one boot comes up, then pull the logs through TWRP. Flashes nothing.
# Starts nothing new after -LastStart (HH:mm), so a run does not collide with the user coming back.
param([string]$Name = 't50-auto-storefix', [string]$Log = 'storefix', [int]$Tries = 4, [string]$LastStart = '12:15')
$f = 'E:\DSH-Fuxi\tools\platform-tools\fastboot.exe'
$session = 'E:\DSH-Fuxi\dump\wsl\qud-session.ps1'
$limit = [datetime]::ParseExact($LastStart, 'HH:mm', $null)
function Get-Others { @(Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" | Where-Object { $_.CommandLine -match 'qud-(retry|session)\.ps1' -and $_.ProcessId -ne $PID }).Count }
while ((Get-Others) -gt 0) { if ((Get-Date) -gt $limit) { "RESULT stopped at $LastStart while the REBOOT test still waited for the phone"; exit 3 }; Start-Sleep 10 }
for ($n = 1; $n -le $Tries; $n++) {
  while (-not (& $f devices)) { if ((Get-Date) -gt $limit) { "RESULT stopped at $LastStart with the phone not in fastboot, before try $n"; exit 2 }; Start-Sleep 5 }
  if ((Get-Date) -gt $limit) { "RESULT stopped at $LastStart, before try $n"; exit 2 }
  "=== try $n of $Tries at " + (Get-Date).ToString('HH:mm:ss')
  $out = & $session -Name $Name -Timeout 480 -AskAfter 110
  $out
  if (($out -match 'SXNU1R .* HELLO OK') -and ($out -match 'BACK in fastboot')) {
    Start-Sleep 5
    & 'E:\DSH-Fuxi\dump\wsl\pull-wall.ps1' -Name $Log
    "RESULT booted on try $n; logs in logs\carve-$Log"
    exit 0
  }
}
"RESULT no complete boot in $Tries tries"
exit 1
