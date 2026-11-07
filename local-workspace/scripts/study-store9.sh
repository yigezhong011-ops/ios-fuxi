#!/bin/bash
# Read-only: which attributes does the store demand (resolve the GOT constants), and how far did migration get in the log.
cd /mnt/e/DSH-Fuxi/dump/wsl; D=/root/fuxi/sys-peek/dsc; L=/mnt/e/DSH-Fuxi/logs/carve-wallnew/lscan.txt
python3 -I - $D <<'EOF'
import importlib.util, struct, sys
sys.argv = ['x', sys.argv[1]]
spec = importlib.util.spec_from_file_location('c', 'read-dsc-caller-lib.py')
c = importlib.util.module_from_spec(spec); spec.loader.exec_module(c)
def cf(got):
    raw = c.rd(got, 8)
    p = struct.unpack('<Q', raw)[0]
    for t in (p & 0xfffffffff, (p & 0xffffffff) + 0x180000000, (p & 0xfffffffff) + 0x180000000):
        d = c.rd(t, 32)
        if not d: continue
        for off in (16,):
            q = struct.unpack_from('<Q', d, off)[0]
            for s in (q & 0xfffffffff, (q & 0xffffffff) + 0x180000000, (q & 0xfffffffff) + 0x180000000):
                x = c.cstr(s)
                if x: return x
    return hex(p)
for g in (0x1f350cfe0, 0x1f350cfe8, 0x1f350d020, 0x1f350d3a8):
    print(hex(g), cf(g))
print('stub 0x1ce0659e8', c.rd(0x1ce0659e8, 12).hex())
EOF
echo "=== function behind 0x1ce0659e8 by image"; python3 -I read-store-build.py $D 1ce0659e0 20 | grep -v '^{' | cut -c1-100
echo "=== log"
for p in 'Kicking off 61' 'Kicking off 60' 'Beginning migration to Version' 'Success updating file attributes' 'No data store @' 'error updating to 61' 'Begin attribute migration' 'needsFileProtectionsMigration' 'pre fixing file protection' 'post fixing file protection' 'failed to correct file protection' 'Unable to fix file protections' 'Setting up poster configurations' 'Failed to update resource' 'Error setting' 'FixupResourceValues' 'Operation not supported' ; do printf '%-40s %s\n' "$p" "$(grep -a -c -- "$p" $L)"; done
grep -a -E 'NSURLFileProtection|NSFileProtection' $L | cut -c1-200 | sed -E 's/[0-9A-F]{8}-[0-9A-F-]{27}/#/g' | sort | uniq -c | sort -rn | head -12
echo "=== strings about reachable/conform"
python3 -I read-store-strings.py $D 'conform|not reachable|attributes|URLsNot|Fixup' 2>&1 | grep -v '^{' | grep -- '<- 0x' | cut -c1-170 | head -16
