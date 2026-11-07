#!/bin/bash
set -uo pipefail
echo "=== 构建树里的 UniXNUPkg ==="
ls /root/UniXNU/out/fuxi/ipados-17.7.11-21H461/fuxi/tree/package/UniXNUPkg/Driver/ 2>/dev/null
echo
echo "=== UniXNU 源码里的官方 ramdisk 驱动 ==="
ls -l /root/UniXNU/package/UniXNUPkg/Driver/UniXNURamDiskDxe/ 2>/dev/null || echo "(源码里没有，可能只存在于 submodule)"
echo
echo "=== 入口参数 HOB GUID 是否在源码中被引用 ==="
grep -rn 'DAEE82E6\|EntryArgHob' /root/UniXNU/package/UniXNUPkg/ 2>/dev/null | head -5
