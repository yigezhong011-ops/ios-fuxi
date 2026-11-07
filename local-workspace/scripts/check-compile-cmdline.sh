#!/bin/bash
set -uo pipefail
L=/root/ux2/fuxi/logs/kernel-bootstrap.log
echo "=== 编译 IOUserServer.cpp 的命令行 ==="
grep -a 'IOUserServer.cpp' "$L" | grep -a 'clang' | head -2 | tr -d '\000' | tr ' ' '\n' | grep -a 'WIFI\|PRIVATE\|std=\|I/user' | head -12
echo
echo "=== 该命令行里有没有 -DPRIVATE_WIFI_ONLY ==="
grep -a 'clang.*IOUserServer.cpp' "$L" | head -1 | grep -c 'PRIVATE_WIFI_ONLY'
echo
echo "=== Makefile.template 第 15-25 行 ==="
awk 'NR>=15 && NR<=25 {printf "%3d| %s\n", NR, $0}' /root/ux2/fuxi/tree/.cache/xnu-work/iokit/conf/Makefile.template
