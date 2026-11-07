#!/bin/bash
set -uo pipefail
K=/root/insp-user/kernel.macho
echo "=== boot-ui-* 参数 ==="
strings -a "$K" 2>/dev/null | grep -E '^boot-ui[-a-z0-9]*$' | sort -u | head -20
echo
echo "=== 与锁屏/解锁相关的参数 ==="
strings -a "$K" 2>/dev/null | grep -E '^(sheng|offline)-[a-z0-9-]*(lock|unlock|springboard|desktop|ui)[a-z0-9-]*$' | sort -u | head -20
echo
echo "=== 含 springboard 的参数 ==="
strings -a "$K" 2>/dev/null | grep -i 'springboard' | grep -E '^[a-z-]+=[a-z0-9,]+$|^[a-z-]+$' | sort -u | head -10
