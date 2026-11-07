#!/sbin/sh
# Runs in TWRP. Read-only: finds crash report headers in the Data area of userdata (16 GiB, 4K blocks from 54282042).
# Each row: <start MiB of chunk>:<byte offset in chunk>:<matched text>
D=/dev/block/by-name/userdata
BASE=$((54282042 / 256))
LEFT=$((54282042 - BASE * 256))
echo "base_mib=$BASE left_blocks=$LEFT"
i=0
while [ $i -lt 16384 ]; do
  dd if=$D bs=1048576 skip=$((BASE + i)) count=65 2>/dev/null | grep -a -b -o -E '\{"(app_name|bug_type)":"[A-Za-z0-9_. -]{1,40}","timestamp":"[0-9: .+-]{10,30}' | sed "s/^/$i:/"
  i=$((i + 64))
done
echo done
