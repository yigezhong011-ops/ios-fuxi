#!/usr/bin/env python3
"""GpuPowerProbe is the tablet's probe: it calls NativeAdrenoRing::setPageTable,
which this driver revision no longer has. Keep the diagnostic, drop the call."""
import subprocess
from pathlib import Path

p = Path('/root/fuxi/fork-device/kits/sheng/GpuPowerProbe.cpp')
text = p.read_text()
old = '        gRing.setPageTable(ttbr0, asid);'
new = ('        // The sheng probe published the ring\'s SMMU page table here; this driver\n'
       '        // revision has no setPageTable, so record what the context reported.\n'
       '        snprintf(row, sizeof row, "C1 pagetable ttbr0 %llx asid %u",\n'
       '                 (unsigned long long)ttbr0, asid);\n'
       '        setRow(7, row);')
if new.splitlines()[0] in text:
    print('已经改过')
elif old in text:
    p.write_text(text.replace(old, new, 1))
    print('已替换 setPageTable 调用')
else:
    raise SystemExit('找不到调用行')

subprocess.run(['git', '-C', '/root/fuxi/fork-device', 'add', '-A'], check=False)
subprocess.run(['git', '-C', '/root/fuxi/fork-device', '-c', 'user.name=dsh',
                '-c', 'user.email=dsh@local', 'commit', '-qm',
                'kits: drop the ring setPageTable call this driver revision lacks'], check=False)
r = subprocess.run(['git', '-C', '/root/fuxi/fork-device', 'push', '-q', 'origin', 'old'], capture_output=True)
print('推送:', '成功' if r.returncode == 0 else r.stderr.decode()[:120])
