#!/bin/bash
# t50-auto-load with the scheduler kept off the three A510s: sched_recommended_cores=0xf8 (cpu3-7). Only the args differ. Temp boot only.
set -euo pipefail
S=/mnt/e/DSH-Fuxi/dump/wsl; E=/mnt/e/DSH-Fuxi
tr -d '\r' < $S/make-t50-auto.sh > /tmp/a.sh
EXTRA_ARGS='sched_recommended_cores=0xf8' bash /tmp/a.sh /root/fuxi/t50-priv-load 300 t50-auto-load-big
export MTOOLS_SKIP_CHECK=1
mtype -i /root/fuxi/auto-t50-auto-load-big/vol.img ::/EFI/UniXNU/unixnu.toml | grep -a -m1 '^args' | cut -c1-140
