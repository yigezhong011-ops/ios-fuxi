#!/bin/bash
# Edit our device fork with git: drop the PMGR archive (the only one that needs a
# prelink candidate) and add a full config that links the stub archive instead.
set -euo pipefail
TOKEN=$(tr -d '\r\n' < /mnt/e/DSH-Fuxi/token2.txt)
W=/root/fuxi/fork-device
rm -rf "$W"
git clone -q "https://x-access-token:${TOKEN}@github.com/yigezhong011-ops/unixnu-fuxi.git" "$W"
cd "$W"
git checkout -q old

echo "=== 改 board.toml：去掉 PMGR 归档 ==="
python3 - <<'PY'
from pathlib import Path
p = Path('board.toml')
t = p.read_text()
line = '  "build-sheng-platform-power.py",\n'
if line in t:
    t = t.replace(line, '', 1)
    p.write_text(t)
    print('  已移除 build-sheng-platform-power.py')
else:
    print('  没找到该行（可能已移除）')
PY

echo "=== 新增 fuxi_gpu_defconfig ==="
python3 - <<'PY'
from pathlib import Path
full = Path('configs/fuxi_full_defconfig').read_text()
extra = ('\n# Link-only stubs for the symbols the skipped PMGR archive provided.\n'
         'CONFIG_XNU_EXTRA_LD_ARCHIVES="../../../device/build/fuxi-link-stubs/libFuxiLinkStubs.a"\n')
lines = [l for l in full.splitlines() if not l.startswith('CONFIG_XNU_EXTRA_LD_ARCHIVES')]
Path('configs/fuxi_gpu_defconfig').write_text('\n'.join(lines) + '\n' + extra)
print('  写好 fuxi_gpu_defconfig', len(lines) + 3, '行')
PY

git -c user.name=dsh -c user.email=dsh@local add -A
git -c user.name=dsh -c user.email=dsh@local commit -q -m "board: build without the PMGR archive so a clean checkout can produce a kernel"
git push -q origin old
echo "已推送"
grep -n 'build-sheng-platform-power' board.toml || echo "  board.toml 已无 PMGR 行"
tail -3 configs/fuxi_gpu_defconfig
