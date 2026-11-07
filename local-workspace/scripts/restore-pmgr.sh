#!/bin/bash
# The candidate now exists, so the PMGR archive can build again — it is what
# enables interrupts, and without it the kernel hard-locks with IRQ off.
set -euo pipefail
cd /root/fuxi/fork-device
git fetch -q origin old
git reset -q --hard origin/old

python3 - <<'PY'
from pathlib import Path

# 1) restore the PMGR archive in the chain, right after libpthread
p = Path('board.toml')
t = p.read_text()
anchor = '  "build-libpthread-kernel.py",'
if 'build-sheng-platform-power.py' not in t:
    t = t.replace(anchor, anchor + '\n  "build-sheng-platform-power.py",', 1)
    p.write_text(t)
    print('board.toml: 已恢复 PMGR 归档')

# 2) turn the kernel side back on
c = Path('configs/fuxi_gpu_defconfig')
ct = c.read_text()
ct = ct.replace('CONFIG_XNU_SHENG_PMGR=n', 'CONFIG_XNU_SHENG_PMGR=y')
c.write_text(ct)
print('defconfig: SHENG_PMGR=y')
PY

grep -n 'sheng-platform-power' board.toml | head -2
grep -n 'SHENG_PMGR' configs/fuxi_gpu_defconfig

git add -A
git -c user.name=dsh -c user.email=dsh@local commit -q -m "board: restore the PMGR archive now that the candidate exists"
git push -q origin old
echo "已推送"
