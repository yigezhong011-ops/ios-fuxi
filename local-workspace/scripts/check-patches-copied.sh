#!/bin/bash
set -uo pipefail
D=/mnt/e/DSH-Fuxi/unixnu-build/fuxi/patches/xnu
echo "=== 相关补丁是否存在 ==="
for n in linux-host-tools linux-link-shims iig-method-forwarders portable-kalloc-type-builtins llvm-clang-arm64-crypto-asm; do
  if [ -f "$D/$n.patch" ]; then echo "  ✓ $n.patch"; else echo "  ✗ $n.patch"; fi
done
echo
echo "=== 补丁总数 ==="
ls "$D" | wc -l
