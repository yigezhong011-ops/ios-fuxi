#!/bin/bash
# Restore the CLT clang shim and instead tell the kernel driver to use xnu's own
# host compiler wrapper (xnu-host-cc), which knows the Mach-O libraries and the
# host linker. XNU's makedefs honour an exported HOST_CC.
set -euo pipefail
SHIM=/opt/unixnu-linux/CommandLineTools/usr/bin/clang
if [ -f "$SHIM.orig" ]; then
  cp -a "$SHIM.orig" "$SHIM"
  echo "已恢复原始 CLT clang shim"
else
  echo "没有 .orig 备份，跳过恢复"
fi
ls -l "$SHIM" | head -1

python3 - <<'PY'
from pathlib import Path
p = Path('/mnt/e/DSH-Fuxi/unixnu-build/unixnu/scripts/unixnu/kernel.py')
t = p.read_text()
needle = "'UNIXNU_PLATFORM_PATH': str(fakeroot / 'Platforms/iPhoneOS.platform'),"
add = needle + "\n            'HOST_CC': str(clt / 'bin/xnu-host-cc'),"
if "'HOST_CC'" in t:
    print('HOST_CC 已经设置')
else:
    if needle not in t:
        raise SystemExit('找不到插入点')
    p.write_text(t.replace(needle, add, 1))
    print('已在驱动里导出 HOST_CC=xnu-host-cc')
for line in p.read_text().splitlines():
    if 'HOST_CC' in line:
        print('  ' + line.strip()[:120])
PY
