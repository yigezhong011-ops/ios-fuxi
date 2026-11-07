#!/bin/bash
set -uo pipefail
T=/root/ux3/fuxi/tree
echo "=== drivers 目录 ==="
ls "$T/drivers" 2>/dev/null | head -16
echo
echo "=== 各驱动目录里的 OriginalAcceleratorABI.h ==="
find "$T/drivers" -name 'Original*ABI*.h' 2>/dev/null | head -6
echo
echo "=== AdrenoMetal 目录里有没有 original 相关 ==="
ls "$T/drivers/AdrenoMetal" 2>/dev/null | grep -i 'original\|abi' | head -6 || echo "  （无）"
