#!/bin/bash
set -uo pipefail
cd /mnt/e/DSH-Fuxi/unixnu-build/unixnu || exit 1
echo "=== 当前 HEAD ==="
git log --oneline -1 2>&1 | cut -c1-120
echo "=== 远程分支 ==="
git branch -r 2>&1 | head -5
echo "=== fetch 结果 ==="
git fetch origin main 2>&1 | tail -3
echo "=== origin/main 最近 10 条 ==="
git log --oneline -10 origin/main 2>&1 | cut -c1-120
