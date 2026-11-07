#!/bin/bash
# What does the export region hold, per boot header, and does the addon carry the log writer? Read-only.
for n in log-gpufix log-gpu2 log-gpu3; do
  L=$(ls -d /root/fuxi/$n/*/ | head -1); echo "== $n"
  grep -E '^(version|boot_id|first_lba|window_blocks|uptime_s|state|export_|crash)' "$L/header.txt" | tr '\n' ' '; echo
done
echo "== header layout past the export fields, gpu3"
python3 - <<'EOF'
import glob,struct
b=open('/mnt/e/DSH-Fuxi/logs/twrp-gpu3.bin','rb').read()[:400]
print(b[:8], [hex(x) for x in struct.unpack_from('<40I',b,8)])
EOF
echo "== addon of the flashed image"
W=/root/fuxi/wall-study; rm -rf $W; mkdir -p $W
sed -n 1,30p /mnt/e/DSH-Fuxi/dump/wsl/verify-gpu-image.sh | cut -c1-150
ls /root/fuxi/ | grep -i -E 'gpu-fix|gpufix|gpu2|install-gpu' | head
find /root/fuxi -maxdepth 4 -type f \( -name 'adrenoprobed*' -o -name '*.primelist' -o -name 'NativeAdrenoMetal*' \) 2>/dev/null | head -12
strings -a /root/fuxi/t50-mine/kernel.macho | grep -E 'adrenoprobed|zz-oslog|\.ips|sheng-crash|crash-export|boot_log_crash|NativeAdrenoProbe' | cut -c1-140 | sort -u | head -14
echo "== UFS reserve constants"
grep -n -E 'kLogReserveBlocks|kExportBlocks|native_ufs_export_blocks|ExportReserve|kExport' /mnt/e/DSH-Fuxi/unixnu-build/fuxi/drivers/NativeUfs/*.cpp /mnt/e/DSH-Fuxi/unixnu-build/fuxi/drivers/NativeUfs/*.h 2>/dev/null | cut -c1-190 | head -14
