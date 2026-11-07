#!/bin/bash
set -uo pipefail
L=/root/ci-step.log
echo "=== 编译与 prelink 相关 ==="
tr -d '\000' < "$L" | sed 's/[^[:print:]]//g' | grep -a 'mach.development\|kernel: prelink\|Experimental candidate\|built kernel\|error:' | grep -av 'CCC_OVERRIDE' | tail -12 | cut -c1-175
echo
echo "=== 最后的 archive ==="
tr -d '\000' < "$L" | sed 's/[^[:print:]]//g' | grep -a 'kernel: archive' | tail -4 | cut -c1-150
