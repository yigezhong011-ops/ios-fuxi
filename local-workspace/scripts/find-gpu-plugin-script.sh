#!/bin/bash
set -uo pipefail
D=/root/fuxi/fork-device
echo "=== 有没有 add-gpu-plugin-data.py ==="
ls "$D/scripts" | grep -i 'gpu-plugin\|plugin-data' || echo "  没有"
echo
echo "=== 树里有没有 ==="
ls /root/ux3/fuxi/tree/scripts 2>/dev/null | grep -i 'gpu-plugin\|plugin-data' || echo "  没有"
echo
echo "=== 搜索 add-gpu-plugin-data ==="
grep -rln 'add-gpu-plugin-data' /root/ux3/fuxi/tree /root/fuxi/fork-device 2>/dev/null | head -5
