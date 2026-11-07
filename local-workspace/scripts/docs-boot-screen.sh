#!/bin/bash
set -uo pipefail
echo "=== 文档里的 boot progress / lock screen / SpringBoard 启动 ==="
grep -rn -i 'boot progress\|progress bar\|lock screen\|lockscreen\|first unlock\|SpringBoard' /root/ios-fuxi/docs/sweet.md /root/ios-fuxi/docs-lanes/*.md 2>/dev/null | head -20
