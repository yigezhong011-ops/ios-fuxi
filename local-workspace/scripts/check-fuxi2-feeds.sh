#!/bin/bash
set -uo pipefail
cd /root/fuxi/fuxi2 || exit 1
echo "=== feeds.toml 前 40 行 ==="
head -40 feeds.toml | cut -c1-140
echo
echo "=== board.toml 里引用 os profile 的地方 ==="
grep -n 'os_profile\|ios-16\|profiles/os' board.toml | head -6 | cut -c1-140
