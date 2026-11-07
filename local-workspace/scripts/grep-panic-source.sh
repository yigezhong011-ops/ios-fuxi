#!/bin/bash
set -uo pipefail
K=/mnt/e/DSH-Fuxi/kernel-inject/kernel.development.fuxi
echo "=== 内核里 'userspace panic' / 'platform' 相关串 ==="
strings -a "$K" | grep -iE 'userspace panic|non-platform|platform binary|platform-binary|not a platform' | sort -u | head -15
echo
echo "=== 相关片段（可能是拼接的）==="
strings -a "$K" | grep -iE '^unexpected|exec of |binary: %s|platform' | sort -u | head -15
echo
echo "=== fuxiamfi 的确切用法 ==="
strings -a "$K" | grep -i 'fuxiamfi' | head -5
