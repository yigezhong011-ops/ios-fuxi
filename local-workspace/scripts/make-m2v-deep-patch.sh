#!/bin/bash
# Build a patch for AdrenoMetal ce63701: bring back reportDisplayState from our earlier plugin, which clears the display's deep flag on the 21H461 cache.
# Upstream removed it (the addresses are 21H461's); without it the compositor draws two-plane b3a8 frames, which our kernel's display refuses.
set -euo pipefail
A=/root/fuxi/src-adrenometal; T=ce63701; P=/root/fuxi/plugin-try; OLD=$(git -C $P rev-parse --short HEAD); F=NativeAdrenoMetalPlugin.mm
W=/root/fuxi/m2v-deep; rm -rf $W; mkdir -p $W/a $W/b; cd $W
git -C $A show $OLD:$F > old.mm; git -C $A show $T:$F > a/$F
echo '== old call sites'; grep -n -B3 -A3 'reportDisplayState(' old.mm | grep -v 'static void reportDisplayState' | cut -c1-150
echo '== new: helpers'; grep -n -E 'static bool (read|write)Task|struct Gpu|class Gpu|void mark\(' a/$F | cut -c1-120
python3 -I - "$F" <<'EOF'
import re, sys
F = sys.argv[1]
old = open('old.mm').read(); new = open('a/' + F).read()
s = old.index('static unsigned gReports;'); e = old.index('// Every process other than the render server')
block = old[s:e]
assert 'static void reportDisplayState(Gpu &gpu)' in block and 'f &= ~8u' in block
anchor = '// Every process other than the render server'
assert new.count(anchor) == 1 and 'reportDisplayState' not in new
new = new.replace(anchor, block + anchor)
# The branch removed the ten-second monitor thread that called it. Only this call comes back, on a thread of its own.
mark = '        gpu->mark(0x6802);\n'
assert new.count(mark) == 1
thread = mark + '''        pthread_t displayState;
        if (pthread_create(&displayState, nullptr, [](void *arg) -> void * {
            Gpu *g = static_cast<Gpu *>(arg);
            for (;;) {
                sleep(10);
                reportDisplayState(*g);
            }
            return nullptr;
        }, gpu) == 0) pthread_detach(displayState);
'''
new = new.replace(mark, thread)
open('b/' + F, 'w').write(new)
EOF
diff -u a/$F b/$F > adrenometal-21h461-display-state.patch || true
wc -l adrenometal-21h461-display-state.patch; grep -nE '^\+.*reportDisplayState' adrenometal-21h461-display-state.patch | cut -c1-110
grep -n 'Gpu' a/$F | head -4 | cut -c1-120
grep -c 'bootArgSet\|sampleDisplay' b/$F
