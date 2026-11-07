#!/bin/bash
# Read-only: what reads the boot-arg sched_recommended_cores in t50, and the control run's frame rate.
K=/root/fuxi/t50/kernel.macho
python3 -I - <<'PY'
import struct
k = open('/root/fuxi/t50/kernel.macho','rb').read()
i = k.find(b'sched_recommended_cores\0')
print('string file offset', hex(i))
PY
for s in _sched_update_recommended_cores _sched_perfcontrol_update_recommended_cores; do :; done
llvm-objdump -d --start-address=0xfffffff00b8e3080 --stop-address=0xfffffff00b8e3180 $K 2>/dev/null | tail -n +7 | cut -c1-90 | head -70
echo '--- control fps'
D=$(ls -d /root/fuxi/hang/swipe-load/*/ | head -1)
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/fps-by-id.py > /tmp/fbi.py; python3 -I /tmp/fbi.py "$D" 30 2>&1 | head -30 | cut -c1-150
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/read-swipe.sh > /tmp/rs.sh 2>/dev/null; head -20 /tmp/rs.sh
