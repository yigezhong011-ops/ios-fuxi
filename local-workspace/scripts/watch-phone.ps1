# Waits up to $Minutes for the phone: logs when COM3 or fastboot appears, captures COM3 while it is there. Touches nothing on the phone.
param([int]$Minutes = 225, [string]$Name = 'watch')
$f = 'E:\DSH-Fuxi\tools\platform-tools\fastboot.exe'
$start = Get-Date
$note = "E:\DSH-Fuxi\logs\watch-$Name.txt"
$out = "E:\DSH-Fuxi\logs\com3-$Name.log"
"start " + $start.ToString('HH:mm:ss') | Out-File -Append -Encoding utf8 $note
$port = $null
while (((Get-Date) - $start).TotalMinutes -lt $Minutes) {
  if (-not $port -and ([System.IO.Ports.SerialPort]::GetPortNames() -contains 'COM3')) {
    try {
      $port = New-Object System.IO.Ports.SerialPort 'COM3', 115200, 'None', 8, 'One'
      $port.DtrEnable = $true; $port.ReadTimeout = 500; $port.Open()
      "COM3 open " + (Get-Date).ToString('HH:mm:ss') | Out-File -Append -Encoding utf8 $note
    } catch { $port = $null }
  }
  if ($port) { try { [System.IO.File]::AppendAllText($out, $port.ReadExisting()) } catch { try { $port.Close() } catch {}; $port = $null; "COM3 gone " + (Get-Date).ToString('HH:mm:ss') | Out-File -Append -Encoding utf8 $note } }
  if (& $f devices) { "fastboot back " + (Get-Date).ToString('HH:mm:ss') | Out-File -Append -Encoding utf8 $note; "fastboot back"; break }
  Start-Sleep 2
}
if ($port) { try { $port.Close() } catch {} }
"end " + (Get-Date).ToString('HH:mm:ss') | Out-File -Append -Encoding utf8 $note
