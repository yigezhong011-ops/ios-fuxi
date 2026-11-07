#!/bin/bash
# The CPU probe on top of what t50-auto-120clock-p already proved: only the blob's CPU_PROBE differs. Temp boot only.
set -euo pipefail
S=/mnt/e/DSH-Fuxi/dump/wsl
tr -d '\r' < $S/make-t50-gpu-120.sh > /tmp/g120.sh; tr -d '\r' < $S/make-t50-auto.sh > /tmp/a.sh; tr -d '\r' < $S/make-t50-privlog.sh > /tmp/pl.sh
bash /tmp/g120.sh t50-mine-gpu-120clockcpu -DPANEL_120 -DCPU_PROBE -DCLOCK_SECS=$(date +%s)UL
bash /tmp/pl.sh /root/fuxi/t50-mine-gpu-120clockcpu /root/fuxi/t50-priv-120clockcpu
bash /tmp/a.sh /root/fuxi/t50-priv-120clockcpu 200 t50-auto-cpu2
cd /root/fuxi
export MTOOLS_SKIP_CHECK=1
echo "=== toml same as the proved image except the autoreset seconds?"
diff <(mtype -i auto-t50-auto-120clock-p/vol.img ::/EFI/UniXNU/unixnu.toml) <(mtype -i auto-t50-auto-cpu2/vol.img ::/EFI/UniXNU/unixnu.toml) | cut -c1-60 | head -4
cmp <(mtype -i auto-t50-auto-120clock-p/vol.img ::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon) <(mtype -i auto-t50-auto-cpu2/vol.img ::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon) && echo addon same
cmp <(mtype -i auto-t50-auto-120clock-p/vol.img ::/EFI/UniXNU/Payloads/kernel.macho.adt) <(mtype -i auto-t50-auto-cpu2/vol.img ::/EFI/UniXNU/Payloads/kernel.macho.adt) && echo adt same
mcopy -n -i auto-t50-auto-120clock-p/vol.img ::/EFI/UniXNU/Payloads/kernel.macho /tmp/k1; mcopy -n -i auto-t50-auto-cpu2/vol.img ::/EFI/UniXNU/Payloads/kernel.macho /tmp/k2
python3 -I - <<'PY'
a,b=open('/tmp/k1','rb').read(),open('/tmp/k2','rb').read()
d=[i for i in range(len(a)) if a[i]!=b[i]]
print('kernel size same',len(a)==len(b),'diff',len(d),hex(d[0]),hex(d[-1]))
PY
rm -f /tmp/k1 /tmp/k2