#!/bin/bash
# Which process is behind the failing HEIC writes: show line context around them.
set -uo pipefail
L=/mnt/e/DSH-Fuxi/logs/carve-wallnew/lscan.txt
n=$(grep -an -m 1 'writeImageAtIndex' "$L" | cut -d: -f1)
echo "第一条 writeImageAtIndex 在第 $n 行，前后 12 行："
awk -v s="$n" 'NR>=s-12 && NR<=s+3 {printf "%6d| %s\n", NR, substr($0,1,180)}' "$L"
echo
echo "=== 该文件里 Posteroard 相关进程名统计（前 8）==="
grep -aoE '(PosterBoard|PRSPoster[A-Za-z]*|ChronoServices[A-Za-z.]*|chronod|PosterKit[A-Za-z.]*)' "$L" | sort | uniq -c | sort -rn | head -8
