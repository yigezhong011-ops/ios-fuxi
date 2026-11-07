#!/bin/bash
set -uo pipefail
W=/root/fuxi/t36-bl2
mtype -i "$W/vol.img" ::/EFI/UniXNU/unixnu.toml > /root/fuxi/t36-cur.toml 2>/dev/null
echo "=== toml 大小与 args ==="
wc -c < /root/fuxi/t36-cur.toml
A=$(grep -o 'args = "[^"]*"' /root/fuxi/t36-cur.toml | sed 's/^args = "//; s/"$//')
echo "args 字符数: ${#A}"
echo "title: $(grep -o 'title = "[^"]*"' /root/fuxi/t36-cur.toml | head -1)"
echo
echo "=== 当前 sheng-disable-jobs ==="
echo "$A" | tr ' ' '\n' | grep 'sheng-disable-jobs'
echo
echo "=== args 里还剩多少空位（1000 上限）==="
echo $((1000 - ${#A}))
