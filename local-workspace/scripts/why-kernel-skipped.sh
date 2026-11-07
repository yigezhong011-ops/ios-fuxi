#!/bin/bash
set -uo pipefail
echo "=== 最新日志（按时间）==="
ls -lt --time-style=+%H:%M /root/ux-out/fuxi/logs/ 2>/dev/null | head -6
echo
echo "=== kernel.log 内容（若有）==="
if [ -f /root/ux-out/fuxi/logs/kernel.log ]; then tail -20 /root/ux-out/fuxi/logs/kernel.log | cut -c1-160; else echo "（不存在）"; fi
echo
echo "=== 驱动里 kernel 步骤的判断逻辑 ==="
grep -n 'def run_kernel\|link.filelist\|already\|skip' /mnt/e/DSH-Fuxi/unixnu-build/unixnu/scripts/unixnu/kernel.py 2>/dev/null | head -12
