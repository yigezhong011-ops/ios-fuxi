# Temp boots the high-slot log image until a boot does not return by itself; then pulls the log window. Flashes nothing.
# A good boot of this image comes back on its own within about 130 s (autoreset 60). A hang falls into daily, which only comes back when the user forces fastboot.
param([string]$Name = 't50-auto-hanghigh', [int]$Tries = 12, [int]$GoodWithin = 140)
$f = 'E:\DSH-Fuxi\tools\platform-tools\fastboot.exe'
$session = 'E:\DSH-Fuxi\dump\wsl\qud-session.ps1'
$start = Get-Date
for ($n = 1; $n -le $Tries; $n++) {
  while (-not (& $f devices)) { if (((Get-Date) - $start).TotalMinutes -gt 60) { 'RESULT gave up waiting for fastboot'; exit 2 }; Start-Sleep 3 }
  "=== try $n of $Tries at " + (Get-Date).ToString('HH:mm:ss')
  $out = & $session -Name $Name -Timeout 2400 -AskAfter 9999 -Verbs PING
  $out
  $m = [regex]::Match(($out -join "`n"), 'BACK in fastboot after (\d+) s')
  if (-not $m.Success) { 'RESULT did not return to fastboot in 40 min'; exit 1 }
  if ([int]$m.Groups[1].Value -gt $GoodWithin -or -not ($out -match 'COM3 open after')) {
    Start-Sleep 3
    & 'E:\DSH-Fuxi\dump\wsl\pull-log-only.ps1' -Name 'hanghigh'
    "RESULT stopped on try $n after $($m.Groups[1].Value) s; log in logs\carve-hanghigh"
    exit 0
  }
  Start-Sleep 3
}
& 'E:\DSH-Fuxi\dump\wsl\pull-log-only.ps1' -Name 'hanghigh'
"RESULT no hang in $Tries tries"
