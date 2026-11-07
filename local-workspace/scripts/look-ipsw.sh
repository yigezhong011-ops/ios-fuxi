#!/bin/bash
set -uo pipefail
cd /root/UniXNU
echo "=== kernel.py 里 ipsw / corecrypto 相关 ==="
grep -n 'ipsw\|corecrypto' scripts/unixnu/kernel.py | head -20
echo
echo "=== build-corecrypto-14.py 需要什么输入 ==="
grep -n 'ipsw\|KernelCache\|opensource\|fetch\|download' scripts/build-corecrypto-14.py | head -15
echo
echo "=== 第 757 行到底是什么 ==="
sed -n '755,760p' scripts/build-xnu-4k-baseline.sh
