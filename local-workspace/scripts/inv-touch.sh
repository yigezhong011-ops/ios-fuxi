#!/bin/bash
# Inventory for the touch-injection work.
set -uo pipefail
W=/mnt/e/DSH-Fuxi/dump/wsl
echo "=== 参考源码目录 ==="
ls -d /root/fuxi/ref-qcomxnuusbdebug 2>/dev/null && ls /root/fuxi/ref-qcomxnuusbdebug | head -12
echo
echo "=== 分发源码搜索 sxnu_control_reply_start ==="
grep -rl 'sxnu_control_reply_start' /root/fuxi/ref-qcomxnuusbdebug 2>/dev/null | head -5
echo
echo "=== 已有 cave / 截图代码 ==="
ls -l "$W"/shot-cave.c "$W"/make-t50-shot.sh "$W"/patch-t50-usbfast.py "$W"/read-touch-verb.py 2>/dev/null
echo
echo "=== TouchProbe.cpp 在哪 ==="
find /root/fuxi /mnt/e/DSH-Fuxi/dump/wsl -name 'TouchProbe.cpp' 2>/dev/null | head -5
echo
echo "=== t50-shot 内核树 ==="
ls /root/fuxi/t50-shot 2>/dev/null | head -8
