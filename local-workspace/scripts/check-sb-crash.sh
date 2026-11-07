#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon22/boot.log
echo "=== SpringBoard 崩溃前后的上下文 ==="
grep -a -n 'CRASH SpringBoard' "$L" | head -3
echo "---"
N=$(grep -a -n 'CRASH SpringBoard' "$L" | head -1 | cut -d: -f1)
[ -n "${N:-}" ] && sed -n "$((N-12)),$((N+6))p" "$L" | tr -d '\000'
echo
echo "=== 崩溃原因关键字 ==="
grep -a -o -E 'SIGSEGV|SIGBUS|SIGILL|SIGABRT|EXC_BAD_ACCESS|KERN_INVALID|panic|user trap' "$L" | sort | uniq -c | head -8
echo
echo "=== GPU ABI 调用记录（如果有）==="
grep -a -c 'FUXI GPU ABI:' "$L"
grep -a 'FUXI GPU ABI:' "$L" | tail -5
