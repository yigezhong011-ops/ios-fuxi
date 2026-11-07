#!/bin/bash
set -uo pipefail
L=/root/ci-step.log
echo "=== 驱动替换相关输出 ==="
tr -d '\000' < "$L" | sed 's/[^[:print:]]//g' | grep -aE 'Adreno740|OriginalAcceleratorABI|NativeMetal|fatal|Checking out' | grep -av 'CCC_OVERRIDE' | head -20 | cut -c1-175
