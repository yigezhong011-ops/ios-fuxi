#!/bin/bash
set -uo pipefail
T=/root/ux2/fuxi/tree
echo "=== SETUP/installfile/Makefile ==="
sed -n '1,30p' "$T/.cache/xnu-work/SETUP/installfile/Makefile" 2>/dev/null | cut -c1-150
echo
echo "=== 实际用的 CC（从编译日志）==="
L=/root/ux2/fuxi/logs/kernel-bootstrap.log
grep -a 'installfile.o' "$L" | head -2 | cut -c1-200
