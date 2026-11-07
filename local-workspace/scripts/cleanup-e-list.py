#!/usr/bin/env python3
"""Remove development iterations that are superseded, keeping the current images,
the backups, the deliverables and the iOS 16 root image."""
from pathlib import Path

ROOT = Path('/mnt/e/DSH-Fuxi')
KEEP = {
    # current test images
    'fuxi-touch-boot.img', 'unixnu-quiet.img', 'unixnu-touch.img',
    'unixnu-expert-boot.img', 'fuxi-csfix-quiet.img',
    # backups and deliverables
    'backup', 'backup-gpu-first-light', 'known-good', 'share-2026-10-31',
    'share-2026-10-30', 'fuxi-unixnu-gpu-kernel-2026-10-31.zip',
    'gles-root10-libs.simg', 'tools', 'dump', 'keys', 'gpu-re', 'read',
}
patterns = [
    't32-*.img',            # old iteration images
    'fuxi-*.img',           # except the keeps above
    'unixnu-*.img',         # except the keeps above
    'payload-gpu16.img',
    'kernel-gpu16.macho',
    'working-kernel.macho',
    'fuxi-unixnu-2026-10-30.zip',
    'GPU-FIRST-LIGHT-2026-10-28.zip',
    'ci-fail.zip',
]

targets = []
for pat in patterns:
    for p in ROOT.glob(pat):
        if p.is_file() and p.name not in KEEP:
            targets.append(p)

total = 0
for p in sorted(targets):
    total += p.stat().st_size
    print('  删除 %-40s %7.1f MB' % (p.name, p.stat().st_size / 1e6))

print()
print('共 %d 个文件，可释放 %.2f GB' % (len(targets), total / 1e9))
open('/tmp/cleanup-list.txt', 'w').write('\n'.join(str(p) for p in targets))
