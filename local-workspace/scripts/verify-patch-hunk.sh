#!/bin/bash
set -uo pipefail
P=/root/fuxi/0116-kern-exec-inject.patch
echo "=== 补丁里的 csflags hunk ==="
awk '/^@@/{h=$0} /ip_csflags &~/{print h; found=1} found{print; if (++n>22) exit}' "$P" | head -30
echo
echo "=== 确认 proc_csflags_update 在清除之后 ==="
grep -n 'proc_csflags_update\|ip_csflags &~' /mnt/e/DSH-Fuxi/dump/kern_exec-8796.141.3.c | head -5
