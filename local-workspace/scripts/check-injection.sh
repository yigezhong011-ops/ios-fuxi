#!/bin/bash
set -uo pipefail
echo "=== 现有 dylib 注入方式 ==="
grep -rn 'DYLD_INSERT_LIBRARIES\|libfuxitouch' /root/fuxi/*.sh /mnt/e/DSH-Fuxi/dump/wsl/step1*.sh /mnt/e/DSH-Fuxi/dump/wsl/step2*.sh 2>/dev/null | head -12
echo
echo "=== 根镜像里已装的 dylib ==="
mdir -i /mnt/e/DSH-Fuxi/iosroot-metal.img ::/usr/lib 2>/dev/null | grep -i fuxi | head -5
echo
echo "=== 现有的注入 plist ==="
mdir -i /mnt/e/DSH-Fuxi/iosroot-metal.img ::/Library/LaunchDaemons 2>/dev/null | head -8
