$ErrorActionPreference = 'Continue'
$adb = 'E:\DSH-Fuxi\tools\platform-tools\adb.exe'
$ext = 'E:\DSH-Fuxi\dump\ext-bytes.json'

Write-Output 'waiting for Android...'
$deadline = (Get-Date).AddMinutes(30)
$online = $false
while ((Get-Date) -lt $deadline) {
    $out = & $adb devices 2>&1 | Out-String
    if ($out -match '(\S+)\s+device') { $online = $true; break }
    Start-Sleep -Seconds 8
}
if (-not $online) { Write-Output 'TIMEOUT'; exit 1 }
Write-Output 'device online, pushing...'

& $adb push 'E:\DSH-Fuxi\dump\iosroot-nolock.img' /data/fuxi/iosroot.img 2>&1 | Select-Object -Last 1

$raw = & $adb shell "su 0 /data/local/tmp/fiemap_bytes /data/fuxi/iosroot.img" 2>&1
$raw | Set-Content -Path $ext -Encoding ASCII
try {
    $j = Get-Content $ext -Raw | ConvertFrom-Json
    Write-Output ("extents: {0} size: {1}" -f $j.extents.Count, $j.size)
} catch {
    Write-Output "extent parse failed: $($_.Exception.Message)"
    exit 1
}

Write-Output 'rebuilding boot image...'
wsl -d Ubuntu -u root -- bash /mnt/e/DSH-Fuxi/dump/wsl/step24-build-diag2.sh 2>&1 | Select-Object -Last 4
