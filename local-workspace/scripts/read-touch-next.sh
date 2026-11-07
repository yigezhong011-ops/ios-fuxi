#!/bin/bash
# Read-only: what the fence and submit statistics are, how TouchProbe fills its slots, and how the USB control parser handles a verb.
R=/root/fuxi/ref-qcomxnuusbdebug; S=/mnt/e/DSH-Fuxi/unixnu-build; D=/root/fuxi/t50.dis; N=/tmp/t50-syms.txt; K=/root/fuxi/t50/kernel.macho
[ -s "$N" ] || llvm-nm --defined-only "$K" > "$N" 2>/dev/null
echo '== stat symbols'; grep -E 'native_adreno_(fence_wait|submit_ibs)|native_touch_' "$N" | sort | cut -c1-80
echo '== stat source'; grep -rn -E 'native_adreno_fence_wait|native_adreno_submit_ibs|native_touch_hid_reports' "$S/fuxi" "$S/unixnu/drivers" --include='*.cpp' --include='*.h' --include='*.c' --include='*.hpp' --include='*.mm' 2>/dev/null | cut -c1-170 | head -24
echo '== publish'; F="$S/fuxi/package/TouchProbe.cpp"; L=$(grep -n 'publish(' "$F" | head -1 | cut -d: -f1); sed -n "$L,$((L+32))p" "$F" | cut -c1-120
echo '== control source'; C=$(grep -rl sxnu_control_reply_start "$R" --include='*.c' --include='*.h' --include='*.inc' --include='*.patch' | head -5); echo "$C"
for f in $C; do grep -n -E 'SCREENSHOT|SHOTNEXT|"REBOOT|"PING"|"STATUS"|sxnu_control_[a-z_]+\(|strncmp|memcmp|verb' "$f" | cut -c1-120 | head -50; done
echo '== size of the unnamed range, and which symbols precede the parser'
awk '$1>="fffffff00c06e80c" && $1<="fffffff00c06faac"' "$N" | sort | cut -c1-70
