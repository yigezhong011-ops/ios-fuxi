#!/bin/bash
set -uo pipefail
cd /mnt/e/DSH-Fuxi/unixnu-build/unixnu || exit 1
git fetch -q origin main
echo "=== 落后多少提交 ==="
git rev-list --count HEAD..origin/main
echo
echo "=== 与 verified-root / storage 相关的改动 ==="
git log --oneline HEAD..origin/main -- '*verified*' '*storage*' 'profiles/os/*' 2>/dev/null | head -8 | cut -c1-130
echo
echo "=== 20d8a70 的 diff 概要 ==="
git show --stat 20d8a70 2>/dev/null | head -14 | cut -c1-140
echo
echo "=== dc8e5de 的 diff 概要 ==="
git show --stat dc8e5de 2>/dev/null | head -12 | cut -c1-140
