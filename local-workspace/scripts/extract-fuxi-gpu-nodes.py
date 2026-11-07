#!/usr/bin/env python3
"""Do what the port record says is the next action: read fuxi's own device tree
and report the GPU / GMU identity and the SMMU stream it uses."""
import re
import subprocess
from pathlib import Path

DTB = Path('/mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi/Resources/DTBs/fuxi.dtb')
DTS = Path('/root/fuxi/fuxi.dts')
print('DTB %d 字节' % DTB.stat().st_size)

# dtc 反编译成文本，便于按节点看
res = subprocess.run(['dtc', '-I', 'dtb', '-O', 'dts', '-o', str(DTS), str(DTB)],
                     capture_output=True, text=True)
print('dtc 退出码', res.returncode, (res.stderr or '').strip()[:200])
text = DTS.read_text(errors='replace')
print('DTS %d 行' % len(text.splitlines()))

print()
print('=== 与 GPU / GMU / SMMU 相关的节点 ===')
for m in re.finditer(r'^\s*([a-z0-9_@.\-]+)\s*\{', text, re.M):
    name = m.group(1)
    if any(k in name.lower() for k in ('gpu', 'kgsl', 'gmu', 'adreno', 'smmu', 'iommu')):
        start = m.start()
        depth, i = 0, m.end() - 1
        while i < len(text):
            if text[i] == '{':
                depth += 1
            elif text[i] == '}':
                depth -= 1
                if depth == 0:
                    break
            i += 1
        block = text[start:i + 1]
        print('--- 节点 %s （%d 行）' % (name, block.count('\n')))
        for line in block.splitlines()[:18]:
            print('   ', line.strip()[:120])
        print()
