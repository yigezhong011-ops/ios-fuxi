#!/bin/bash
# Keep the two newest carves for the frame-pacing work, delete the rest of 待删除.
set -uo pipefail
ROOT=/mnt/e/DSH-Fuxi
TRASH=$ROOT/待删除
KEEP="carve-wallnew carve-coh2"

echo "=== 保留两份最新 carve ==="
for k in $KEEP; do
  if [ -d "$TRASH/logs/$k" ]; then
    mv -f "$TRASH/logs/$k" "$ROOT/logs/$k" && echo "  取回 logs/$k"
  fi
done

echo
echo "=== 删除 待删除 其余内容 ==="
before=$(df -B1 --output=avail /mnt/e | tail -1)
n=0
while IFS= read -r -d '' p; do
  rm -rf -- "$p" && n=$((n+1))
done < <(find "$TRASH" -mindepth 1 -maxdepth 1 -print0)
echo "  删除 $n 项"
after=$(df -B1 --output=avail /mnt/e | tail -1)
echo "  释放 $(echo "$before $after" | awk '{printf "%.2f", ($2-$1)/1073741824}') GB（负值表示其他写入）"

echo
echo "=== 之后 ==="
df -h /mnt/e | tail -1 | sed 's/^/  /'
echo "  待删除: $(du -sh "$TRASH" 2>/dev/null | cut -f1)"
echo "  logs 里的 carve: $(du -sm "$ROOT"/logs/carve-* 2>/dev/null | awk '{s+=$1} END {print s+0}') MB"
