#!/bin/bash
set -uo pipefail
K=/mnt/e/DSH-Fuxi/kernel-inject/kernel.development.fuxi
echo "=== 内核里与 boot-uuid 相关的格式串 ==="
strings -a "$K" | grep -E 'boot-uuid|rd=uuid|rooting via' | sort -u
echo
echo "=== pexpert 里 boot-arg 解析的典型串 ==="
strings -a "$K" | grep -E '^PE_|boot-args|parse_boot_arg' | sort -u | head -8
