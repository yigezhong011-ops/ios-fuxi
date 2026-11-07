#!/usr/bin/env python3
"""Add -DXNU_BOOT_PROGRESS=1 to the two compilations that include osfmk headers
whose prototypes are hidden behind that macro."""
from pathlib import Path

p = Path('/root/fuxi/fork-device/scripts/build-boot-progress.py')
t = p.read_text()

old = """                             '-I', str(ROOT / '.cache/xnu-work/osfmk')])"""
new = """                             '-DXNU_BOOT_PROGRESS=1',
                             '-I', str(ROOT / '.cache/xnu-work/osfmk')])"""
old2 = """                          ['-mgeneral-regs-only', '-Wall', '-Wextra', '-Werror',
                           '-I', str(ROOT / '.cache/xnu-work/osfmk')])"""
new2 = """                          ['-mgeneral-regs-only', '-Wall', '-Wextra', '-Werror',
                           '-DXNU_BOOT_PROGRESS=1',
                           '-I', str(ROOT / '.cache/xnu-work/osfmk')])"""

if new in t:
    print('已经加过')
else:
    n = t.count(old) + t.count(old2)
    t = t.replace(old, new).replace(old2, new2)
    p.write_text(t)
    print('替换处数:', n)

import subprocess
subprocess.run(['git', '-C', '/root/fuxi/fork-device', 'add', '-A'], check=False)
subprocess.run(['git', '-C', '/root/fuxi/fork-device', '-c', 'user.name=dsh',
                '-c', 'user.email=dsh@local', 'commit', '-qm',
                'scripts: define XNU_BOOT_PROGRESS for the osfmk-including builds'], check=False)
r = subprocess.run(['git', '-C', '/root/fuxi/fork-device', 'push', '-q', 'origin', 'old'], capture_output=True)
print('推送:', '成功' if r.returncode == 0 else r.stderr.decode()[:120])
