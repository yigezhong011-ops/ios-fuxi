#!/bin/bash
# Which PosterBoard data-store failure paths actually appear?
set -uo pipefail
L=/mnt/e/DSH-Fuxi/logs/carve-wallnew/lscan.txt
echo "=== 三条失败路径的出现次数 ==="
for k in 'could not setup data store' 'could not validate data store integrity' \
         'failed to setup database' 'could not be created' 'PRBPosterExtensionDataStore'; do
  printf '  %-42s %s\n' "$k" "$(grep -ac "$k" "$L" 2>/dev/null || echo 0)"
done
echo
echo "=== 完整错误行（去重）==="
grep -a -iE 'could not setup data store|could not validate data store|failed to setup database' "$L" \
  | sed 's/^[^ ]* //' | sort -u | head -10 | cut -c1-240
echo
echo "=== 数据存储目录下的文件名（含 PRBPosterExtensionDataStore 的行，去重）==="
grep -a 'PRBPosterExtensionDataStore' "$L" | sed 's/^[^ ]* //' | sort -u | head -10 | cut -c1-240
echo
echo "=== 任何 .sqlitedb / .sqlite 名字（去重，前 15）==="
grep -aoE '[A-Za-z0-9_.-]+\.sqlite(db)?(-shm|-wal)?' "$L" | sort -u | head -15
