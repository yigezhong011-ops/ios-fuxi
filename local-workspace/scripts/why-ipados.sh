#!/bin/bash
set -uo pipefail
B=/mnt/e/DSH-Fuxi/unixnu-build
echo "=== devices.toml 里的 fuxi / sheng 条目 ==="
grep -n -A6 -iE '^\s*(\[|name).*(fuxi|sheng)' "$B/unixnu/devices.toml" 2>/dev/null | head -30
echo
echo "=== fuxi 仓库里出现的 OS profile / IPSW 引用 ==="
grep -rn -iE 'ipados|ipad7|17\.7\.11|ios-17|os_profile' "$B/fuxi" --include='*.toml' --include='*.md' 2>/dev/null | head -12
echo
echo "=== unixnu 的 os profile 目录 ==="
ls "$B/unixnu/profiles/os" 2>/dev/null
