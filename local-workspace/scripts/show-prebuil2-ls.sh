#!/bin/bash
set -uo pipefail
L=/root/ci3.log
echo "=== pre_build 里的 kernel/ 与 prelink 输出 ==="
tr -d '\000' < "$L" | sed 's/[^[:print:]]//g' | grep -a 'kernel.macho\|xnu-prelink\|noctf\|display-analysis\|prelink' | grep -av 'CCC_OVERRIDE' | tail -20 | cut -c1-180
