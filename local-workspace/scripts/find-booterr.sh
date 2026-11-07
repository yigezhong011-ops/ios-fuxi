#!/bin/bash
set -uo pipefail
cd /root/UniXNU
echo "=== 搜索报错字符串 ==="
grep -rn 'requested parameters' scripts/ --include='*.py' | head -5
echo
echo "=== bootimg.py 里 header 相关 ==="
grep -n -E 'header|--dtb|ramdisk|mkbootimg' scripts/unixnu/bootimg.py | head -30
