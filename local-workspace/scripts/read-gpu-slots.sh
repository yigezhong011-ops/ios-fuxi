#!/bin/bash
# Read-only: how the 4-slot limit, its windows and bookkeeping compiled in the t50 kernel; whether it is the code the local source describes; firmware build progress.
set -u
K=/root/fuxi/t50/kernel.macho; A=/root/fuxi/t50.dis; N=/tmp/t50-syms.txt
[ -s "$N" ] || llvm-nm --defined-only "$K" > "$N" 2>/dev/null
grep -E '(native_adreno_(client_stats|window_overflow|client_log|mount_fail)|kClientWindows|NativeAdrenoPublish|gPublish|_ZL1g|native_adreno_slot)' "$N" | cut -c1-100 | head -24
grep -E 'mountClient|NativeAdreno[A-Za-z]*(Client|Publish)|newUserClient' "$N" | grep -v -E 'MetaClass|vtable|__ZTV|startup' | cut -c1-110 | head -30
echo '== sources of kClientWindows in the binary'
python3 -I - "$K" <<'PY'
import struct, sys
d = open(sys.argv[1], 'rb').read()
for pat in (struct.pack('<QQ', 0x40000000, 0x10000000), struct.pack('<Q', 0x40000000)):
    print(pat.hex(), d.count(pat))
at = d.find(struct.pack('<QQ', 0x40000000, 0x10000000))
PY
tail -3 /root/fuxi/fw/build-base.log 2>/dev/null | cut -c1-140
