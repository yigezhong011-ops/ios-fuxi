#!/bin/bash
set -uo pipefail
S=/root/fuxi/fork-device/scripts/build-xnu-4k-baseline.sh
echo "=== 脚本里所有 OWNER_ROOT / VERIFIED_ROOT 开关 ==="
grep -o 'XNU_OWNER_ROOT_[A-Z_]*\|XNU_VERIFIED_ROOT_[A-Z_]*' "$S" | sort -u
echo
echo "=== defconfig 里现有的 ==="
grep -n 'OWNER_ROOT\|VERIFIED_ROOT' /root/fuxi/fork-device/configs/fuxi_gpu_defconfig
