#!/bin/bash
set -uo pipefail
L=/root/ci-step.log
echo "=== unixnu: 与 payload 相关 ==="
tr -d '\000' < "$L" | sed 's/[^[:print:]]//g' | grep -a 'unixnu:' | grep -av CCC_OVERRIDE | tail -5 | cut -c1-190
echo
echo "=== Font.h / freestanding / clang 错误 ==="
tr -d '\000' < "$L" | sed 's/[^[:print:]]//g' | grep -a 'Font.h\|freestanding\|fatal error\|CalledProcessError' | grep -av CCC_OVERRIDE | tail -8 | cut -c1-190
