#!/bin/bash
set -uo pipefail
echo "=== 当前 cmdline ==="
grep '^CMDLINE=' /mnt/e/DSH-Fuxi/dump/wsl/step11b-build-boot.sh | head -1
echo
echo "=== 镜像构建时间/大小 ==="
ls -l /mnt/e/DSH-Fuxi/fuxi-diag.img
echo
echo "=== 镜像里的 ADT 根 extents 数（从文本里找）==="
strings -a /mnt/e/DSH-Fuxi/fuxi-diag.img 2>/dev/null | grep -c 'sweet,ufs-root-extents' || true
echo
echo "=== known-good 备份 ==="
ls -l /mnt/e/DSH-Fuxi/known-good/
