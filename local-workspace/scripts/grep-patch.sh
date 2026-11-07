#!/bin/bash
set -uo pipefail
P=/root/fuxi/0116-kern-exec-inject.patch
echo "=== 行数 ==="
wc -l "$P"
echo "=== 关键行 ==="
grep -n 'CS_HARD' "$P" | head -5
grep -n 'exec_inject_target' "$P" | head -5
grep -n 'ip_csflags' "$P" | head -5
echo "=== hunk 头 ==="
grep -n '^@@' "$P"
