#!/bin/bash
set -uo pipefail
cd /root/uefi-fuxi
echo "=== build_uefi.py 里的命令构造 ==="
grep -n -E 'stuart|Popen|subprocess|call\(' build_uefi.py | head -15
echo
echo "=== DeviceBuild.py 的路径 ==="
ls Platforms/Xiaomi/fuxiPkg/*.py 2>/dev/null
