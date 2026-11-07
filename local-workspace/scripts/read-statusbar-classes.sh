#!/bin/bash
# Read only: pong's insertion and provider choice, and the status bar classes in our 21H461 cache.
P=/mnt/e/DSH-Fuxi/read/pong-iphone/ui_compat18.c; I=/mnt/e/DSH-Fuxi/read/pong-iphone/init.c; D=/root/fuxi/sys-peek/dsc
echo '== pong init 392-443'; sed -n 392,443p $I | cut -c1-150
echo; echo '== pong provider choice'; sed -n 328,372p $P | cut -c1-150
echo; echo '== pong SystemStatusUI 922-960'; sed -n 922,960p $P | cut -c1-150
echo; echo '== cache identity'; ls $D | wc -l; du -sh $D | cut -f1; ls /root/fuxi/sys-peek | head -12
python3 -I - <<'EOF'
import mmap, re
from pathlib import Path
D = Path('/root/fuxi/sys-peek/dsc')
pat = re.compile(rb'(_UIStatusBarVisualProvider[A-Za-z0-9_]{0,40}|STUIStatusBar[A-Za-z0-9_]{0,30}VisualProvider[A-Za-z0-9_]*|STUIStatusBarVisualProvider[A-Za-z0-9_]*|_UIStatusBarFallbackItem|_UIStatusBarGetVisualProviderClassForScreen|visualProviderClassForScreen:[a-zA-Z:]*|_prepareVisualProviderIfNeeded|resetVisualProvider|referenceScreenScale|scalesWithScreenNativeScale|_UIStatusBarVisualProviderFactory|_UIStatusBarScreenInfo)\x00')
seen = {}
for f in sorted(D.glob('dyld_shared_cache_arm64*')):
    if f.stat().st_size == 0 or f.name.endswith(('.symbols',)) or 'ResourceFork' in f.name: continue
    with open(f,'rb') as h:
        m = mmap.mmap(h.fileno(), 0, access=mmap.ACCESS_READ)
        for x in pat.finditer(m):
            seen.setdefault(x.group(1).decode(), set()).add(f.name.split('.')[-1])
for k in sorted(seen): print(k, sorted(seen[k])[:3])
print('count', len(seen))
EOF
