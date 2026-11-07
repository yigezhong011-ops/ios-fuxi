# Alternates temp boots of two auto-resetting images and records each result. Stops when the phone does not come back by itself.
# Usage: run-ab.ps1 <image A> <image B> <rounds>
param([string]$A, [string]$B, [int]$Rounds = 3)
$f = 'E:\DSH-Fuxi\tools\platform-tools\fastboot.exe'
$res = 'E:\DSH-Fuxi\logs\ab-results.txt'
$queue = @(); for ($i = 0; $i -lt $Rounds; $i++) { $queue += $A; $queue += $B }
foreach ($n in $queue) {
  if (-not (& $f devices)) { "phone not in fastboot, stopping before $n"; break }
  $null = cmd /c "`"$f`" set_active b 2>&1"
  Start-Sleep 2
  $t = (Get-Date).ToString('HH:mm:ss')
  $o = & E:\DSH-Fuxi\dump\wsl\run-auto-test.ps1 -Name $n -Timeout 480 | Out-String
  $back = [regex]::Match($o, 'BACK in fastboot after (\d+) s').Groups[1].Value
  $rates = ([regex]::Matches($o, 'FUXI120 rate')).Count
  $line = "$t $n back=$back rates=$rates"
  $line
  Add-Content -Path $res -Value $line -Encoding utf8
  if (-not $back) { "phone did not return by itself, stopping"; break }
}
$null = cmd /c "`"$f`" set_active b 2>&1"
'done'
