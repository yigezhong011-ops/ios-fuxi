#!/usr/bin/env python3
"""Point the 0116 generator at the patched base and regenerate."""
import pathlib
import subprocess

gen = pathlib.Path('/mnt/e/DSH-Fuxi/dump/wsl/make-inject-v2.py')
src = gen.read_text()

old = "SRC = pathlib.Path('/mnt/e/DSH-Fuxi/dump/kern_exec-8796.141.3.c')"
new = "SRC = pathlib.Path('/root/fuxi/regenerate/kern_exec.base.c')"
if new in src:
    print('already pointed at the base')
else:
    assert old in src, 'SRC line not found'
    src = src.replace(old, new, 1)
    gen.write_text(src)
    print('generator now reads the patched base')

r = subprocess.run(['python3', str(gen)], capture_output=True, text=True)
print(r.stdout.strip()[:500])
print(r.stderr.strip()[:400])
