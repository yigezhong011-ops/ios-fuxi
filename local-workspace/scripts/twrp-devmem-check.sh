#!/system/bin/sh
# Read-only memory checks in TWRP. The device node lives in /tmp only.
zcat /proc/config.gz | grep -E 'CONFIG_DEVMEM|STRICT_DEVMEM|CONFIG_PSTORE|IO_STRICT_DEVMEM|CONFIG_MODULES='
grep -E ' mem$| 1 ' /proc/devices | head
mknod /tmp/mem c 1 1 && ls -l /tmp/mem
dd if=/tmp/mem of=/tmp/o.bin bs=4096 count=1 skip=$((0x146AA000/4096)) 2>&1 | tail -1
dd if=/tmp/mem of=/tmp/o.bin bs=4096 count=1 skip=$((0xA7601000/4096)) 2>&1 | tail -1
rm -f /tmp/mem /tmp/o.bin
grep -i -E 'imem|sram|reserved|ramoops|mem-dump' /proc/iomem | head -20
grep -E 'System RAM' /proc/iomem | head -12
for d in /proc/device-tree/soc/*imem* /proc/device-tree/soc/*sram* /proc/device-tree/reserved-memory/*ramoops* /proc/device-tree/reserved-memory/*pstore*; do [ -e "$d" ] && echo "$d"; done
ls /sys/fs/pstore /dev/block/by-name 2>/dev/null | grep -E 'pstore|ramoops|logdump|rawdump|minidump|misc$|logfs|frp|splash'
which nc socat python3 lsmod insmod
