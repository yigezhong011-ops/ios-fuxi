#!/bin/bash
# The bootstrap pass must see a define so the link stubs can exist only there;
# once the real archives exist their strong definitions must win.
set -euo pipefail
cd /root/fuxi/fork-device
git fetch -q origin old
git reset -q --hard origin/old

echo "=== 1) 让脚本传 -DXNU_BOOTSTRAP ==="
python3 - <<'PY'
from pathlib import Path
p = Path('scripts/build-xnu-4k-baseline.sh')
t = p.read_text()
old = 'EXTRA_CFLAGS="$EXTRA_CFLAGS -DXNU_BOOT_PROGRESS=$BOOT_PROGRESS"'
new = ('EXTRA_CFLAGS="$EXTRA_CFLAGS -DXNU_BOOT_PROGRESS=$BOOT_PROGRESS"\n'
       '# The link stubs in bsd_init.c exist only for the bootstrap pass; without this\n'
       '# define their weak definitions satisfy the symbols and the real archives are\n'
       '# never pulled in.\n'
       'EXTRA_CFLAGS="$EXTRA_CFLAGS -DXNU_BOOTSTRAP=$BOOTSTRAP"')
if '-DXNU_BOOTSTRAP=' in t:
    print('  已经加过')
else:
    if old not in t:
        raise SystemExit('找不到 EXTRA_CFLAGS 那一行')
    t = t.replace(old, new, 1)
    p.write_text(t)
    print('  已加入 -DXNU_BOOTSTRAP=$BOOTSTRAP')
PY

echo "=== 2) EXTRA_LD_ARCHIVES 只留给 bootstrap 配置 ==="
python3 - <<'PY'
from pathlib import Path
gpu = Path('configs/fuxi_gpu_defconfig')
t = gpu.read_text()
kept = [l for l in t.splitlines() if not l.startswith('CONFIG_XNU_EXTRA_LD_ARCHIVES')]
gpu.write_text('\n'.join(kept) + '\n')
print('  fuxi_gpu_defconfig: 去掉 EXTRA_LD_ARCHIVES 行')

boot = Path('configs/fuxi_gpu_bootstrap_defconfig')
bt = boot.read_text()
line = 'CONFIG_XNU_EXTRA_LD_ARCHIVES="{tree}/kits/sheng/libFuxiLinkStubs.a"'
if line not in bt:
    bt = bt.rstrip('\n') + '\n' + line + '\n'
    boot.write_text(bt)
    print('  fuxi_gpu_bootstrap_defconfig: 保留 stub 归档')
PY

grep -n 'EXTRA_LD_ARCHIVES' configs/*.defconfig || true

git add -A
git -c user.name=dsh -c user.email=dsh@local commit -q -m "build: define XNU_BOOTSTRAP and keep the stubs to the bootstrap pass"
git push -q origin old
echo "已推送"
