#!/bin/bash
# t50-mine-gpu-fix with blob options, temp boot only. Only the kernel differs from t50-mine-gpu-fix; the proof is printed below.
# Usage: make-t50-gpu-120.sh <out name> <blob defines...>   e.g. -DPANEL_120 and/or -DCLOCK_SECS=$(date +%s)UL
# PANEL_120: "FUXI120" lines in msgbuf and on the USB serial. CLOCK_SECS: the calendar starts at that time.
set -euo pipefail
OUT=$1; shift
E=/mnt/e/DSH-Fuxi; S=$E/dump/wsl; W=/root/fuxi/$OUT
export MTOOLS_SKIP_CHECK=1
rm -rf "$W"; mkdir -p "$W"; cd "$W"
cp /root/fuxi/gpu-new-t50-mine/vol.img vol.img
mcopy -n -i vol.img ::/EFI/UniXNU/Payloads/kernel.macho kernel.old
cmp kernel.old /root/fuxi/t50-mine/kernel.macho
BLOB_DEFS="$* -Os" REPLACE_SINK=1 python3 -I $S/patch-t32-buttons.py /root/fuxi/t50/kernel.macho kernel.macho | grep -E '^blob'
python3 -I $S/fat-inplace.py vol.img ::/EFI/UniXNU/Payloads/kernel.macho kernel.macho >/dev/null
mcopy -n -i vol.img ::/EFI/UniXNU/Payloads/kernel.macho kernel.back; cmp kernel.back kernel.macho
python3 -I - <<'EOF'
import subprocess
old, new = open('kernel.old', 'rb').read(), open('kernel.macho', 'rb').read()
assert len(old) == len(new)
d = [i for i in range(len(old)) if old[i] != new[i]]
s = subprocess.run(['llvm-size', '--format=berkeley', 'kernel.blob.elf'], capture_output=True, text=True).stdout.splitlines()[-1].split()
print('kernel bytes differ', len(d), 'file range', hex(d[0]), hex(d[-1]), '| blob', hex(int(s[0])), 'OVER 0xa23' if int(s[0]) > 0xa23 else 'within 0xa23')
EOF
python3 -I $S/repack-with-vol.py $E/t50-mine.img vol.img $E/$OUT.img >/dev/null
python3 -I $S/compare-loaders.py $E/$OUT.img | tail -1
sha256sum $E/$OUT.img | cut -c1-16
