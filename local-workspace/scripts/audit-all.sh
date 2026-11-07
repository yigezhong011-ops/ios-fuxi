#!/bin/bash
set -uo pipefail
echo "=== 1. WSL 里的 iOS 材料 ==="
ls -lh /root/fuxi/ 2>/dev/null | grep -v '^-.*build-.*log' | head -15
echo
echo "=== 2. WSL 里的大文件（>500MB）==="
find /root -maxdepth 3 -type f -size +500M 2>/dev/null | head -10
echo
echo "=== 3. xnu 源码里的文件系统模块 ==="
ls /root/ios-fuxi/xnu/ 2>/dev/null | head -20
echo
echo "=== 4. 搜索 sweet/overlay/vfs 关键字 ==="
grep -rln 'sweet_vfs\|sweetfs\|SWEET_VFS' /root/ios-fuxi/xnu/ 2>/dev/null | head -6
echo
echo "=== 5. ADT 生成器里的 display 节点细节 ==="
grep -n -A12 "sweet,display" /root/ios-fuxi/tools/mkadt.py | head -25
