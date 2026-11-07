#!/bin/bash
# Read-only: the candidate's identity properties, its boot args on Data persistence, and how a Data-free boot behaves.
export MTOOLS_SKIP_CHECK=1
E=/mnt/e/DSH-Fuxi; S=$E/dump/wsl; V=/root/fuxi/t50-wall17/vol.img
mcopy -n -i $V ::/EFI/UniXNU/Payloads/kernel.macho.adt /tmp/cand.adt
for n in /device-tree /device-tree/product /device-tree/chosen /device-tree/buttons; do
  echo "== $n"; python3 -I $S/adt-node-props.py $n /tmp/cand.adt | grep -i -E 'model|target-type|compatible|product|artwork|display|island|notch|thin|fallback|home|button|gamut|variant' | cut -c1-120
done
echo "== args"
mtype -i $V ::/EFI/UniXNU/unixnu.toml | grep -a -o -E 'args = "[^"]*"' | tr ' ' '\n' | grep -E 'persist|setup|usb|autoreset|sheng-data|serial|scale|sheng-fb'
echo "== daily args diff"
mtype -i /root/fuxi/gpu-new-t50-mine/vol.img ::/EFI/UniXNU/unixnu.toml | grep -a -o -E 'args = "[^"]*"' | tr ' ' '\n' | grep -E 'persist|setup|usb|autoreset'
echo "== data-persist in tree"
grep -n -r -E 'sheng-data-persist' $E/unixnu-build/fuxi/package $E/unixnu-build/fuxi/board.toml $E/unixnu-build/fuxi/AGENTS.md 2>/dev/null | cut -c1-220 | head -10
grep -n -E 'data-persist|PERSIST' $E/*进度*.md $E/progress-*.md 2>/dev/null | cut -c1-220 | head -12
echo "== make-arg-variant"; cut -c1-180 $S/make-arg-variant.sh | head -40
echo "== 2436"
grep -n -r -E '\b2436\b' $E/read/pong-iphone $E/unixnu-build/unixnu/docs 2>/dev/null | cut -c1-200 | head -8
rm -f /tmp/cand.adt
