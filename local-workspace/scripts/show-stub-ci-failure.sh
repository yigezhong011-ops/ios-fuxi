#!/bin/bash
set -uo pipefail
L=/root/ci3.log
echo "=== pre_build 里的关键行 ==="
grep -n 'link-stubs\|build prelink\|build kernel\|Boot progress requires\|Undefined symbols\|No such file' "$L" | head -20 | cut -c1-180
echo
echo "=== 586-605 行 ==="
sed -n '586,605p' "$L" | cut -c1-180
