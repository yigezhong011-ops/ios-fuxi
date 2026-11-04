#!/bin/bash
# t50-mine-gpu-apps with one data migration forced, so SystemAppMigrator installs the staged apps already copied into Data.
# The kernel's sheng-setup=1 path unlinks two preference files. Their two path strings are changed in place to
# com.apple.migration.plist, whose LastSystemVersion is what skips the migration, and the argument becomes sheng-setup=1.
# Setup's own flags stay. Temporary boot only: this image deletes the file on every boot it is used for.
set -euo pipefail
export MTOOLS_SKIP_CHECK=1
E=/mnt/e/DSH-Fuxi; W=/root/fuxi/t50-gpu-migrate
rm -rf "$W"; mkdir -p "$W"
cp /root/fuxi/t50-gpu-apps/vol.img "$W/vol.img"
mcopy -n -i "$W/vol.img" ::/EFI/UniXNU/Payloads/kernel.macho "$W/kernel.orig"
python3 -I - "$W/kernel.orig" "$W/kernel.macho" <<'EOF'
import sys
d = bytearray(open(sys.argv[1], 'rb').read())
P = b'/private/var/mobile/Library/Preferences/'
new = P + b'com.apple.migration.plist\0'
for name in (b'com.apple.purplebuddy.plist', b'com.apple.purplebuddy.notbackedup.plist'):
    s = b'\0' + P + name + b'\0'
    hits = []
    at = d.find(s)
    while at >= 0:
        hits.append(at + 1)
        at = d.find(s, at + 1)
    print(name.decode(), 'hits', [hex(x) for x in hits])
    assert len(hits) == 1, 'path string must be unique'
    old_len = len(P) + len(name) + 1
    assert len(new) <= old_len
    d[hits[0]:hits[0] + old_len] = new + b'\0' * (old_len - len(new))
open(sys.argv[2], 'wb').write(d)
print('kernel bytes', len(d))
EOF
mtype -i "$W/vol.img" ::/EFI/UniXNU/unixnu.toml > "$W/toml.orig"
python3 -I - "$W/toml.orig" "$W/toml" <<'EOF'
import sys
t = open(sys.argv[1], encoding='utf-8', newline='').read()
assert t.count('sheng-setup=0') == 1 and 'sheng-staged-apps=1' in t
open(sys.argv[2], 'w', encoding='utf-8', newline='').write(t.replace('sheng-setup=0', 'sheng-setup=1'))
EOF
python3 -I $E/dump/wsl/fat-inplace.py "$W/vol.img" ::/EFI/UniXNU/unixnu.toml "$W/toml"
python3 -I $E/dump/wsl/fat-inplace.py "$W/vol.img" ::/EFI/UniXNU/Payloads/kernel.macho "$W/kernel.macho"
mtype -i "$W/vol.img" ::/EFI/UniXNU/unixnu.toml | cmp - "$W/toml"
mcopy -n -i "$W/vol.img" ::/EFI/UniXNU/Payloads/kernel.macho "$W/kernel.back"; cmp "$W/kernel.back" "$W/kernel.macho"
python3 -I $E/dump/wsl/repack-with-vol.py $E/t50-mine.img "$W/vol.img" $E/t50-mine-gpu-migrate.img
python3 -I $E/dump/wsl/compare-loaders.py $E/t50-mine-gpu-migrate.img
cmp -l "$W/kernel.orig" "$W/kernel.macho" | wc -l
sha256sum $E/t50-mine-gpu-migrate.img | cut -c1-16
