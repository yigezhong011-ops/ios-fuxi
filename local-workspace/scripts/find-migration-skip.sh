#!/bin/bash
set -uo pipefail
echo "=== 仓库文档里关于 migration 的说明 ==="
grep -rn -i 'migration\|datamigrator\|AppleSetupDone\|setupdone' /root/ios-fuxi/docs-lanes/*.md /root/ios-fuxi/README*.md 2>/dev/null | head -15
echo
echo "=== 代码/脚本里提到 migration 的地方 ==="
grep -rn -i 'migration' /root/ios-fuxi/tools/*.py /root/ios-fuxi/tools/*.sh 2>/dev/null | head -10
