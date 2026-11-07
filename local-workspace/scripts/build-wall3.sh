#!/bin/bash
# Add sheng-data-reset=1 so every boot starts from a fresh Data store, then rebuild.
set -uo pipefail
W=/root/rebuild
cp -f "$W/args-final.txt" "$W/args-final.bak"
if ! grep -qx 'sheng-data-reset=1' "$W/args-final.txt"; then
  echo 'sheng-data-reset=1' >> "$W/args-final.txt"
fi
echo "参数 $(wc -l < "$W/args-final.txt") 个，命令行 $(tr '\n' ' ' < "$W/args-final.txt" | wc -c) 字节"
tail -3 "$W/args-final.txt"
bash /root/fuxi/bwv.sh t32-wall3 'SpringBoard,WidgetRenderer_Default' 2>&1 | tail -8
