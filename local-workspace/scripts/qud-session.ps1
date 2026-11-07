# Temp boots an auto-resetting image, captures COM3 and talks to the kernel's USB control channel (SXNU1 protocol, QcomXnuUsbDebug).
# Sends HELLO, then -Verbs (default PING, STATUS, SCREENSHOT: nothing that reboots the phone). Pass REBOOT in -Verbs to test it; the run then ends 90 s later.
# Usage: qud-session.ps1 -Name <image without .img> [-Timeout 480] [-AskAfter 110] [-Verbs PING,REBOOT]
param([string]$Name, [int]$Timeout = 480, [int]$AskAfter = 110, [string[]]$Verbs = @('PING', 'STATUS', 'SCREENSHOT'))
$f = 'E:\DSH-Fuxi\tools\platform-tools\fastboot.exe'
$img = "E:\DSH-Fuxi\$Name.img"
if (-not (Test-Path $img)) { "no $img"; exit 1 }
if (-not (& $f devices)) { 'phone not in fastboot'; exit 1 }

function Get-Crc([string]$text) {
  [long]$crc = 4294967295
  foreach ($b in [Text.Encoding]::ASCII.GetBytes($text)) {
    $crc = $crc -bxor [long]$b
    for ($i = 0; $i -lt 8; $i++) {
      if ($crc -band 1) { $crc = ($crc -shr 1) -bxor 3988292384 } else { $crc = $crc -shr 1 }
    }
  }
  return ($crc -bxor 4294967295)
}
function Get-Frame([string]$verb, [string]$session, [long]$seq) {
  $body = 'SXNU1 {0} {1:x8} {2}' -f $session, $seq, $verb
  return ('{0} {1:x8}' -f $body, (Get-Crc $body)) + "`n"
}

$null = cmd /c "`"$f`" set_active b 2>&1"
Start-Sleep 2
$start = Get-Date
"boot $Name at " + $start.ToString('HH:mm:ss')
& $f boot $img 2>&1 | Select-Object -Last 1
$out = "E:\DSH-Fuxi\logs\com3-$Name-" + $start.ToString('HHmmss') + '.log'
$end = $start.AddSeconds($Timeout)
$gone = $false; $port = $null; $back = $null; $all = ''
$step = 0; $session = '0000000000000000'; [long]$seq = 0; $seen = 0; $nextAsk = $start.AddSeconds($AskAfter); $tries = 0
while ((Get-Date) -lt $end) {
  if (-not $port -and ([System.IO.Ports.SerialPort]::GetPortNames() -contains 'COM3')) {
    try {
      $port = New-Object System.IO.Ports.SerialPort 'COM3', 115200, 'None', 8, 'One'
      $port.DtrEnable = $true; $port.ReadTimeout = 300; $port.WriteTimeout = 2000; $port.Open()
      "COM3 open after " + [int]((Get-Date) - $start).TotalSeconds + " s"
    } catch { $port = $null }
  }
  if ($port) {
    try {
      $chunk = $port.ReadExisting()
      if ($chunk) {
        [System.IO.File]::AppendAllText($out, $chunk)
        $all += $chunk
        if ($all.Length -gt 200000) { $seen = [Math]::Max(0, $seen - ($all.Length - 100000)); $all = $all.Substring($all.Length - 100000) }
      }
      $found = [regex]::Matches($all.Substring($seen), 'SXNU1R [^\r\n]*')
      foreach ($m in $found) {
        "[{0,4}s] {1}" -f [int]((Get-Date) - $start).TotalSeconds, $m.Value
        if ($m.Value -match '^SXNU1R (\w{16}) \w{8} HELLO OK .*last_seq=(\w+)') {
          $session = $Matches[1]; $seq = [Convert]::ToInt64($Matches[2], 16); $step = 1; $nextAsk = Get-Date
        } elseif ($step -ge 1) { $nextAsk = Get-Date }
      }
      if ($found.Count) { $seen = $found[$found.Count - 1].Index + $seen + $found[$found.Count - 1].Length }
      if ((Get-Date) -ge $nextAsk) {
        if ($step -eq 0 -and $tries -lt 20) {
          $tries++
          $port.Write((Get-Frame 'HELLO' $session 0))
          $nextAsk = (Get-Date).AddSeconds(5)
        } elseif ($step -ge 1 -and $step -le $Verbs.Count) {
          $seq++
          $port.Write((Get-Frame $Verbs[$step - 1] $session $seq))
          if ($Verbs[$step - 1] -eq 'REBOOT') { $end = (Get-Date).AddSeconds(90); "[{0,4}s] REBOOT sent" -f [int]((Get-Date) - $start).TotalSeconds }
          $step++
          $nextAsk = (Get-Date).AddSeconds(30)
        } else { $nextAsk = $end }
      }
    } catch { try { $port.Close() } catch {}; $port = $null; "port lost after " + [int]((Get-Date) - $start).TotalSeconds + " s" }
  }
  $d = & $f devices
  if (-not $d) { $gone = $true }
  if ($gone -and $d) { $back = (Get-Date) - $start; break }
  Start-Sleep -Milliseconds 300
}
if ($port) { try { $port.Close() } catch {} }
if ($back) { "BACK in fastboot after " + [int]$back.TotalSeconds + " s" } else { "NOT back within $Timeout s (left the bootloader: $gone)" }
if (Test-Path $out) { "serial log $out bytes " + (Get-Item $out).Length; "control replies in log: " + @(Select-String -Path $out -SimpleMatch 'SXNU1R').Count }
$null = cmd /c "`"$f`" set_active b 2>&1"
