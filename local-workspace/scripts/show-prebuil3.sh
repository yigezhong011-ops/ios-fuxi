#!/bin/bash
set -uo pipefail
L=/root/ci3.log
echo "=== pre_build 里 cp / seed / audit 的结果 ==="
tr -d '\000' < "$L" | sed 's/[^[:print:]]//g' | grep -a 'seeded\|native-owner\|display-analysis\|kernel.json\|kernel.macho\|Experimental candidate\|No reference' | grep -av 'CCC_OVERRIDE' | head -24 | cut -c1-175
