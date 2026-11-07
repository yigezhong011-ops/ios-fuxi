#!/bin/bash
set -uo pipefail
echo "=== /root 大目录 ==="
du -sh /root/* 2>/dev/null | sort -rh | head -12
echo
echo "=== /root/fuxi 里的大文件 ==="
ls -lh /root/fuxi/*.img 2>/dev/null | head -10
echo
echo "=== 构建输入 ==="
du -sh /root/fuxi/build-x /root/fuxi/build-1616 2>/dev/null
