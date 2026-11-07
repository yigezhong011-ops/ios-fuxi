#!/bin/bash
set -uo pipefail
cd /root/fuxi/fork-device
echo "=== board.toml 的 [payload] 段 ==="
awk '/^\[payload\]/,/^\[/' board.toml | head -20 | cut -c1-170
echo
echo "=== trust_cache 相关键 ==="
grep -n 'trust_cache\|trustcache' board.toml | head -6 | cut -c1-170
echo
echo "=== 设备仓库里有没有 trust cache 文件 ==="
find . -iname '*trust*' -not -path './.git/*' 2>/dev/null | head -6
