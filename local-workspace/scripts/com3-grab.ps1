# Opens COM3 the moment it appears and saves every byte, reopening after a drop. Sends nothing. Usage: com3-grab.ps1 -Name x -Seconds 180
param([string]$Name = 'peer-boot1', [int]$Seconds = 180)
$start = Get-Date
$out = "E:\DSH-Fuxi\logs\com3-grab-$Name-" + $start.ToString('HHmmss') + '.log'
$port = $null; $total = 0; $opens = 0
while (((Get-Date) - $start).TotalSeconds -lt $Seconds) {
  $t = [int]((Get-Date) - $start).TotalSeconds
  if (-not $port) {
    if ([System.IO.Ports.SerialPort]::GetPortNames() -contains 'COM3') {
      try {
        $port = New-Object System.IO.Ports.SerialPort 'COM3', 115200, 'None', 8, 'One'
        $port.DtrEnable = $true; $port.RtsEnable = $true; $port.ReadBufferSize = 1048576; $port.Open()
        $opens++; "open #$opens at $t s"
      } catch { $port = $null; "open failed at $t s" }
    }
    Start-Sleep -Milliseconds 30
    continue
  }
  try {
    $n = $port.BytesToRead
    if ($n -gt 0) {
      $buf = New-Object byte[] $n
      $got = $port.Read($buf, 0, $n)
      $fs = [System.IO.File]::Open($out, 'Append'); $fs.Write($buf, 0, $got); $fs.Close()
      if ($total -eq 0) { "first bytes at $t s" }
      $total += $got
    } else { Start-Sleep -Milliseconds 20 }
  } catch { "port lost at $t s, $total bytes so far"; try { $port.Close() } catch {}; $port = $null }
}
if ($port) { try { $port.Close() } catch {} }
"done: $total bytes, $opens opens, file $out"
