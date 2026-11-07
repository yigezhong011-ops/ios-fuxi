# Waits until the phone has left fastboot and come back, then runs one auto test. Usage: wait-then-test.ps1 <image name> <timeout seconds> [minutes to wait]
param([string]$Name, [int]$Timeout = 540, [int]$Minutes = 120)
$f = 'E:\DSH-Fuxi\tools\platform-tools\fastboot.exe'
$start = Get-Date
$gone = $false
while (((Get-Date) - $start).TotalMinutes -lt $Minutes) {
  $d = & $f devices
  if (-not $d) { $gone = $true }
  if ($gone -and $d) { break }
  Start-Sleep 2
}
if (-not ($gone -and $d)) { "phone did not come back within $Minutes minutes"; exit 2 }
"fastboot back at " + (Get-Date).ToString('HH:mm:ss')
& E:\DSH-Fuxi\dump\wsl\run-auto-test.ps1 -Name $Name -Timeout $Timeout
