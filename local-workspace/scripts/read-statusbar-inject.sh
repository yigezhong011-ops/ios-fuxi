#!/bin/bash
# Read only: exec injection in our kernel and sources, the selector names on 21H461, and pong's remaining status bar code.
K=/root/fuxi/t50-gpu7/kernel.macho; V=/root/fuxi/ref-fuxi-v2; U=/root/fuxi/up-latest; P=/mnt/e/DSH-Fuxi/read/pong-iphone
echo '== exec_inject'
strings -n 5 $K | grep -iE 'exec_inject|exec-inject|inject' | cut -c1-110 | head -12
llvm-nm --defined-only $K 2>/dev/null | grep -iE 'exec_inject|sysctl.*inject|_inject' | cut -c1-90 | head -12
git -C $V grep -n -iE 'exec_inject|exec-inject' HEAD -- . | sed 's#^HEAD:##' | cut -c1-200 | head -8
git -C $U grep -n -iE 'exec_inject|exec-inject' origin/main -- . ':!docs/zh' | sed 's#^origin/main:##' | cut -c1-220 | head -14
git -C $U ls-tree --name-only origin/main patches/xnu/ | grep -iE 'inject|exec|dyld' | head
echo; echo '== selectors in the cache'
python3 -I - <<'EOF'
import mmap, re
from pathlib import Path
D = Path('/root/fuxi/sys-peek/dsc')
want = [b'visualProviderSubclassForScreen:visualProviderInfo:', b'_visualProviderClass', b'_setVisualProviderClass:', b'visualProvider', b'requiresIterativeOverflowLayout', b'intrinsicContentSizeForOrientation:', b'nativeBounds', b'nativeScale', b'_UIStatusBarVisualProvider_Phone', b'_prepareVisualProviderIfNeeded', b'setupInContainerView:', b'itemIsEnabled:', b'statusBar:shouldDisplayItem:', b'overriddenStyleAttributes']
found = {}
for f in sorted(D.glob('dyld_shared_cache_arm64*')):
    if f.stat().st_size == 0 or f.name.endswith('.symbols') or 'ResourceFork' in f.name: continue
    with open(f,'rb') as h:
        m = mmap.mmap(h.fileno(), 0, access=mmap.ACCESS_READ)
        for w in want:
            if m.find(b'\0' + w + b'\0') >= 0: found.setdefault(w.decode(), []).append(f.name.split('.')[-1])
for w in want: print(w.decode(), found.get(w.decode(), 'NOT FOUND')[:3])
EOF
echo; echo '== pong code to study'
sed -n 170,188p $P/ui_compat18.c | cut -c1-150
sed -n 284,295p $P/ui_compat18.c | cut -c1-140
echo ...; sed -n 960,1050p $P/ui_compat18.c | cut -c1-140
echo; echo '== pong notes 1195-1222'; sed -n 1195,1224p $P/services.md | cut -c1-240
