#!/bin/bash
set -uo pipefail
F=/root/ios-fuxi/shim/fuxi-loader/loader.c.bangprovn
echo "=== bangprovn loader 里的电源/RPMh ==="
grep -n -i 'rpmh\|ldo\|vreg\|rail\|touch' "$F" | head -25
echo
echo "=== 当前 fuxi loader 里的电源相关 ==="
grep -n -i 'rpmh\|ldo\|vreg\|rail\|power' /root/ios-fuxi/shim/fuxi-loader/loader.c | head -20
