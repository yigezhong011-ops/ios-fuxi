# Capture the phone's USB debug serial (t50 images only: COM3, 115200 8N1, DTR on) and count the GPU errors.
# The port appears about 40 s after boot, so this waits for it. Unplugging ends the capture.
# Usage: powershell -ExecutionPolicy Bypass -File E:\DSH-Fuxi\dump\wsl\read-com3.ps1 [seconds] [name]
param([int]$Seconds = 180, [string]$Name = 'com3')
$dir = 'E:\DSH-Fuxi\logs'
New-Item -ItemType Directory -Force $dir | Out-Null
$out = Join-Path $dir ("$Name-" + (Get-Date -Format 'MMdd-HHmmss') + '.log')
$end = (Get-Date).AddSeconds($Seconds)
while (([System.IO.Ports.SerialPort]::GetPortNames() -notcontains 'COM3') -and ((Get-Date) -lt $end)) { Start-Sleep 1 }
if ([System.IO.Ports.SerialPort]::GetPortNames() -notcontains 'COM3') { Write-Output 'COM3 never appeared'; exit 1 }
$p = New-Object System.IO.Ports.SerialPort 'COM3', 115200, 'None', 8, 'One'
$p.DtrEnable = $true
$p.ReadTimeout = 500
$p.Open()
try {
    while ((Get-Date) -lt $end) {
        try { [System.IO.File]::AppendAllText($out, $p.ReadExisting()) } catch { break }
        Start-Sleep -Milliseconds 200
    }
} finally {
    try { $p.Close() } catch {}
}
Write-Output "log: $out"
if (Test-Path $out) {
    Write-Output ("bytes: " + (Get-Item $out).Length)
    foreach ($pat in 'no linear image', 'gpu client text', 'panic', 'jetsam', 'AdrenoMetal', 'native-metal') {
        Write-Output ("{0}: {1}" -f $pat, @(Select-String -Path $out -SimpleMatch $pat).Count)
    }
}
