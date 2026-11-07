#!/bin/bash
set -uo pipefail
cd /root/hakios-xnu-kernel || exit 1
echo "=== kernel 目标 ==="
awk '/^kernel:/{flag=1} flag{print} /^$/{if(flag) exit}' Makefile | head -25 | cut -c1-150
echo
echo "=== xnu-deps ==="
ls xnu-deps 2>/dev/null | head -10
echo
echo "=== setup.sh 前 25 行 ==="
head -25 xnu-deps/setup.sh 2>/dev/null | cut -c1-140
echo
echo "=== 是否依赖 macOS ==="
grep -rn 'uname\|Darwin\|xcrun' Makefile xnu-deps/*.sh 2>/dev/null | head -10 | cut -c1-140
