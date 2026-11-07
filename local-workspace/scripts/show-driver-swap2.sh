#!/bin/bash
set -uo pipefail
L=/root/ci-step.log
echo "=== 05:58 之后的驱动相关行 ==="
tr -d '\000' < "$L" | sed 's/[^[:print:]]//g' | grep -aE 'Adreno740|OriginalAcceleratorABI|cloning|Cloning' | grep -av 'CCC_OVERRIDE' | sed -n '10,30p' | cut -c1-175
