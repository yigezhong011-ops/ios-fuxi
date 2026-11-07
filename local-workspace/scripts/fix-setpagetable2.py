#!/usr/bin/env python3
"""Patch package/GpuPowerProbe.cpp: the ring has no setPageTable in this driver
revision, so keep the diagnostic row instead of publishing the page table."""
import subprocess
from pathlib import Path

p = Path('/root/fuxi/fork-device/package/GpuPowerProbe.cpp')
text = p.read_text()
old = '        gRing.setPageTable(ttbr0, asid);'
new = ('        // This driver revision has no NativeAdrenoRing::setPageTable; record what\n'
       '        // the context reported so the probe still shows the page table it found.\n'
       '        snprintf(row, sizeof row, "C1 pagetable ttbr0 %llx asid %u",\n'
       '                 (unsigned long long)ttbr0, asid);\n'
       '        setRow(7, row);')
if 'no NativeAdrenoRing::setPageTable' in text:
    print('已经改过')
elif old in text:
    p.write_text(text.replace(old, new, 1))
    print('已替换')
else:
    raise SystemExit('找不到调用行')

subprocess.run(['git', '-C', '/root/fuxi/fork-device', 'add', '-A'], check=False)
subprocess.run(['git', '-C', '/root/fuxi/fork-device', '-c', 'user.name=dsh',
                '-c', 'user.email=dsh@local', 'commit', '-qm',
                'package: drop the ring setPageTable call this driver revision lacks'], check=False)
r = subprocess.run(['git', '-C', '/root/fuxi/fork-device', 'push', '-q', 'origin', 'old'], capture_output=True)
print('推送:', '成功' if r.returncode == 0 else r.stderr.decode()[:120])
