#!/usr/bin/env python3
"""Put pwt on the first line of the label branch that actually renders."""
from pathlib import Path

p = Path('/mnt/e/DSH-Fuxi/dump/wsl/fuxi-statusbar.c')
t = p.read_text()
old = '''        int m = 0;
        for (unsigned i = 0; i < 8; i++) {'''
new = '''        int m = 0;
        m += snprintf(text + m, sizeof text - m, "pwt %d set %d | views %lu draws %lu presents %lu commits %lu\\n",
            layerPwt, layerPwtSet, views, draws, presents, commits);
        for (unsigned i = 0; i < 8; i++) {'''
assert old in t, 'branch not found'
t = t.replace(old, new)
p.write_text(t)
print('patched: pwt is the first line of the rendered branch')
