#!/bin/bash
# t50-mine-gpu-bgra stuck at the Mi logo: only the toml differs. Look at the args limit and a way to set TU_DEBUG without an arg. Read-only.
export MTOOLS_SKIP_CHECK=1
cd /root/fuxi
echo "== longest args among built volumes (name, length)"
for v in */vol.img; do
  n=$(mtype -i "$v" ::/EFI/UniXNU/unixnu.toml 2>/dev/null | grep -a -m1 '^args' | wc -c); echo "$n ${v%/vol.img}"
done | sort -n | tail -12
echo "== plugin: file-based TU_DEBUG at pin"
git -C src-adrenometal show 7e0d3d2:NativeAdrenoMetalPlugin.mm | sed -n '268,299p' | cut -c1-200
echo "== loader strings about args / size limits"
python3 - <<'EOF'
import re, struct, zlib
d = open('/mnt/e/DSH-Fuxi/t50-mine.img','rb').read()
hs, ks = struct.unpack_from('<I', d, 20)[0], struct.unpack_from('<I', d, 8)[0]
s = (hs + 4095) // 4096 * 4096
b = zlib.decompressobj(16 + zlib.MAX_WBITS).decompress(d[s:s + ks])[:3145920]
for m in re.finditer(rb'[ -~]{6,}', b):
    t = m.group().decode()
    if re.search(r'(?i)boot.?arg|command.?line|cmdline|args|too long|BootArgs', t): print('  a', t[:120])
for m in re.finditer(rb'(?:[ -~]\x00){6,}', b):
    t = m.group().decode('utf-16-le')
    if re.search(r'(?i)boot.?arg|command.?line|cmdline|args|too long|toml', t): print('  w', t[:120])
EOF
echo "== BOOT_LINE style text in kernel"
strings -a t50-mine/kernel.macho | grep -i -E 'boot-args|bootargs|boot args' | cut -c1-120 | sort -u | head -12
echo "== boot line appended by the loader, from the last good log"
L=$(ls -t /mnt/e/DSH-Fuxi/logs/gpu-fix-*.log | head -1)
grep -a -m1 -o 'boot-args = .*' "$L" | wc -c
grep -a -m1 -o 'boot-args = .*' "$L" | tail -c 200
