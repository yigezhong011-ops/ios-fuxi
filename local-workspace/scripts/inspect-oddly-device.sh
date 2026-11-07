#!/bin/bash
# Inspect OddlyLabs' fuxi device repository layout.
set -euo pipefail
W=/root/fuxi/fuxi-oddly
rm -rf "$W"
git clone -q --depth 1 https://github.com/OddlyLabs/unixnu-fuxi.git "$W"
cd "$W"
echo "=== 顶层 ==="
ls
echo
echo "=== configs ==="
ls configs
echo
echo "=== drivers ==="
ls drivers 2>/dev/null | head -10
echo
echo "=== package 里的 touch 相关 ==="
ls package 2>/dev/null | grep -i 'fts\|touch\|spi' | head -10
echo
echo "=== board.toml 的 [components] 与 touch ==="
grep -n -i 'include\|Fts\|GeniSpi\|touch' board.toml | head -14 | cut -c1-160
echo
echo "=== 有没有自己的 components.toml ==="
ls components.toml drivers/components.toml 2>/dev/null || echo "无"
