#!/usr/bin/env python3
"""Put the presentsWithTransaction readout on the probe label's first line."""
from pathlib import Path

p = Path('/mnt/e/DSH-Fuxi/dump/wsl/fuxi-statusbar.c')
t = p.read_text()
old = 'int n = snprintf(text, sizeof text, "HELLO t%u cls %d view %lu win %lu\\ndrawRect %lu draw %lu needs %lu nilDrawable %lu\\n",'
new = 'int n = snprintf(text, sizeof text, "pwt %d set %d | t%u cls %d view %lu win %lu\\ndrawRect %lu draw %lu needs %lu nilDrawable %lu\\n",'
assert old in t, 'format string not found'
t = t.replace(old, new)
old2 = 'ticks, helloClass != 0, views, windowCount, drawRects, draws, needs, nilDrawables);'
new2 = 'layerPwt, layerPwtSet, ticks, helloClass != 0, views, windowCount, drawRects, draws, needs, nilDrawables);'
assert old2 in t, 'arguments not found'
t = t.replace(old2, new2)
p.write_text(t)
print('patched: pwt is now the first field')
