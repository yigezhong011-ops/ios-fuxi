#!/bin/bash
# Only the bsd_init stubs are bootstrap-only. The kit archive's stubs answer
# symbols this port genuinely does not build, so the real link needs them too.
set -euo pipefail
cd /root/fuxi/fork-device
git fetch -q origin old
git reset -q --hard origin/old

python3 - <<'PY'
from pathlib import Path

line = 'CONFIG_XNU_EXTRA_LD_ARCHIVES="{tree}/kits/sheng/libFuxiLinkStubs.a"'

for name in ('configs/fuxi_gpu_defconfig', 'configs/fuxi_gpu_bootstrap_defconfig'):
    p = Path(name)
    t = p.read_text()
    if line in t:
        print('  %-40s 已有' % name)
        continue
    t = t.rstrip('\n') + '\n\n# Stubs for symbols this port does not build (owner-root accounting, touch stats).\n' + line + '\n'
    p.write_text(t)
    print('  %-40s 已加入' % name)
PY

grep -n 'EXTRA_LD_ARCHIVES' configs/fuxi_gpu_defconfig configs/fuxi_gpu_bootstrap_defconfig
echo "=== bsd_init 补丁是否已带 bootstrap 宏守卫 ==="
grep -c 'XNU_BOOTSTRAP' patches/xnu/fuxi-link-stubs.patch
echo "=== 构建脚本是否传宏 ==="
grep -n 'DXNU_BOOTSTRAP' scripts/build-xnu-4k-baseline.sh

git add -A
git -c user.name=dsh -c user.email=dsh@local commit -q -m "configs: keep the kit stub archive in the real link as well"
git push -q origin old
echo "已推送"
