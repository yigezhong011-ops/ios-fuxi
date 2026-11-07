# Temp boot the step recorder repeatedly and write down the time back to fastboot. Each boot's extra delay reads out the previous boot's last step.
# Flashes nothing, does not enter TWRP. Waits for fastboot between tries, which after a hang needs the keys or an auto-returning boot_b.
param([int]$Tries = 3, [int]$Base = 109, [int]$Secs = 4, [string]$Image = 't50-auto-marker4', [int]$StopAfterHangs = 0)
$f = 'E:\DSH-Fuxi\tools\platform-tools\fastboot.exe'
$session = 'E:\DSH-Fuxi\dump\wsl\qud-session.ps1'
$res = 'E:\DSH-Fuxi\logs\step-chain-results.txt'
function Note([string]$s) { $line = (Get-Date).ToString('HH:mm:ss') + ' ' + $s; $line; Add-Content -Path $res -Value $line -Encoding UTF8 }
Note "chain start $Image tries $Tries"
$hangs = 0
for ($n = 1; $n -le $Tries; $n++) {
  while (-not (& $f devices)) { Start-Sleep 3 }
  $out = & $session -Name $Image -Timeout 7200 -AskAfter 9999 -Verbs PING
  $m = [regex]::Match(($out -join "`n"), 'BACK in fastboot after (\d+) s')
  if (-not $m.Success) { Note "try $n did not return within 2 h; stopping"; exit 1 }
  $secs = [int]$m.Groups[1].Value; $com = [bool]($out -match 'COM3 open after')
  $step = [math]::Round(($secs - $Base) / $Secs, 1)
  Note "try $n back after $secs s, COM3 $com, previous boot's last step reads $step"
  if (-not $com) { $hangs++; if ($StopAfterHangs -gt 0 -and $hangs -ge $StopAfterHangs) { $n++; while (-not (& $f devices)) { Start-Sleep 3 }; Note 'hang seen; one more boot to read it'; $out = & $session -Name $Image -Timeout 7200 -AskAfter 9999 -Verbs PING; $m = [regex]::Match(($out -join "`n"), 'BACK in fastboot after (\d+) s'); if ($m.Success) { $secs = [int]$m.Groups[1].Value; Note "readout boot back after $secs s, the hung boot's last step reads $([math]::Round(($secs - $Base) / $Secs, 1))" }; break } }
  Start-Sleep 3
}
while (-not (& $f devices)) { Start-Sleep 3 }
cmd /c "`"$f`" set_active b 2>&1"
Note 'chain end; phone in fastboot on slot b'
