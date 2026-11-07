# Repeats qud-session.ps1 until one run gets a REBOOT reply. Stops after -Tries runs, or as soon as the phone is not in fastboot within -WaitFastboot seconds.
# Only temp boots (fastboot boot) and set_active b: flashes nothing.
# Usage: qud-retry.ps1 -Name <image without .img> [-Tries 5] [-WaitFastboot 180]
param([string]$Name, [int]$Tries = 5, [int]$WaitFastboot = 180)
$f = 'E:\DSH-Fuxi\tools\platform-tools\fastboot.exe'
$session = 'E:\DSH-Fuxi\dump\wsl\qud-session.ps1'
function Get-Others { @(Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" | Where-Object { $_.CommandLine -match 'qud-session\.ps1' -and $_.ProcessId -ne $PID }).Count }
while ((Get-Others) -gt 0) { Start-Sleep 5 }
for ($n = 1; $n -le $Tries; $n++) {
  $deadline = (Get-Date).AddSeconds($WaitFastboot)
  while (-not (& $f devices) -and (Get-Date) -lt $deadline) { Start-Sleep 3 }
  if (-not (& $f devices)) { "RESULT stopped: phone not in fastboot after $WaitFastboot s, before try $n"; exit 2 }
  "=== try $n of $Tries at " + (Get-Date).ToString('HH:mm:ss')
  $out = & $session -Name $Name -Timeout 270 -AskAfter 90 -Verbs PING,REBOOT
  $out
  $reply = $out | Where-Object { $_ -match 'SXNU1R \w+ \w+ REBOOT ' }
  if ($reply) { "RESULT replied on try $n"; exit 0 }
}
"RESULT no REBOOT reply in $Tries tries"
exit 1
