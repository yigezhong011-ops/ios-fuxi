#!/bin/bash
# Read-only: what booting without sheng-data-persist does to the stored Data, and whether the candidate volume still holds the seed.
export MTOOLS_SKIP_CHECK=1
E=/mnt/e/DSH-Fuxi
echo "== source"
grep -n -r -a -I -E 'data-persist|data-reset|PackedRAMDisk' $E/unixnu-build /root/fuxi/src-unixnu /root/fuxi/src-* --include='*.c' --include='*.cpp' --include='*.h' --include='*.py' --include='*.toml' --include='*.md' --include='*.rs' 2>/dev/null | cut -c1-230 | sort -u | head -30
echo "== notes"
grep -n -E 'fresh|新 Data|全新|种子|seed|data-persist|data-reset' $E/progress-2026-11-0*.md $E/进度-2026*.md 2>/dev/null | cut -c1-240 | head -30
echo "== kernel strings"
strings -a /root/fuxi/t50-wall17/kernel.macho | grep -E 'data-persist|data-reset|PackedRAMDisk|sheng-data' | cut -c1-200 | head -20
echo "== board"
grep -n -E 'packed|persist|data' $E/unixnu-build/fuxi/board.toml | cut -c1-160 | head -14
echo "== scripts"
ls $E/dump/wsl | grep -i -E 'seed|fresh|persist|data' | head -20
