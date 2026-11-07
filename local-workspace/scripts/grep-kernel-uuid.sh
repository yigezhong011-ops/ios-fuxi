#!/bin/bash
set -uo pipefail
K=/mnt/e/DSH-Fuxi/kernel-inject/kernel.development.fuxi
echo "=== 内核二进制里的 uuid 相关字符串 ==="
strings -a "$K" | grep -iE '^boot-uuid|bootsessionuuid|^boot-uuid-string' | sort -u | head -10
echo
echo "=== 附近是否有 apfs-preboot-uuid 等（说明走设备树）==="
strings -a "$K" | grep -E 'apfs-preboot-uuid|boot-uuid' | sort -u | head -10
