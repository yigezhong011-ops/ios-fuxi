#!/bin/bash
set -uo pipefail
echo "=== pip log 里的错误 ==="
grep -n -i -E 'error|failed|cannot' /root/uefi-pip.log | tail -15
echo
echo "=== 已安装的 edk2 包 ==="
python3 -m pip list 2>/dev/null | grep -i -E 'edk2|antlr|regex|pefile|coloredlogs' || echo "(none)"
echo
echo "=== rich 状态 ==="
python3 -m pip show rich 2>/dev/null | head -4 || echo "(rich 未安装)"
