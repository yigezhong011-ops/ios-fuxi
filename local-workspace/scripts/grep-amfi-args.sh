#!/bin/bash
set -uo pipefail
K=/mnt/e/DSH-Fuxi/kernel-inject/kernel.development.fuxi
echo "=== 内核里的 AMFI/代码签名相关启动参数 ==="
strings -a "$K" | grep -iE 'amfi|get_out_of_my_way|cs_debug|cs_enforcement|platform_binary_policy|disable.*cs' | sort -u | head -25
