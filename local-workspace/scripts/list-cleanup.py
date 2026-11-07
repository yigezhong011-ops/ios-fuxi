#!/usr/bin/env python3
"""List E: DS H-Fuxi images and classify them against the cleanup list."""
import fnmatch
from pathlib import Path

ROOT = Path('/mnt/e/DSH-Fuxi')

KEEP_EXACT = {
    't50-mine-gpu-fix.img', 't50-mine.img', 't50-mine-gpu-log.img',
    't50-mine-gpu-migrate.img', 't50-mine-gpu-apps.img',
    't50-subtype2556-nodiag.img',
    't36-bl2.img', 't36-bl2-gpu-fix.img',
    't36-setup0.img', 't36-phone-cache-miss.img',
    't32-bl-daily.img', 't32-gpu6.img',
}
CAND_PATTERNS = [
    't36-usb*', 't36-fd*', 't36-bl2-usb*', 't36-usbdiag*', 't36-usbcpu0*',
    't32-wall*', 't32-usb.img', 't32-buttons-daily2.img', 't32-bl1.img',
    't50-mine-gpu-bgra.img', 't50-mine-gpu-fix1.img', 't36-bl2-gpu-fix1.img',
]

imgs = sorted(ROOT.glob('*.img'))
keep, cand, unknown = [], [], []
for p in imgs:
    name = p.name
    size = p.stat().st_size
    if name in KEEP_EXACT:
        keep.append((name, size))
    elif any(fnmatch.fnmatch(name, pat) for pat in CAND_PATTERNS):
        cand.append((name, size))
    else:
        unknown.append((name, size))

def show(title, rows):
    total = sum(s for _, s in rows)
    print('\n=== %s（%d 个，%.2f GB）===' % (title, len(rows), total / 2**30))
    for n, s in sorted(rows):
        print('  %-34s %7.1f MB' % (n, s / 2**20))

show('保留', keep)
show('清单点名的可清候选', cand)
show('清单没点名，先不动（列出待你确认）', unknown)

print('\n=== 其他候选 ===')
for rel in ('待删除',):
    d = ROOT / rel
    if d.is_dir():
        total = sum(f.stat().st_size for f in d.rglob('*') if f.is_file())
        n = sum(1 for f in d.rglob('*') if f.is_file())
        print('  %-34s %7.1f MB（%d 个文件，由用户自己删）' % (rel + '/', total / 2**20, n))
