# Run with the phone in TWRP (adb state recovery). Reads Data only: dscan opens the device O_RDONLY and writes only under /tmp.
# Finds the gzip logs adrenoprobed left in Data, pulls them to E:\DSH-Fuxi\logs\carve-<name>\ and inflates them in WSL.
# Usage: carve-oslog.ps1 <name>. Does not change the slot; run the usual reboot bootloader + set_active b afterwards.
param([Parameter(Mandatory = $true)][string]$Name)
$adb = "E:\DSH-Fuxi\tools\platform-tools\adb.exe"
$dir = "E:\DSH-Fuxi\logs\carve-$Name"; $wdir = "/mnt/e/DSH-Fuxi/logs/carve-$Name"
$dev = "/dev/block/by-name/userdata"; $first = 54282042; $blocks = 4194304
New-Item -ItemType Directory -Force $dir | Out-Null
if (-not ((& $adb devices) -match "\srecovery")) { Write-Output "ADB NOT UP"; exit 2 }
cmd /c "`"$adb`" push E:\DSH-Fuxi\dump\wsl\dscan-arm64 /tmp/dscan"
cmd /c "`"$adb`" shell chmod 755 /tmp/dscan"
cmd /c "`"$adb`" shell /tmp/dscan scan $dev $first $blocks" | Out-File -Encoding ascii "$dir\scan.txt"
Get-Content "$dir\scan.txt" | Where-Object { $_ -notmatch '^GZ ' } | Select-Object -First 40
wsl -u root -- python3 -I /mnt/e/DSH-Fuxi/dump/wsl/pick-oslog-heads.py --list "$wdir/scan.txt" "$wdir/heads.list"
cmd /c "`"$adb`" push $dir\heads.list /tmp/heads.list"
cmd /c "`"$adb`" shell /tmp/dscan heads $dev /tmp/heads.list /tmp/heads.bin"
cmd /c "`"$adb`" pull /tmp/heads.bin $dir\heads.bin"
wsl -u root -- python3 -I /mnt/e/DSH-Fuxi/dump/wsl/pick-oslog-heads.py "$wdir/scan.txt" "$wdir/heads.bin" "$wdir/oslog.list"
# Each log is gzip, so inflating stops by itself at its end or at the first extent break: 32 MiB per candidate, the newest 12 only.
$list = Get-Content "$dir\oslog.list" | Select-Object -Last 12
foreach ($a in $list) {
    cmd /c "`"$adb`" shell /tmp/dscan dump $dev $a 8192 /tmp/gz-$a.bin"
    cmd /c "`"$adb`" pull /tmp/gz-$a.bin $dir\gz-$a.bin"
    cmd /c "`"$adb`" shell rm -f /tmp/gz-$a.bin"
}
wsl -u root -- python3 -I /mnt/e/DSH-Fuxi/dump/wsl/read-oslog-carve.py $wdir "/root/fuxi/carve-$Name"
