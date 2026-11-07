#!/usr/bin/env python3
"""Delete the superseded iterations and rebuildable copies, keeping the deliverables."""
import shutil
from pathlib import Path

ROOT = Path('/mnt/e/DSH-Fuxi')
targets = [Path(l) for l in Path('/tmp/cleanup-list.txt').read_text().splitlines() if l.strip()]

# whole directories that are copies of things we can fetch again
for name in ('fts-touch-ci', 'ci', 'third-party', 'oddly-image'):
    p = ROOT / name
    if p.is_dir():
        targets.append(p)

freed = 0
removed = 0
for p in targets:
    try:
        if p.is_file():
            size = p.stat().st_size
            p.unlink()
        elif p.is_dir():
            size = sum(q.stat().st_size for q in p.rglob('*') if q.is_file())
            shutil.rmtree(p)
        else:
            continue
        freed += size
        removed += 1
    except OSError as e:
        print('  跳过 %-40s %s' % (p.name, e))

print('删除 %d 项，释放 %.2f GB' % (removed, freed / 1e9))
