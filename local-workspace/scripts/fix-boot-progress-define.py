#!/usr/bin/env python3
"""build-boot-progress.py compiles BootProgress.c with startup.o's flags, which do
not carry XNU_BOOT_PROGRESS, while -I osfmk pulls in the header that hides the
real prototypes behind that macro. Define it for this compilation."""
from pathlib import Path

p = Path('/root/fuxi/fork-device/scripts/build-boot-progress.py')
t = p.read_text()
old = """['-mgeneral-regs-only', '-Wall', '-Wextra', '-Werror',
                                 '-I', str(ROOT / '.cache/xnu-work/osfmk')]"""
new = """['-mgeneral-regs-only', '-Wall', '-Wextra', '-Werror',
                                 '-DXNU_BOOT_PROGRESS=1',
                                 '-I', str(ROOT / '.cache/xnu-work/osfmk')]"""
if new in t:
    print('已经加过')
elif old in t:
    p.write_text(t.replace(old, new, 1))
    print('已加入 -DXNU_BOOT_PROGRESS=1')
else:
    raise SystemExit('找不到编译参数处')

import subprocess
subprocess.run(['git', '-C', '/root/fuxi/fork-device', 'add', '-A'], check=False)
subprocess.run(['git', '-C', '/root/fuxi/fork-device', '-c', 'user.name=dsh',
                '-c', 'user.email=dsh@local', 'commit', '-qm',
                'scripts: define XNU_BOOT_PROGRESS when building the progress backend'], check=False)
r = subprocess.run(['git', '-C', '/root/fuxi/fork-device', 'push', '-q', 'origin', 'old'], capture_output=True)
print('推送:', '成功' if r.returncode == 0 else r.stderr.decode()[:120])
