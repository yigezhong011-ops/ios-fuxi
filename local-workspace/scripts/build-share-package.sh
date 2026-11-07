#!/bin/bash
# Assemble the share package: boot image, kernel, patches, notes.
set -euo pipefail
S=/mnt/e/DSH-Fuxi/share-2026-10-31
DEV=/root/fuxi/fork-device

mkdir -p "$S/kernel" "$S/patches"

echo "=== 内核产物 ==="
python3 - <<'PY'
import zipfile
from pathlib import Path
out = Path('/mnt/e/DSH-Fuxi/share-2026-10-31/kernel')
with zipfile.ZipFile('/root/kernel-artifact.zip') as z:
    for name in z.namelist():
        data = z.read(name)
        target = out / Path(name).name
        target.write_bytes(data)
        print('  %-24s %d B' % (target.name, len(data)))
PY

echo "=== 刷机映像 ==="
cp /mnt/e/DSH-Fuxi/unixnu-ourkernel.img "$S/unixnu-ourkernel.img"
ls -lh "$S/unixnu-ourkernel.img" | awk '{print "  ", $9, $5}'

echo "=== 补丁与覆盖脚本 ==="
cd "$DEV"
for f in patches/xnu/fuxi-link-stubs.patch \
         configs/fuxi_gpu_defconfig \
         scripts/fetch-adreno-inputs.py \
         scripts/build-adreno740-kits.py \
         scripts/build-adreno740-accelerator.py \
         scripts/build-native-legacy-display.py \
         scripts/audit-mobile-graphics-legacy.py \
         board.toml; do
  if [ -f "$f" ]; then
    mkdir -p "$S/patches/$(dirname "$f")"
    cp "$f" "$S/patches/$f"
    echo "  $f"
  fi
done

echo "=== 设备仓库的提交列表 ==="
git log --oneline -25 > "$S/patches/commits.txt"
wc -l < "$S/patches/commits.txt"

echo "=== 文件清单 ==="
find "$S" -type f -printf '%10s  %p\n' | sort -k2 | sed 's|/mnt/e/DSH-Fuxi/share-2026-10-31|.|'
