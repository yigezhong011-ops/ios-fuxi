#!/bin/bash
# Read-only for the phone: Logging preferences from the root image, poster subsystem names, how libsystem_trace uses the key.
cd /mnt/e/DSH-Fuxi/dump/wsl
python3 -I study-subsystem.py 2>&1 | grep -v "^{'__text" | cut -c1-900
which llvm-objdump aarch64-linux-gnu-objdump
I=/mnt/e/DSH-Fuxi/ux-out/fuxi/userdata/userdata-root.img
O=/root/fuxi/logging-prefs; rm -rf $O; mkdir -p $O
ls -la $I | cut -c1-110
7z x -y -bd -o$O "$I" 'System/Library/Preferences/Logging/*' >/dev/null 2>&1; echo "7z rc=$?"
find $O -type f | wc -l
python3 -I - <<'EOF'
import plistlib, glob, os, collections
base = '/root/fuxi/logging-prefs/System/Library/Preferences/Logging'
keys = collections.Counter(); priv = []
for f in glob.glob(base + '/**/*.plist', recursive=True):
    try: d = plistlib.load(open(f, 'rb'))
    except Exception as e: print('bad', f[-40:], e); continue
    if 'Private' in str(d): priv.append(os.path.basename(f))
    for k in d: keys[k] += 1
print(keys.most_common(14)); print('with Private:', priv[:14], len(priv))
print(plistlib.load(open(base + '/Subsystems/com.apple.chrono.plist', 'rb')))
print(sorted(os.listdir(base + '/Subsystems'))[:6], os.listdir(base))
for n in sorted(os.listdir(base + '/Subsystems')):
    if any(k in n.lower() for k in ('poster', 'paperboard', 'wallpaper', 'springboard')): print(n)
if priv:
    print(plistlib.load(open(glob.glob(base + '/**/' + priv[0], recursive=True)[0], 'rb')))
EOF
