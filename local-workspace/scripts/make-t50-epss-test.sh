#!/bin/bash
# Raw EPSS state of the three CPU frequency domains, same recipe as t50-auto-load: only the blob differs. Read only. Temp boot only.
set -euo pipefail
S=/mnt/e/DSH-Fuxi/dump/wsl
tr -d '\r' < $S/make-t50-gpu-120.sh > /tmp/g120.sh; tr -d '\r' < $S/make-t50-auto.sh > /tmp/a.sh; tr -d '\r' < $S/make-t50-privlog.sh > /tmp/pl.sh
bash /tmp/g120.sh t50-mine-gpu-epss -DPANEL_120 -DCPU_EPSS -DCLOCK_SECS=$(date +%s)UL
bash /tmp/pl.sh /root/fuxi/t50-mine-gpu-epss /root/fuxi/t50-priv-epss
bash /tmp/a.sh /root/fuxi/t50-priv-epss 300 t50-auto-epss
E=/root/fuxi/t50-mine-gpu-epss/kernel.blob.elf
echo "=== blob size (limit 0xa23)"
llvm-size -A "$E" | grep -E '\.text|Total'
python3 -I - "$E" <<'PY'
import subprocess, sys
o = subprocess.run(['llvm-objcopy', '-O', 'binary', sys.argv[1], '/tmp/epss-blob.bin'])
import os
print('binary bytes', hex(os.path.getsize('/tmp/epss-blob.bin')))
PY
echo "=== writes to EPSS: none expected in p_epss"
llvm-objdump -d "$E" | awk '/<p_epss>:/{p=1} p&&/^$/{p=0} p' | grep -E '\bstr[bh]?\b' | grep -v 'sp' | cut -c1-90 | head
sha256sum /mnt/e/DSH-Fuxi/t50-auto-epss.img | cut -c1-16
