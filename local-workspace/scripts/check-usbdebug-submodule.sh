#!/bin/bash
set -uo pipefail
cd /mnt/e/DSH-Fuxi/unixnu-build
echo "=== 设备仓库的 unixnu.lock / .gitmodules 里的 QcomXnuUsbDebug ==="
grep -rn 'QcomXnuUsbDebug' fuxi/.gitmodules fuxi/unixnu.lock 2>/dev/null | head -5
echo
echo "=== 上游仓库现有提交 ==="
git ls-remote https://github.com/xiaoleGun/QcomXnuUsbDebug.git 2>&1 | head -8
echo
echo "=== 是否已部分克隆 ==="
ls fuxi/drivers/QcomXnuUsbDebug 2>/dev/null | head -5
