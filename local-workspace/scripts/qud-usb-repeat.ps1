# Repeats normal boots from what is flashed in boot_b: COM3, one screenshot, REBOOT to fastboot. Writes no partition. Stops at the first failure so nobody has to chase a stuck phone.
param([int]$Count = 5, [string]$Name = 't50-daily-usbstart', [int]$At = 60)
$pass = 0
foreach ($i in 1..$Count) {
  $out = & E:\DSH-Fuxi\dump\wsl\qud-shot.ps1 -Name $Name -Installed -At $At -Timeout 240 2>&1 | ForEach-Object { "$_" }
  $com = ($out | Select-String 'COM3 open after (\d+)' | Select-Object -First 1)
  $back = ($out | Select-String 'BACK in fastboot after (\d+) s, (\d+) s after REBOOT' | Select-Object -First 1)
  $shot = [bool]($out | Select-String 'shot 1 done')
  "run ${i}: $(if ($com) { $com.Matches[0].Groups[1].Value + ' s to COM3' } else { 'NO COM3' }); shot $shot; $(if ($back) { 'back ' + $back.Matches[0].Groups[1].Value + ' s, ' + $back.Matches[0].Groups[2].Value + ' s after REBOOT' } else { 'NOT BACK' })"
  if ($com -and $back) { $pass++ } else { "stopped at run $i"; $out | Select-Object -Last 4; break }
}
"RESULT $pass of $Count"
