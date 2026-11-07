# Push the wallpaper-patched image, recompute extents, rebuild the boot image.
# ASCII only: PowerShell 5.1 misreads UTF-8 paths without BOM.
$ErrorActionPreference = 'Stop'

$adb = "E:\DSH-Fuxi\tools\platform-tools\adb.exe"
if (-not $adb) { throw 'adb.exe not found' }
Write-Output "adb: $adb"

$img = 'E:\DSH-Fuxi\dump\iosroot-wall.img'
$ext = 'E:\DSH-Fuxi\dump\ext-wall.json'

Write-Output '=== 1. push image ==='
& $adb push $img /data/fuxi/iosroot.img 2>&1 | Select-Object -Last 2

Write-Output '=== 2. fiemap extents ==='
& $adb push 'E:\DSH-Fuxi\dump\tools\fiemap_bytes' /data/local/tmp/fiemap_bytes 2>&1 | Select-Object -Last 1
& $adb shell "su 0 chmod 755 /data/local/tmp/fiemap_bytes" 2>&1 | Out-Null
$out = & $adb shell "su 0 /data/local/tmp/fiemap_bytes /data/fuxi/iosroot.img" 2>&1
$out | Set-Content -Path $ext -Encoding ASCII
$json = Get-Content $ext -Raw | ConvertFrom-Json
Write-Output ("extents: {0}  size: {1}" -f $json.extents.Count, $json.size)

Write-Output '=== 3. swap extents file ==='
Copy-Item 'E:\DSH-Fuxi\dump\ext-bytes.json' 'E:\DSH-Fuxi\dump\ext-bytes.prev.json' -Force
Copy-Item $ext 'E:\DSH-Fuxi\dump\ext-bytes.json' -Force

Write-Output '=== 4. rebuild ADT + payload + boot.img ==='
wsl -d Ubuntu -u root -- bash /mnt/e/DSH-Fuxi/dump/wsl/step24-build-diag2.sh 2>&1 | Select-Object -Last 6
