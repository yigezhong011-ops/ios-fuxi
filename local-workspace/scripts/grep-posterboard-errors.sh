#!/bin/bash
# What does PosterBoard itself complain about on the current boot?
set -uo pipefail
L=/mnt/e/DSH-Fuxi/logs/carve-wallnew/lscan.txt
echo "=== PosterBoard 里的错误/失败行（去重，前 20 条）==="
grep -a -iE 'posterboard.*(error|fail|unable|could not|nil|assert)' "$L" \
  | sed 's/^[^ ]* //' | sort -u | head -20 | cut -c1-220
echo
echo "=== 含 'poster' 的失败行（去重，前 15 条）==="
grep -a -iE '(poster|wallpaper).*(error|fail|unable|could not|not found)' "$L" \
  | sed 's/^[^ ]* //' | sort -u | head -15 | cut -c1-220
echo
echo "=== Wallpaper 相关不同类型（前 15 种）==="
grep -a 'Wallpaper' "$L" | sed 's/^[^ ]* //' | sort -u | head -15 | cut -c1-200
