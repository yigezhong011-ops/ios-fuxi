#!/bin/bash
set -uo pipefail
O=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/out/fuxi/tree/build/xnu/ios-obj
echo "=== 已生成的 .o 数量 ==="
find "$O" -name '*.o' 2>/dev/null | wc -l
echo "=== 已生成的 .cpo 数量 ==="
find "$O" -name '*.cpo' 2>/dev/null | wc -l
echo "=== obj 目录大小 ==="
du -sh "$O" 2>/dev/null
echo "=== 最近生成的文件（时间序）==="
find "$O" -name '*.o' -newermt '-10 minutes' 2>/dev/null | wc -l
echo "个 .o 是最近 10 分钟生成的"
echo "=== 链接产物 ==="
ls -lh /mnt/e/DSH-Fuxi/unixnu-build/unixnu/out/fuxi/tree/build/xnu/ios-obj/*.macho 2>/dev/null | head -3
echo "=== 当前编译的是哪个模块 ==="
ps -eo cmd 2>/dev/null | grep -o 'xnu-work/[a-z]*/' | sort | uniq -c | head -5
