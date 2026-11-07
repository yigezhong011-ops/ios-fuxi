#!/bin/bash
set -uo pipefail
cd /root/ios-fuxi
echo "=== tools/fuxi-sb/ ==="
ls -l tools/fuxi-sb/ 2>/dev/null || echo "no such dir"
echo
echo "=== docs-lanes/sys-port.md 目录 ==="
grep -nE '^#' docs-lanes/sys-port.md | head -25
echo
echo "=== sys-port 里提到 SpringBoard 快照/呈现的段落 ==="
grep -n -i -E 'snapshot|present|black|render|Metal|SpringBoard' docs-lanes/sys-port.md | head -25
