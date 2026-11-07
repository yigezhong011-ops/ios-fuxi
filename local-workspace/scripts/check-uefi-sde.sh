#!/bin/bash
set -uo pipefail
cd /root/uefi-odd || exit 1
echo "=== build_uefi.py 的选项 ==="
grep -n 'add_argument\|skip\|sde' build_uefi.py 2>/dev/null | head -20 | cut -c1-150
echo
echo "=== mu_nasm 在哪个配置里 ==="
grep -rn 'mu_nasm' --include='*.py' --include='*.json' --include='*.yaml' --include='*.yml' . 2>/dev/null | head -6 | cut -c1-160
echo
echo "=== 系统有没有 nasm ==="
command -v nasm && nasm -v
