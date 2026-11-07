#!/bin/bash
set -uo pipefail
echo "=== log kit 的 Include ==="
ls /root/build/log-kit/Uefi/Common/Include 2>/dev/null
echo
echo "=== 协议 GUID 定义 ==="
grep -rn 'gUniXNULogFlushProtocolGuid\|gUniXNUMenuPluginProtocolGuid' /root/build/log-kit 2>/dev/null | head -6 | cut -c1-150
echo
echo "=== UniXNUPkg.dec 的 [Protocols] 段 ==="
awk '/^\[Protocols\]/,/^\[/' /root/build/unixnu/package/UniXNUPkg/UniXNUPkg.dec 2>/dev/null | head -12
echo
echo "=== 现有 Include 目录 ==="
ls /root/build/unixnu/package/UniXNUPkg/Include 2>/dev/null
