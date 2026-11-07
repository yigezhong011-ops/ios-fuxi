#!/bin/bash
# Read-only: how t50's kernel was built, whether the driver source matches, and every table sized for the client count.
E=/mnt/e/DSH-Fuxi; U=$E/unixnu-build
ls -la --time-style=long-iso /root/fuxi/t50 2>&1 | cut -c24-110 | head -14
echo '== scripts naming t50 kernel output'
grep -l -E 'fuxi/t50( |/|$|")' $E/dump/wsl/* 2>/dev/null | head -8
grep -n -E 'build kernel|build-arm-driver|build-kernel|unixnu build' $E/dump/wsl/*t50* $E/*.md 2>/dev/null | cut -c1-170 | head -12
echo '== trees'
for r in unixnu fuxi uefi-fuxi; do echo "-- $r"; git -C $U/$r log --oneline -2 2>&1 | cut -c1-90; git -C $U/$r status --short 2>&1 | head -5 | cut -c1-90; done
ls -la --time-style=long-iso $U/unixnu/out/fuxi/kernel/kernel.macho 2>&1 | cut -c24-120
strings -a /root/fuxi/t50/kernel.macho | grep -m3 -E 'xnu-[0-9]+|Darwin Kernel Version' | cut -c1-120
python3 -I - <<'PY'
import subprocess
s = subprocess.run(['llvm-nm', '/root/fuxi/t50/kernel.macho'], capture_output=True, text=True).stdout
want = ('native_adreno_client_log', 'native_adreno_mount_fail', 'native_adreno_window_overflow', 'native_adreno_client_stats', 'native_adreno_publish')
for l in s.splitlines():
    if any(w in l for w in want): print(l[:110])
PY
echo '== tables and code tied to the client count'
cd $U/unixnu/drivers/Adreno740
grep -n -E 'queueOutstanding|rangeOutstanding|\bqueue_base\b.*\[|Queues\*|MaxQueues\]|\[[0-9]+\]\[[0-9]+\]|hw_ctx|ctx_id|context_id' NativeAdrenoSubmit.h NativeAdrenoSubmit.cpp NativeAdrenoRing.h | cut -c1-160 | head -16
sed -n 160,172p NativeAdrenoUserClient.cpp | cut -c1-170
grep -n -E 'window_overflow|client_stats|client_text|metal_askers|client_log|mount_fail' $U/fuxi/package/BootLog.c | cut -c1-170 | head -16
grep -n -E 'window|va_start|va_size|MaxClient|slot' $U/unixnu/drivers/AdrenoMetal/*.c* $U/unixnu/drivers/AdrenoMetal/*.h 2>/dev/null | cut -c1-170 | head -14
