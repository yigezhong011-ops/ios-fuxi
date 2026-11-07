#!/system/bin/sh
# Read-only: the ramoops layout in the TWRP kernel.
for R in /proc/device-tree/reserved-memory/ramoops@0xa7000000 /proc/device-tree/reserved-memory/ramoops_region; do
  echo "== $R"
  for f in $R/*; do
    n=${f##*/}
    case "$n" in
      compatible|name|status|label) echo "$n = $(cat $f | tr '\0' ' ')" ;;
      *) echo "$n = $(xxd -p $f 2>/dev/null | tr -d '\n')" ;;
    esac
  done
done
for p in record_size console_size ftrace_size pmsg_size mem_address mem_size mem_type ecc dump_oops max_ftrace_cnt; do
  [ -e /sys/module/ramoops/parameters/$p ] && echo "param $p = $(cat /sys/module/ramoops/parameters/$p)"
done
dmesg | grep -i -E 'ramoops|pstore|persistent_ram' | head -20
grep -n -i a70 /proc/iomem | head
ls -la /sys/fs/pstore
mount | grep pstore
lsmod | grep -i -E 'ramoops|pstore'
