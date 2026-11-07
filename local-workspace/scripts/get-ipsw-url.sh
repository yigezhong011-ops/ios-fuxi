#!/bin/bash
set -uo pipefail
F=/root/fuxi/uni-star/profiles/os/ipados-17.7.11-21H461/profile.toml
echo "=== IPSW 地址 ==="
grep -o 'https://updates.cdn-apple.com[^"]*\.ipsw' "$F" | head -2
echo "=== 产品与版本 ==="
grep -E '"(product|version|build|device_class)"' "$F" | head -6
echo "=== dmg 的 sha256 表 ==="
awk '/\[ipsw.sha256\]/,/^$/' "$F" | head -6
