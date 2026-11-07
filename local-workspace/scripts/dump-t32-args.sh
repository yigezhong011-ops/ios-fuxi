#!/bin/bash
set -uo pipefail
mtype -i /root/fuxi/t32/vol.img ::/EFI/UniXNU/unixnu.toml 2>/dev/null > /root/fuxi/t32/toml.orig
echo "=== 文件大小 ==="
wc -c < /root/fuxi/t32/toml.orig
echo "=== 参数 ==="
grep -o 'args = "[^"]*"' /root/fuxi/t32/toml.orig | sed 's/^args = "//; s/"$//' | tr ' ' '\n' | nl | head -70
