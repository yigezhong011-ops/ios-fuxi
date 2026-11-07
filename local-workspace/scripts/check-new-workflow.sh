#!/bin/bash
set -uo pipefail
cd /root/fuxi/uni-fork || exit 1
echo "=== workflow 文件 ==="
ls .github/workflows/
echo "=== 上传相关的行 ==="
grep -n 'upload-artifact\|Upload ' .github/workflows/*.yml | head -12 | cut -c1-150
