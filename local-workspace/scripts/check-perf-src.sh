#!/bin/bash
set -uo pipefail
F=/root/ios-fuxi/xnu/fuxi-perf/fuxi_perf.c
echo "=== 域定义与 EPSS 编程 ==="
grep -n -i 'gold\|prime\|domain\|EPSS\|domain_names\|row' "$F" | head -25
echo
echo "=== boot-arg 开关 ==="
grep -n 'PE_parse_boot_argn' "$F" | head -10
