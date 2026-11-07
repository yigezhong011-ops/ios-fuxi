#!/bin/bash
set -uo pipefail
echo "=== 完整 traceback ==="
grep -n -B12 '_path_normpath' /root/uefi-build4.log | head -30
echo
echo "=== 可用 Python 版本 ==="
ls /usr/bin/python3* 2>/dev/null
echo "=== 当前 python3 版本 ==="
python3 --version
echo "=== BUILDLOG 尾部 ==="
tail -25 /root/uefi-fuxi/Build/BUILDLOG_fuxiPkg.txt 2>/dev/null
