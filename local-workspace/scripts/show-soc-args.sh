#!/bin/bash
set -uo pipefail
cd /root/hakios-xnu-kernel || exit 1
echo "=== soc.args（fuxi）==="
cat devices/fuxi/soc.args 2>/dev/null | head -30
echo
echo "=== 参考机型 redwood 的 soc.args ==="
cat devices/redwood/soc.args 2>/dev/null | head -30
