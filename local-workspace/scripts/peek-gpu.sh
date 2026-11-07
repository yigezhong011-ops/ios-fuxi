#!/bin/bash
set -uo pipefail
echo "=== 自动化脚本日志尾部 ==="
tail -8 /root/fuxi/deepseek-gpu.log
echo
echo "=== run 41737636080 ==="
python3 /mnt/e/DSH-Fuxi/dump/wsl/run-status-detail.py 2>&1 | head -14
