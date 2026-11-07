#!/bin/bash
# Repack the reverse-engineered GPU userspace into the NGPUADD2 container the
# kernel's addon mount expects.
set -euo pipefail
W=/root/fuxi/addon-new
rm -rf "$W"; mkdir -p "$W"
cd "$W"

echo "=== 解出 gpu-userspace ==="
python3 - <<'PY'
import zipfile
from pathlib import Path
z = zipfile.ZipFile(r'/mnt/c/Users/USER/Downloads/Adreno740-GPU逆向结果-20261101.zip')
base = 'Adreno740-GPU逆向结果-20261101/gpu-userspace/'
out = Path('/root/fuxi/addon-new/raw')
out.mkdir(parents=True, exist_ok=True)
n = 0
for e in z.namelist():
    if e.startswith(base) and not e.endswith('/'):
        rel = e[len(base):]
        if rel.startswith(('addons/', 'bin/', 'daemons/')):
            p = out / rel
            p.parent.mkdir(parents=True, exist_ok=True)
            p.write_bytes(z.read(e))
            n += 1
            print('  %-58s %10d' % (rel, p.stat().st_size))
z.close()
print('共', n, '个文件')
PY

echo "=== 整理成打包器要的布局 ==="
mkdir -p plugin
cp -r raw/addons/NativeAdrenoMetal.bundle plugin/
cp raw/bin/adrenoprobed plugin/
cp raw/daemons/*.plist plugin/ 2>/dev/null || true
find plugin -maxdepth 2 | head -12
du -sh plugin

echo "=== 打包 NGPUADD2 ==="
ADRENO_PLUGIN_DIR="$W/plugin" python3 /root/fuxi/uni-fork/scripts/make-gpu-addon.py --publish "$W/kernel.macho.gpuaddon" 2>&1 | tail -10
ls -lh kernel.macho.gpuaddon
python3 - <<'PY'
from pathlib import Path
d = Path('/root/fuxi/addon-new/kernel.macho.gpuaddon').read_bytes()
print('魔数:', d[:8], '大小:', len(d))
PY
