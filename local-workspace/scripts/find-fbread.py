#!/usr/bin/env python3
"""Find how Mesa 25.0.7 decides a draw reads the framebuffer (fb_read)."""
import subprocess

BASE = 'https://gitlab.freedesktop.org/mesa/mesa/-/raw/mesa-25.0.7/'
FILES = [
    'src/gallium/drivers/freedreno/freedreno_batch.h',
    'src/gallium/drivers/freedreno/freedreno_batch.c',
    'src/gallium/drivers/freedreno/a6xx/fd6_texture.c',
    'src/gallium/drivers/freedreno/a6xx/fd6_emit.c',
]

for f in FILES:
    try:
        out = subprocess.run(['curl', '-sL', '--max-time', '60', BASE + f],
                             capture_output=True, text=True, encoding='utf-8', errors='replace').stdout
    except Exception as e:
        print('MISS', f, e)
        continue
    hits = [l.strip() for l in out.splitlines() if 'fb_read' in l]
    if hits:
        print('==', f, len(hits), 'hits')
        for h in hits[:8]:
            print('   ', h[:160])
