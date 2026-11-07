#!/bin/bash
set -uo pipefail
echo "=== sm7325 仓库结构 ==="
ls /root/hakios-sm7325 2>/dev/null
echo
echo "=== 参考的 soc.args ==="
find /root/hakios-sm7325 -name 'soc.args' | head -2 | while read -r f; do echo "--- $f"; cat "$f"; done
echo
echo "=== 缺失键在代码里的用法 ==="
cd /root/hakios-xnu-kernel || exit 1
grep -rn 'soc_cmd_db\|soc_mpss_mem\|modem_ipa_fw_at\|soc_pas_mpss' --include='*.c' --include='*.cpp' --include='*.h' . 2>/dev/null | head -10 | cut -c1-165
