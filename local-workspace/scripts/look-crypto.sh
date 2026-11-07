#!/bin/bash
set -uo pipefail
cd /root/UniXNU
echo "=== CRYPTO_ARCHIVE 定义与使用 ==="
grep -n 'CRYPTO_ARCHIVE' scripts/build-xnu-4k-baseline.sh | head -10
echo
echo "=== 750 行前后 ==="
sed -n '735,775p' scripts/build-xnu-4k-baseline.sh
echo
echo "=== defconfig 里 corecrypto 相关 ==="
grep -rn 'CORECRYPTO' scripts/unixnu/*.py | head -10
