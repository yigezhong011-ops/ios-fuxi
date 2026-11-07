#!/usr/bin/env python3
# Read-only: which process took the SIGTRAP, and whether Settings' own exit reached the saved log.
import hashlib, re
def blocks(p):
    b = open(p, 'rb').read()
    m = list(re.finditer(rb'(?m)^#C (\d+) (\d+)\n', b))
    for i, x in enumerate(m):
        yield int(x.group(1)), b[x.end():m[i + 1].start() if i + 1 < len(m) else len(b)]
old = {hashlib.sha1(c).digest() for _, c in blocks('/mnt/e/DSH-Fuxi/logs/carve-wall17/lscan.txt')}
new = [(o, c) for o, c in blocks('/mnt/e/DSH-Fuxi/logs/carve-wallsettings/lscan.txt') if hashlib.sha1(c).digest() not in old]
t = b'\n'.join(c for o, c in sorted(new)).decode('latin1')
L = [''.join(ch if 32 <= ord(ch) < 127 else '.' for ch in l) for l in t.split('\n')]
for pat, before, after in ((r'exited due to SIGTRAP', 7, 3), (r'exited due to SIGSEGV|exited due to SIGBUS|EXC_BAD', 7, 3), (r'UIKitApplication:com\.apple\.Preferences.*(exit|crash)|Preferences.*(terminat|crash|exited)', 4, 3), (r'(?i)wallpaper.*(settings|WallpaperSettings)|WallpaperSettings|com\.apple\.Wallpaper-Settings', 3, 3)):
    idx = [i for i, l in enumerate(L) if re.search(pat, l)]
    print('==', pat, len(idx))
    last = -10000; k = 0
    for i in idx:
        if i - last < 400: continue
        last = i; k += 1
        if k > 4: break
        for x in L[max(0, i - before):i + after]: print('  ', x[:200])
        print('  --')
