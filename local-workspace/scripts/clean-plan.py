#!/usr/bin/env python3
"""Dry run for the agreed WSL cleanup: classify every candidate and write the delete list. Deletes nothing. Output: /root/clean-delete.txt, /root/clean-keep.txt"""
import os
import re
import subprocess
import time
from pathlib import Path

ROOT, F = Path('/root'), Path('/root/fuxi')
S = Path('/mnt/e/DSH-Fuxi/dump/wsl')
SINCE = time.time() - 3 * 86400


def run(*a, cwd=None):
    return subprocess.run(a, cwd=cwd, capture_output=True, text=True, errors='replace').stdout


def size(p):
    return int(run('du', '-xsm', str(p)).split()[0] or 0)


# Directories that recent scripts and handoff notes name.
refs = set()
sources = [p for p in S.iterdir() if p.is_file() and p.stat().st_mtime > SINCE and p.suffix in ('.sh', '.py', '.ps1')]
sources += [p for p in Path('/mnt/e/DSH-Fuxi').glob('*.md')] + [p for p in Path('/mnt/e/DSH-Fuxi/ci').rglob('*') if p.is_file() and p.stat().st_size < 2000000]
for p in sources:
    if p.name.startswith('clean-'):
        continue
    t = p.read_text(errors='replace')
    refs |= set(re.findall(r'/root/fuxi/([A-Za-z0-9_.+-]+)', t))
    refs |= {'/root/' + x for x in re.findall(r'/root/([A-Za-z0-9_.+-]+)', t)}

# Directories any live process holds.
busy = set()
for pid in filter(str.isdigit, os.listdir('/proc')):
    try:
        for link in [f'/proc/{pid}/cwd'] + [f'/proc/{pid}/fd/{x}' for x in os.listdir(f'/proc/{pid}/fd')]:
            t = os.readlink(link)
            if t.startswith('/root/'):
                busy.add(t)
    except OSError:
        pass
    try:
        for a in open(f'/proc/{pid}/cmdline').read().split('\0'):
            if a.startswith('/root/'):
                busy.add(a)
    except OSError:
        pass
print('busy paths', sorted(busy)[:12])


def git_state(p):
    """Unpushed or uncommitted work under p, as text, or ''."""
    notes = []
    for g in run('find', str(p), '-xdev', '-maxdepth', '4', '-name', '.git').split():
        r = str(Path(g).parent)
        dirty = len(run('git', '-C', r, 'status', '--porcelain', '--untracked-files=no').splitlines())
        ahead = run('git', '-C', r, 'log', '--oneline', '--branches', '--not', '--remotes').splitlines()
        if dirty or ahead:
            notes.append(f'{r}: modified {dirty}, unpushed {len(ahead)}')
    return '; '.join(notes)


KEEP_NAMES = {'t36', 't36-bl2', 't50', 't50-mine', 't50-gpu-wall', 't50-gpu-apps', 't50-gpu-migrate', 't50-gpu-bgra', 'gpu-new-t50-mine', 'gpu-new-t36-bl2', 'gpu-log', 'ios-fuxi', 'unixnu', 'cat-test', 'wall1'}
delete, keep = [], []


def isbusy(p):
    return any(b == str(p) or b.startswith(str(p) + '/') for b in busy)


for name in ('hakios-xnu-kernel', 'uefi-hak-fuxi', 'uefi-odd', 'build', 'fuxi-touch-kernel'):
    p = ROOT / name
    if not p.is_dir():
        continue
    n = git_state(p)
    why = 'in use' if isbusy(p) else f'unpushed: {n}' if n else 'named by a recent script' if '/root/' + name in refs else ''
    (keep if why else delete).append((size(p), str(p), why or 'tier 1'))

for p in sorted(x for x in F.iterdir() if x.is_dir() and not x.is_symlink()):
    n = p.name
    if n == 't32':
        keep.append((size(p), str(p), 'handled by file: keep verified kernel'))
        continue
    why = ''
    if n in KEEP_NAMES:
        why = 'agreed keep'
    elif n.startswith(('src-', 'ref-', 'log-oslog', 'carve-')):
        why = 'source or current log'
    elif isbusy(p):
        why = 'in use'
    elif n in refs:
        why = 'named by a recent script or note'
    else:
        g = git_state(p)
        if g:
            why = f'unpushed: {g}'
        elif (p / '.git').exists():
            why = 'git repository'
    (keep if why else delete).append((size(p), str(p), why or 'tier 2'))

Path('/root/clean-delete.txt').write_text(''.join(f'{p}\n' for _, p, _ in delete))
Path('/root/clean-keep.txt').write_text(''.join(f'{s}\t{p}\t{w}\n' for s, p, w in sorted(keep, reverse=True)))
print('delete', len(delete), sum(s for s, _, _ in delete), 'MiB')
print('keep', len(keep), sum(s for s, _, _ in keep), 'MiB')
for s, p, w in sorted(keep, reverse=True)[:60]:
    print(f'K {s:6d} {p.replace("/root/", "")[:34]:34s} {w[:90]}')
print('-- largest deletions')
for s, p, w in sorted(delete, reverse=True)[:40]:
    print(f'D {s:6d} {p.replace("/root/", "")}')
print('-- t32 contents')
print(run('du', '-xsm', *[str(x) for x in sorted((F / 't32').iterdir())[:40]])[:1600])
