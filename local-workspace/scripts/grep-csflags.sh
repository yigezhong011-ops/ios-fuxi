#!/bin/bash
set -uo pipefail
F=/mnt/e/DSH-Fuxi/dump/kern_exec-8796.141.3.c
echo "=== ip_csflags 的赋值与使用 ==="
grep -n 'ip_csflags' "$F" | head -20
echo
echo "=== CS_RESTRICT / CS_HARD 出现处 ==="
grep -n 'CS_RESTRICT\|CS_HARD\|CS_KILL' "$F" | head -15
echo
echo "=== exec_extract_strings 里对环境的处理（我们注入的位置）==="
grep -n 'exec_extract_strings\|ip_envc\|DYLD' "$F" | head -15
