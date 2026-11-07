#!/bin/bash
# Read-only: the attribute dictionaries PosterBoardServices hands to createDirectory and the conform check; failure tail; xnu source for the protection calls; t50 symbols.
cd /mnt/e/DSH-Fuxi/dump/wsl; D=/root/fuxi/sys-peek/dsc; K=/root/fuxi/t50/kernel.macho; L=/mnt/e/DSH-Fuxi/logs/carve-wallnew/lscan.txt
echo "== stubs"; python3 -I read-store-build.py $D 1ce0659dc c | grep -v '^{' | cut -c1-90
python3 -I - $D <<'EOF'
import importlib.util, struct, sys
sys.argv = ['x', sys.argv[1]]
spec = importlib.util.spec_from_file_location('c', 'read-dsc-caller-lib.py')
c = importlib.util.module_from_spec(spec); spec.loader.exec_module(c)
d = c.rd(0x1ce0659dc, 8)
a, b = struct.unpack('<II', d)
imm = ((a >> 29) & 3) | (((a >> 5) & 0x7ffff) << 2)
t = (0x1ce0659dc & ~0xfff) + (imm << 12) + ((b >> 10) & 0xfff)
print('create attrs fn', hex(t))
open('/tmp/attrfn.txt', 'w').write(hex(t)[2:])
EOF
F=$(cat /tmp/attrfn.txt)
echo "== around both attr fns (once-init blocks build the dictionaries)"
python3 -I read-store-build.py $D 1a82cda80 180 | grep -v '^{' | cut -c1-120 | grep -E '; |\bret\b|adrp|ldr\s+x[0-9]+, \[x[0-9]+, #' | head -60
echo "== failure tail 0x1ca89f4dc"; python3 -I read-store-build.py $D 1ca89f4dc 60 | grep -v '^{' | cut -c1-100
echo "== xnu sources"
for f in $(find /root/fuxi /root/hakios-xnu-kernel -maxdepth 6 -name kern_descrip.c 2>/dev/null | head -3); do echo $f; grep -n -A14 'case F_SETPROTECTIONCLASS' $f | cut -c1-90 | head -34; done
echo "== t50"; llvm-nm $K | grep -E ' _(fcntl_nocancel|sys_fcntl_nocancel|cp_fs_protected|cp_vnode_transcode|setattrlist|vnode_setattr|vfs_flags|cp_is_valid_class)$' | cut -c1-80
echo "== log: errors with ENOTSUP context"
grep -a -E 'Code=45|Code=256.*(Operation not supported)|Operation not supported\}?' $L | grep -i -E 'NSCocoa|Domain' | sed -E 's/0x[0-9a-f]+/#/g; s/[0-9A-F]{8}-[0-9A-F-]{27}/#/g' | cut -c1-200 | sort | uniq -c | sort -rn | head -12
grep -a 'Operation not supported' $L | sed -E 's/0x[0-9a-f]+/#/g; s/[0-9A-F]{8}-[0-9A-F-]{27}/#/g; s/[0-9]+/N/g' | cut -c1-110 | sort | uniq -c | sort -rn | head -14
