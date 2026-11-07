#!/bin/bash
set -uo pipefail
cd /root/fuxi/uni-oldci/patches/xnu || exit 1
echo "=== owner / offline 补丁 ==="
ls | grep -iE 'owner|offline' | head -14
echo
echo "=== 改 bsd_init.c 的补丁 ==="
grep -l 'bsd/kern/bsd_init.c' ./*.patch 2>/dev/null | head -14
