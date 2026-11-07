#!/bin/bash
set -uo pipefail
echo "=== sweet_spmi 的能力（读/写）==="
grep -n 'sweet_spmi_\|spmi_write\|spmi_read\|cmd\|write' /root/ios-fuxi/xnu/fuxi-h1/sweet_spmi_bus.h 2>/dev/null | head -20
echo
echo "=== sweet_spmi.c 里的写路径 ==="
grep -n -i 'write\|cmd\|addr' /root/ios-fuxi/xnu/fuxi-h1/sweet_spmi.c 2>/dev/null | head -20
