#!/bin/bash
set -uo pipefail
D=/root/fuxi/uni-fork/docs/.vitepress/device-records
echo "=== sheng 记录里的触控/背光/电池参数 ==="
grep -n -i 'sheng-touch\|backlight\|brightness\|battery\|sheng-hid\|sheng-keys\|power' "$D/sheng.toml" 2>/dev/null | head -20 | cut -c1-175
echo
echo "=== fuxi 记录里的相关项 ==="
ls "$D" | grep -i fuxi
grep -n -i 'touch\|backlight\|battery\|gpu\|display' "$D"/*fuxi*.toml 2>/dev/null | head -20 | cut -c1-175
