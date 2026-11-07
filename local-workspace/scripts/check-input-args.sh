#!/bin/bash
set -uo pipefail
D=/root/fuxi/uni-fork/docs
echo "=== boot-args 里触控/背光/电池相关 ==="
grep -n -i 'touch\|backlight\|brightness\|battery\|charger\|power button\|keys' "$D/boot-args.md" 2>/dev/null | head -24 | cut -c1-160
