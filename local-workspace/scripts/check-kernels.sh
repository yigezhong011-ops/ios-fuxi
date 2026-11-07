#!/bin/bash
set -uo pipefail
P=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working
echo "=== 独立内核文件 ==="
for f in kernel.development.fuxi kernel-current-in-use.fuxi; do
  printf '%-28s %10s bytes  sha=%s\n' "$f" "$(stat -c%s $P/$f)" "$(sha256sum $P/$f | cut -c1-16)"
done
echo
echo "=== 各 boot 镜像里的内核大小（用 payload 里的 kernel_end_va 无法直接判，改用文件大小）==="
for f in boot-gpu3-v4.img boot-final-v4.img boot-touch-v4.img boot-native-v4.img; do
  printf '%-24s %10s bytes\n' "$f" "$(stat -c%s $P/$f)"
done
echo
echo "=== README 说：17482568 可用 / 15951888 起不来 ==="
