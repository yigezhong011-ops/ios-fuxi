#!/bin/bash
# Make the status bar patch for AdrenoMetal: the block goes on the end of the plugin, so it applies on the branch or an older tree. Nothing is pushed.
set -euo pipefail
A=/root/fuxi/src-adrenometal; S=/mnt/e/DSH-Fuxi/dump/wsl; F=NativeAdrenoMetalPlugin.mm; T=ce63701
W=/root/fuxi/m2v-statusbar; rm -rf $W; mkdir -p $W/a $W/b; cd $W
git -C $A show $T:$F > a/$F
grep -n -E '^#(import|include) <(objc/runtime|objc/message|dispatch/dispatch|dlfcn)' a/$F | cut -c1-70 || true
python3 -I - "$F" "$S/fuxi-statusbar.inc" <<'EOF'
import sys
F, inc = sys.argv[1:]
t = open('a/' + F, newline='').read()
block = open(inc, newline='').read().replace('\r\n', '\n')
head = '#import <Foundation/Foundation.h>\n'
assert t.count(head) == 1
t = t.replace(head, head + '#include <dispatch/dispatch.h>\n#include <objc/runtime.h>\n')
open('b/' + F, 'w', newline='').write(t.rstrip('\n') + '\n' + block)
EOF
diff -u a/$F b/$F > fuxi-statusbar.patch || true
wc -l fuxi-statusbar.patch
# Each older plugin source has the same anchors?
P=/root/fuxi/plugin-try; OLD=$(git -C $P rev-parse --short HEAD)
for r in $T $OLD; do mkdir -p /tmp/chk-$r; git -C $A show $r:$F > /tmp/chk-$r/$F; (cd /tmp/chk-$r && patch -p1 --dry-run < $W/fuxi-statusbar.patch | tail -2 | cut -c1-90; echo "$r readTask $(grep -c 'static bool readTask' $F) writeTask $(grep -c 'static bool writeTask' $F)"); done
which clang++ >/dev/null && echo 'clang here'; ls /root/fuxi/ 2>/dev/null | grep -iE 'sdk|theos' | head -3
