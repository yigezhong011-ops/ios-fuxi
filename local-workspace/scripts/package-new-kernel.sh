#!/bin/bash
# Package the freshly built kernel into a boot image: keep the expert payload's
# ADT/trust cache/data seed and swap in our kernel.
set -euo pipefail
W=/root/fuxi/pkg
rm -rf "$W"; mkdir -p "$W/mnt"
cd "$W"

echo "=== 解压内核产物 ==="
cd "$W"
python3 - <<'PY'
import zipfile
from pathlib import Path
with zipfile.ZipFile('/root/kernel-artifact.zip') as z:
    for name in z.namelist():
        if name.endswith('kernel.macho') or name.endswith('kernel.json'):
            data = z.read(name)
            out = Path('/root/fuxi/pkg') / Path(name).name
            out.write_bytes(data)
            print('  %-24s %d B' % (out.name, len(data)))
PY

echo "=== 取专家版的 ADT / trustcache / scratch ==="
for m in $(mount | awk '/vfat|msdos/{print $3}'); do umount -l "$m" 2>/dev/null || true; done
mount -t vfat -o loop,ro /root/fuxi/expert-payload-vol.img "$W/mnt"
cp "$W/mnt/EFI/UniXNU/Payloads/kernel.macho.adt"         "$W/kernel.macho.adt"
cp "$W/mnt/EFI/UniXNU/Payloads/kernel.macho.trustcache"  "$W/kernel.macho.trustcache"
cp "$W/mnt/EFI/UniXNU/Payloads/scratch-data.img"         "$W/scratch-data.img"
cp "$W/mnt/EFI/UniXNU/unixnu.toml"                       "$W/unixnu.toml"
umount "$W/mnt"
ls -l "$W" | head -8

echo "=== 组装新 payload 卷（201 MB 稀疏） ==="
cd "$W"
python3 - <<'PY'
import shutil, subprocess
from pathlib import Path
w = Path('/root/fuxi/pkg')
img = w / 'payload-new.img'
img.write_bytes(b'')
with img.open('wb') as f:
    f.truncate(201 * 1024 * 1024)
subprocess.run(['mkfs.vfat', '-F', '32', '-n', 'FUXIESP', str(img)], check=True, capture_output=True)
out = subprocess.run(['mcopy', '-i', str(img), '-s', '-m', str(w / 'payload'), '::/'], capture_output=True)
print('mcopy payload:', out.returncode, out.stderr.decode()[:200])
PY
echo "准备 payload 目录"
mkdir -p "$W/payload/EFI/UniXNU/Payloads"
cp "$W/kernel.macho"              "$W/payload/EFI/UniXNU/Payloads/kernel.macho"
cp "$W/kernel.macho.adt"          "$W/payload/EFI/UniXNU/Payloads/kernel.macho.adt"
cp "$W/kernel.macho.trustcache"   "$W/payload/EFI/UniXNU/Payloads/kernel.macho.trustcache"
cp "$W/scratch-data.img"          "$W/payload/EFI/UniXNU/Payloads/scratch-data.img"
cp "$W/unixnu.toml"               "$W/payload/EFI/UniXNU/unixnu.toml"
rm -f "$W/payload-new.img"
python3 - <<'PY'
import subprocess
from pathlib import Path
w = Path('/root/fuxi/pkg')
img = w / 'payload-new.img'
with img.open('wb') as f:
    f.truncate(201 * 1024 * 1024)
subprocess.run(['mkfs.vfat', '-F', '32', '-n', 'FUXIESP', str(img)], check=True, capture_output=True)
out = subprocess.run(['mcopy', '-i', str(img), '-s', str(w / 'payload'), '::/'], capture_output=True)
print('mcopy:', out.returncode, out.stderr.decode()[:300])
print('payload 大小', img.stat().st_size)
PY
echo PACKAGE_STAGE_OK
