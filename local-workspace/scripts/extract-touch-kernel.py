#!/usr/bin/env python3
"""Pull just the kernel out of the big artifact."""
import pathlib
import zipfile

z = zipfile.ZipFile('/root/fuxi-touch-fuxi-touch-kernel.zip')
names = [n for n in z.namelist() if n.endswith('kernel.macho') or n.endswith('kernel.json')]
print('候选:', names[:6])
out = pathlib.Path('/root/fuxi-touch-kernel')
out.mkdir(exist_ok=True)
for n in names:
    if n.endswith('/'):
        continue
    target = out / pathlib.Path(n).name
    with z.open(n) as f, open(target, 'wb') as g:
        while True:
            chunk = f.read(1 << 20)
            if not chunk:
                break
            g.write(chunk)
    print('  %-40s %10d B' % (target.name, target.stat().st_size))
z.close()
