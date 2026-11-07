#!/bin/bash
set -uo pipefail
cd /root/ios-fuxi
echo "=== 文档里 autolock / idle / display off ==="
grep -rn -i -E 'autolock|auto-lock|idle timer|display off|lock screen' docs docs-lanes README.md 2>/dev/null | head -20 || echo "(none)"
echo
echo "=== Boot-args 相关（driver 里）==="
grep -n -E 'PE_parse_boot_argn' xnu/fuxi-unixnu/SweetFramebuffer.cpp | head -20
