#!/bin/bash
set -uo pipefail
echo "=== hackios 仓库里的 RPMh 实现 ==="
grep -rln -i 'rpmh\|cmd.db\|cmd_db\|rsc' /root/hackios/xnuloader/ /root/hackios/src 2>/dev/null | head -8
echo
echo "=== loader.c 里的 RPMh 函数 ==="
grep -n -i 'rpmh\|cmd_db\|rsc_\|vrm' /root/hackios/xnuloader/loader.c 2>/dev/null | head -20
echo
echo "=== 仓库里其它 rpmh 文件 ==="
grep -rln -i 'cmd_db\|rpmh_rsc\|tcs_cmd' /root/hackios 2>/dev/null | head -8
