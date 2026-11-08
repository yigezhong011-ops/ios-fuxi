#!/bin/bash
# Where the space went, and what is safe to remove (the handoff's do-not-delete list is respected).
set -uo pipefail
E=/mnt/e/DSH-Fuxi
echo "=== E: 空间 ==="
df -h /mnt/e | tail -1
echo
echo "=== logs 里最大的 12 项 ==="
du -sm "$E"/logs/* 2>/dev/null | sort -rn | head -12 | while read -r mb p; do printf '  %6d MB  %s\n' "$mb" "$(basename "$p")"; done
echo
echo "=== 根目录镜像 ==="
du -sm "$E"/*.img 2>/dev/null | sort -rn | head -20 | while read -r mb p; do printf '  %6d MB  %s\n' "$mb" "$(basename "$p")"; done
echo
echo "=== 其他大目录 ==="
du -sm "$E"/*/ 2>/dev/null | sort -rn | head -12 | while read -r mb p; do printf '  %6d MB  %s\n' "$mb" "$(basename "$p")"; done
