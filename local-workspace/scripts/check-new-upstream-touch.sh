#!/bin/bash
set -uo pipefail
echo "=== 新上游（541 提交后）的触控驱动 ==="
ls /root/fuxi/uni-fork/drivers 2>/dev/null | grep -i 'touch\|hid\|novatek\|goodix\|geni'
echo
echo "=== 新上游有没有 goodix 字样 ==="
grep -rl -i 'goodix\|gt9916' /root/fuxi/uni-fork --include='*.c' --include='*.cpp' --include='*.h' 2>/dev/null | head -8
echo
echo "=== 新上游的 QcomGeniSpi / 触控相关驱动目录 ==="
ls -d /root/fuxi/uni-fork/drivers/*Touch* /root/fuxi/uni-fork/drivers/*Hid* 2>/dev/null
echo
echo "=== 其他 fuxi 移植有没有 goodix ==="
grep -rl -i 'goodix\|gt9916' /root/fuxi/fuxi2 2>/dev/null | head -5
