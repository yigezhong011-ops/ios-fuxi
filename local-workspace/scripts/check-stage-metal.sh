#!/bin/bash
set -uo pipefail
echo "=== stage-fuxi-metal.py 的 backboardd 选项 ==="
grep -n 'backboardd' /root/ios-fuxi/tools/stage-fuxi-metal.py | head -15
echo
echo "=== BackboardGate 的 strike 记录 ==="
grep -n -iE 'strike|persist|path|open\(' /root/ios-fuxi/tools/fuxi-metal/BackboardGate.hpp | head -20
