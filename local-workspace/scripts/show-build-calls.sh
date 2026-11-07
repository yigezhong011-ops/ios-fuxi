#!/bin/bash
set -uo pipefail
L=/root/ci-step.log
echo "=== 所有 unixnu build 调用与结果 ==="
tr -d '\000' < "$L" | sed 's/[^[:print:]]//g' | grep -an 'unixnu build\|kernel: archive\|built kernel at\|Error 2\|failed (' | tail -20 | cut -c1-175
