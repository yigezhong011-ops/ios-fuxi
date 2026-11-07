#!/bin/bash
set -uo pipefail
S=/mnt/e/DSH-Fuxi/mesa-ios/userland/eagl_slots.txt
G=/mnt/e/DSH-Fuxi/gles-stack/eagl_gen.h
echo "=== 槽位表 ==="
TOTAL=$(grep -vc '^#' "$S" || true)
STAR=$(grep -v '^#' "$S" | grep -c '\*' || true)
echo "条目数: $TOTAL（mkeagl 的下限是 409）"
echo "其中 QuartzCore 会调用的(*): $STAR"
echo
echo "=== 生成表 ==="
echo "static 函数: $(grep -c '^static ' "$G" || true)"
echo "表格填充项: $(grep -c 'eagl_table\[' "$G" 2>/dev/null || echo 'n/a')"
head -2 "$G"
echo
echo "=== 槽位偏移范围 ==="
grep -v '^#' "$S" | awk '{print $1}' | sort -u | head -2
grep -v '^#' "$S" | awk '{print $1}' | sort -u | tail -2
