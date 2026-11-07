#!/bin/bash
# t50-daily-usb: the daily image for boot_b. Same kernel, addon and Data as t50-auto-shot, with the USB control channel on and no autoreset, so a fall-through boot can be sent back to fastboot.
set -euo pipefail
export MTOOLS_SKIP_CHECK=1
E=/mnt/e/DSH-Fuxi; S=$E/dump/wsl; B=/root/fuxi/t50-shot; W=/root/fuxi/t50-daily-usb; OUT=$E/t50-daily-usb.img
rm -rf "$W"; mkdir -p "$W"; cd "$W"; cp "$B/vol.img" vol.img
mtype -i vol.img ::/EFI/UniXNU/unixnu.toml > toml.orig
python3 -I - toml.orig toml <<'PY'
import re, sys
old = open(sys.argv[1], 'rb').read(); t = old.decode()
t = t.replace('title = "fuxi first boot: source 4K XNU to console"', 'title = "fuxi"')
m = re.search(r'args = "([^"]*)"', t)
args = [a for a in m.group(1).split() if not a.startswith(('sheng-autoreset=', 'qcom-usb-ctl=', 'boot-ui-focus4='))]
args = ['qcom-usb-ctl=1'] + args
line = ' '.join(args)
new = (t[:m.start()] + 'args = "' + line + '"' + t[m.end():]).encode()
assert len(new) <= len(old) and len(line) < 1020, (len(new), len(old), len(line))
body = new.rstrip(b'\n ')
open(sys.argv[2], 'wb').write(body + b'\n' + b' ' * (len(old) - len(body) - 1))
print('args chars', len(line))
PY
python3 -I $S/fat-inplace.py vol.img ::/EFI/UniXNU/unixnu.toml toml >/dev/null
mtype -i vol.img ::/EFI/UniXNU/unixnu.toml | cmp - toml
for f in kernel.macho kernel.macho.adt kernel.macho.gpuaddon kernel.macho.trustcache; do
  mcopy -n -i vol.img "::/EFI/UniXNU/Payloads/$f" /tmp/d.$f; mcopy -n -i /root/fuxi/auto-t50-auto-shot/vol.img "::/EFI/UniXNU/Payloads/$f" /tmp/s.$f; cmp /tmp/d.$f /tmp/s.$f && echo "same as t50-auto-shot: $f"; rm -f /tmp/d.$f /tmp/s.$f
done
mtype -i vol.img ::/EFI/UniXNU/unixnu.toml | grep -a -o -E 'qcom-usb-ctl=[0-9]|sheng-autoreset=[0-9]+|sheng-data-persist=[0-9]|sheng-setup=[0-9]|offline-legacy-unit-scale=[0-9]' | tr '\n' ' '; echo
rm -f "$OUT"
python3 -I $S/repack-with-vol.py $E/t50-mine.img vol.img "$OUT" >/dev/null
python3 -I $S/compare-loaders.py "$OUT" | tail -1
python3 -I $S/compare-loaders.py $E/t50-mine-gpu-fix.img | tail -1
stat -c '%s %n' "$OUT" $E/t50-mine-gpu-fix.img
sha256sum "$OUT" $E/t50-mine-gpu-fix.img | cut -c1-16
