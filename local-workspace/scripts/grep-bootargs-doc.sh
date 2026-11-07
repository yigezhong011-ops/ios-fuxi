#!/bin/bash
set -uo pipefail
F=/root/fuxi/uni-fork/docs/xnu/boot-arguments.md
echo "=== 参数目录里 touch / backlight / battery / keys ==="
grep -n -i 'sheng-touch\|backlight\|brightness\|sheng-batt\|sheng-adsp\|sheng-keys\|power-button\|sheng-pmgr\|sheng-aks' "$F" 2>/dev/null | head -24 | cut -c1-165
