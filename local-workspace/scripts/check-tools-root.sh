#!/bin/bash
set -uo pipefail
echo "=== 工具检查 ==="
for t in apfs-fuse hfsplus mkfs.hfsplus fsck.hfsplus rsync 7z unzip; do
  printf '%-16s %s\n' "$t" "$(command -v $t || echo MISSING)"
done
echo
echo "=== mkiosroot.sh 用法行 ==="
sed -n '1,12p' /root/fuxi/mkiosroot.sh
echo
echo "=== E: 磁盘剩余空间 ==="
df -h /mnt/e | tail -1
echo
echo "=== 现有 16G root 镜像？ ==="
ls -lh /root/fuxi/*.img /mnt/e/DSH-Fuxi/*.img 2>/dev/null | head -5
