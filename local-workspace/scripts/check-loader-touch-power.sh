#!/bin/bash
set -uo pipefail
echo "=== loader 里的 RPMh / LDO 触摸供电 ==="
grep -rn -i 'ldob12\|ldom6\|touch.*rail\|rail.*touch\|rpmh' /root/ios-fuxi/shim/fuxi-loader/*.c 2>/dev/null | head -12
echo
echo "=== loader 源文件 ==="
ls /root/ios-fuxi/shim/fuxi-loader/ 2>/dev/null | head -10
echo
echo "=== 运行时日志里触摸供电的痕迹 ==="
tr -d '\000' < /root/fuxi/mon39/boot.log 2>/dev/null | grep -a -i 'ldob12\|ldom6\|touch.*rail\|rail.*touch' | head -6
echo
echo "=== loader 自己的日志里有 touch 吗 ==="
ls /root/fuxi/mon39/ 2>/dev/null | head -8
