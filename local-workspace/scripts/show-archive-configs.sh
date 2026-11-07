#!/bin/bash
set -uo pipefail
echo "=== defconfig 里的归档路径 ==="
grep -n 'ARCHIVE' /root/fuxi/fork-device/configs/fuxi_gpu_defconfig | cut -c1-170
