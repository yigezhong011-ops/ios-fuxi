#!/bin/bash
set -uo pipefail
python3 /mnt/e/DSH-Fuxi/dump/wsl/extract-payloads.py
for n in unixnu-quiet unixnu-touch; do
  echo "================ $n ================"
  W=/root/insp-$n
  mdir -i "$W/payload.img" -/ ::/EFI/UniXNU/Payloads 2>/dev/null | tail -10
  echo "--- 参数 ---"
  mtype -i "$W/payload.img" ::/EFI/UniXNU/unixnu.toml 2>/dev/null | grep -o 'args = "[^"]*"' | head -1 | cut -c1-700
done
