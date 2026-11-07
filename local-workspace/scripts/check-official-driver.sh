#!/bin/bash
set -uo pipefail
echo "=== 官方驱动的 INF ==="
cat /root/UniXNU/package/UniXNUPkg/Driver/UniXNURamDiskDxe/UniXNURamDiskDxe.inf
echo
echo "=== 驱动主体逻辑（HOB → FDT → initrd）==="
grep -n -E 'InitrdStart|initrd-start|linux,initrd|GetFirstGuidHob|Fdt|PUBLISH|Block' /root/UniXNU/package/UniXNUPkg/Driver/UniXNURamDiskDxe/UniXNURamDiskDxe.c | head -20
echo
echo "=== fuxi DSC 里的 HobLib / FdtLib ==="
grep -n -E 'HobLib|FdtLib' /root/uefi-fuxi/Platforms/Xiaomi/fuxiPkg/fuxi.dsc | head -8
