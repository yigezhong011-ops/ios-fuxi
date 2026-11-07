#!/bin/bash
# Read-only for the phone and the image: copy the Logging preferences out of the system image to read their format, and disassemble what libsystem_trace does with the key.
set -u
O=/root/fuxi/logging-prefs; rm -rf $O; mkdir -p $O
cd $O
7z x -y -bd -o$O /mnt/e/DSH-Fuxi/dump/root-peek/systemos.img 'System/Library/Preferences/Logging/*' >/dev/null 2>&1; echo "7z rc=$?"
find $O -type f | wc -l; du -sh $O | cut -f1
pip3 list 2>/dev/null | grep -i -E 'capstone'
python3 -I - <<'EOF'
import plistlib, glob, os, collections
base = '/root/fuxi/logging-prefs/System/Library/Preferences/Logging'
keys = collections.Counter(); priv = []
for f in glob.glob(base + '/**/*.plist', recursive=True):
    try: d = plistlib.load(open(f, 'rb'))
    except Exception as e: print('bad', f[-40:], e); continue
    s = str(d)
    if 'Private' in s: priv.append(os.path.basename(f))
    for k in d: keys[k] += 1
print(keys.most_common(14)); print('with Private:', priv[:14], len(priv))
p = base + '/Subsystems/com.apple.chrono.plist'
print(plistlib.load(open(p, 'rb')))
for n in ('com.apple.PosterKit', 'com.apple.PosterBoard', 'com.apple.posterboard', 'com.apple.WallpaperKit'):
    print(n, os.path.exists(f'{base}/Subsystems/{n}.plist'))
print(os.listdir(base)[:12])
if priv:
    print(plistlib.load(open(glob.glob(base + '/**/' + priv[0], recursive=True)[0], 'rb')))
EOF
grep -n -E 'com\.apple\.[A-Za-z]*[Pp]oster' /mnt/e/DSH-Fuxi/dump/root-peek/list.txt | grep Logging | cut -c1-140 | head
