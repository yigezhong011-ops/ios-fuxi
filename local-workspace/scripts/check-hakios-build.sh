#!/bin/bash
set -uo pipefail
cd /root/hakios-xnu-kernel || exit 1
echo "=== Makefile 目标 ==="
grep -E '^[a-zA-Z0-9_.-]+:' Makefile | head -30 | cut -c1-90
echo
echo "=== CI workflows ==="
ls .github/workflows/ 2>/dev/null | head -10
echo
echo "=== README 的构建段落 ==="
grep -n -A12 -i 'build' README.md | head -30 | cut -c1-140
