#!/bin/bash
# Read-only: how autoreset calls boot_reset_bootloader, and how test images and the blob are built.
K=/root/fuxi/t50/kernel.macho; S=/mnt/e/DSH-Fuxi/dump/wsl
echo "=== writer around the reset calls"; llvm-objdump -d --start-address=0xfffffff00c029860 --stop-address=0xfffffff00c029900 $K 2>/dev/null | tail -n +7 | cut -c19-96
echo "=== boot_reset_bootloader head"; llvm-objdump -d --start-address=0xfffffff00c031b30 --stop-address=0xfffffff00c031b80 $K 2>/dev/null | tail -n +7 | cut -c19-96
echo "=== source"; grep -n 'CONTROL_PE_RESTART_CPU' /root/fuxi/ref-qud/kernel/*.c /root/fuxi/ref-qud/kernel/*.h | cut -c1-120 | head -3
echo "=== make-t50-gpu-120"; tr -d '\r' < $S/make-t50-gpu-120.sh | cut -c1-200
echo "=== make-t50-auto"; tr -d '\r' < $S/make-t50-auto.sh | cut -c1-200 | head -45
echo "=== blob top"; sed -n 1,48p $S/fuxi-buttons-blob.c | tr -d '\r' | cut -c1-170
echo "=== blob entry"; sed -n 207,235p $S/fuxi-buttons-blob.c | tr -d '\r' | cut -c1-140
echo "=== current sizes"; for d in /root/fuxi/t50-mine-gpu-120clock /root/fuxi/t50-mine-gpu-epss /root/fuxi/t50-mine-gpu-fix; do [ -f $d/kernel.blob.elf ] && { llvm-objcopy -O binary $d/kernel.blob.elf /tmp/b.bin; echo "$d $(stat -c %s /tmp/b.bin)"; }; done
