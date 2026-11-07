#!/bin/bash
set -uo pipefail
echo "=== 设备树里的 cmd-db ==="
grep -n -i -B3 -A8 'cmd.db\|cmddb' /root/fuxi/fuxi-live.dts | head -40
