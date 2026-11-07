#!/bin/bash
# Read-only: wait_drained, the autoreset caller of boot_reset_bootloader, and the blob inside the wall17 kernel compared with t50-usbreboot's.
set -u
A=/root/fuxi/t50.dis
r() { awk -v a="$1" -v b="$2" '{k=substr($1,1,16)} k>=a && k<=b' "$A" | cut -c1-100; }
echo '== wait_drained'; awk 'index($0,"<_qcom_usb_debug_wait_drained>:"){p=1} p{print; c++} p&&c>1&&/^$/{exit} c>48{exit}' "$A" | cut -c1-100
echo '== autoreset around bl boot_reset_bootloader'; r fffffff00c0298a0 fffffff00c029920
echo '== does boot_reset_bootloader reset itself'; awk 'index($0,"<_boot_reset_bootloader>:"){p=1} p&&/smc|hvc|ret$/{print} p&&/<_[a-zA-Z_]*>:/&&!index($0,"boot_reset_bootloader"){exit}' "$A" | cut -c1-80 | head
for k in /root/fuxi/t50-wall17/kernel.macho /root/fuxi/t50-mine-gpu-usbreboot/kernel.macho /root/fuxi/t50-mine/kernel.macho; do
  [ -f "$k" ] || { echo "missing $k"; continue; }
  echo "== $k $(stat -c%s "$k")"
  llvm-objdump -d --no-show-raw-insn --start-address=0xfffffff00bd0d95c --stop-address=0xfffffff00bd0d968 "$k" | tail -3 | cut -c1-90
  llvm-objdump -d --no-show-raw-insn --start-address=0xfffffff00b8a3228 --stop-address=0xfffffff00b8a3234 "$k" | tail -3 | cut -c1-90
done
echo '== kernels differing from usbreboot'; python3 -I - <<'PY'
a=open('/root/fuxi/t50-wall17/kernel.macho','rb').read(); b=open('/root/fuxi/t50-mine-gpu-usbreboot/kernel.macho','rb').read()
print(len(a),len(b))
i=0; runs=[]
while i<min(len(a),len(b)):
    if a[i]!=b[i]:
        j=i
        while j<len(a) and j<len(b) and j-i<4096 and (a[j]!=b[j] or a[j:j+16]!=b[j:j+16]): j+=1
        runs.append((hex(i),j-i)); i=j
    else: i+=1
print(len(runs),runs[:30])
PY
llvm-objdump -d --no-show-raw-insn /root/fuxi/t50-mine-gpu-usbreboot/kernel.blob.elf | awk '/<reboot_hook>:/{p=1} p{print} p&&/^$/{exit}' | cut -c1-80
ls -la /root/fuxi/t50-wall17 | cut -c24- | head -25
