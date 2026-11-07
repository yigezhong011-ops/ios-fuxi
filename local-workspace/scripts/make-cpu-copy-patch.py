#!/usr/bin/env python3
"""Patch 0114: force the CPU surface copy (GPU copy leaves inflight stuck)."""
import difflib, re, subprocess, tempfile, pathlib

old = '''int sweet_surface_gpu_copy(SweetSurface *s, uintptr_t src, unsigned sx, unsigned sy,
    unsigned dx, unsigned dy, unsigned width, unsigned height)
{
 if (!fuxi_gpu_ready() || s->pixelFormat != 0x42475241u ||
'''
new = '''int sweet_surface_gpu_copy(SweetSurface *s, uintptr_t src, unsigned sx, unsigned sy,
    unsigned dx, unsigned dy, unsigned width, unsigned height)
{
 /* fuxi: the GPU surface copy never retires sweet_gpu_inflight on this unit, so
  * every following frame returned 2 and was skipped, leaving the panel on stale
  * content. Take the CPU copy; the GPU scanout still moves the frame to the
  * panel. */
 return 0;
 if (!fuxi_gpu_ready() || s->pixelFormat != 0x42475241u ||
'''
assert old != new

diff = list(difflib.unified_diff(
    old.splitlines(keepends=True), new.splitlines(keepends=True),
    fromfile='a/iokit/Kernel/arm/SweetSurface.cpp',
    tofile='b/iokit/Kernel/arm/SweetSurface.cpp', n=3))

BASE = 120
out = [diff[0], diff[1]]
for line in diff[2:]:
    m = re.match(r'@@ -(\d+),(\d+) \+(\d+),(\d+) @@', line)
    if m:
        a, n_old, b, n_new = (int(x) for x in m.groups())
        start = BASE + a - 1
        out.append(f'@@ -{start},{n_old} +{start},{n_new} @@\n')
    else:
        out.append(line)
text = ''.join(out)
pathlib.Path('/root/fuxi/0114-fuxi-cpu-copy.patch').write_bytes(text.encode())
print(text)

work = pathlib.Path(tempfile.mkdtemp())
(work / 'iokit/Kernel/arm').mkdir(parents=True)
(work / 'iokit/Kernel/arm/SweetSurface.cpp').write_text('/* pad */\n' * (BASE - 1) + old + ' /* rest */\n')
r = subprocess.run(['git', 'apply', '--check', '--verbose',
                    '/root/fuxi/0114-fuxi-cpu-copy.patch'],
                   cwd=work, capture_output=True, text=True)
print('=== git apply --check ===')
print('rc =', r.returncode, r.stdout.strip()[:200], r.stderr.strip()[:300])
