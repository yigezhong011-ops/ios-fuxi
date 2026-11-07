#!/bin/bash
set -uo pipefail
echo "=== 内核里的注入动作 ==="
for k in /mnt/e/DSH-Fuxi/kernel-inject/kernel.development.fuxi /mnt/e/DSH-Fuxi/kernel-inject/kernel.panic.fuxi; do
  [ -f "$k" ] || continue
  printf '%-40s ' "$(basename "$k")"
  if strings -a "$k" | grep -q 'panic("FUXI INJECT'; then echo "panic 版"; else echo "printf 版"; fi
done
ls -l /mnt/e/DSH-Fuxi/kernel-inject/
