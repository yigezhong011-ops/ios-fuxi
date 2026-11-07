#!/bin/bash
set -uo pipefail
F=/root/ux3/fuxi/tree/kits/NativePrelink/emit_prelink.py
[ -f "$F" ] || F=$(find /root/ux3 -name emit_prelink.py 2>/dev/null | head -1)
echo "脚本: $F"
echo "=== 输出相关 ==="
grep -n 'json\|output\|write_text\|\.macho' "$F" 2>/dev/null | head -16 | cut -c1-170
echo
echo "=== 参数 ==="
grep -n 'add_argument' "$F" 2>/dev/null | head -12 | cut -c1-150
