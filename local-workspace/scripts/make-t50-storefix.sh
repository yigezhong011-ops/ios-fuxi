#!/bin/bash
# t50-auto-usbreboot plus: F_SETPROTECTIONCLASS succeeds on this volume, so PosterBoard can create its store. Temp boot only.
set -euo pipefail
S=/mnt/e/DSH-Fuxi/dump/wsl
tr -d '\r' < $S/make-t50-gpu-120.sh > /tmp/g120.sh; tr -d '\r' < $S/make-t50-auto.sh > /tmp/a.sh; tr -d '\r' < $S/make-t50-privlog.sh > /tmp/pl.sh
export FCNTL_PROTECT=1
bash /tmp/g120.sh t50-mine-gpu-storefix -DPANEL_120 -DUSB_REBOOT -DCLOCK_SECS=$(date +%s)UL
unset FCNTL_PROTECT
bash /tmp/pl.sh /root/fuxi/t50-mine-gpu-storefix /root/fuxi/t50-priv-storefix
bash /tmp/a.sh /root/fuxi/t50-priv-storefix 300 t50-auto-storefix
A=$(llvm-nm /root/fuxi/t50/kernel.macho | awk '$3=="_sys_fcntl_nocancel"{print $1}')
echo "=== the patched spot"; llvm-objdump -d --start-address=$(printf '0x%x' $((0x$A + 0xb00))) --stop-address=$(printf '0x%x' $((0x$A + 0xb20))) /root/fuxi/t50-mine-gpu-storefix/kernel.macho | tail -n +7 | cut -c19-60 | grep -c 'mov.*w0, #0x0' || true
python3 -I - <<'EOF'
a = open('/root/fuxi/t50/kernel.macho', 'rb').read(); b = open('/root/fuxi/t50-mine-gpu-usbreboot/kernel.macho', 'rb').read(); c = open('/root/fuxi/t50-mine-gpu-storefix/kernel.macho', 'rb').read()
d = [i for i in range(len(b)) if b[i] != c[i]]
print('differs from usbreboot', len(d), 'bytes:', [hex(i) for i in d][:16])
EOF
sha256sum /mnt/e/DSH-Fuxi/t50-auto-storefix.img | cut -c1-16
