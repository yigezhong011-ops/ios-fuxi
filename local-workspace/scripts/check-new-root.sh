#!/bin/bash
set -uo pipefail
echo "=== 构建日志里的警告/错误 ==="
grep -i -E 'error|invalid|fail|warn' /root/fuxi/build-x/mkroot.log | head -10
echo
echo "=== 日志末尾 ==="
tail -12 /root/fuxi/build-x/mkroot.log
echo
echo "=== 挂载检查 ==="
mkdir -p /root/fuxi/mnt/check
mount -o loop,ro /root/fuxi/root-iphonex.img /root/fuxi/mnt/check 2>&1 || echo "MOUNT_FAILED"
ls /root/fuxi/mnt/check 2>/dev/null | head -8
echo "--- keybag ---"
ls -l /root/fuxi/mnt/check/private/var/keybags/systembag.kb 2>/dev/null || echo "(no keybag)"
echo "--- dyld cache ---"
ls -l /root/fuxi/mnt/check/System/Library/Caches/com.apple.dyld/ 2>/dev/null | head -3
echo "--- SystemVersion ---"
cat /root/fuxi/mnt/check/System/Library/CoreServices/SystemVersion.plist 2>/dev/null | grep -A1 'ProductVersion\|ProductBuildVersion' | head -6
umount /root/fuxi/mnt/check 2>/dev/null || true
