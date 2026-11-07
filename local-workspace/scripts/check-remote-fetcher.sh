#!/bin/bash
set -uo pipefail
cd /root/fuxi/fork-device || exit 1
git fetch -q origin old
echo "=== origin/old 的 fetcher 关键行 ==="
git show origin/old:scripts/fetch-adreno-inputs.py | grep -n 'adreno-source\|adreno-inputs\|TARGETS\|into' | head -8
echo
echo "=== 最新提交 ==="
git log --oneline -3 origin/old
