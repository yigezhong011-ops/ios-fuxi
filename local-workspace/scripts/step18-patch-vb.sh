#!/bin/bash
set -uo pipefail
cd /root/fuxi
#
# 1) 改 first_stage_ramdisk/fstab.qcom：去掉 userdata 的 fileencryption / metadata_encryption / keydirectory
#
F=/root/fuxi/rd/first_stage_ramdisk/fstab.qcom
cp "$F" "$F.orig"
python3 - <<'PY'
import re
p = '/root/fuxi/rd/first_stage_ramdisk/fstab.qcom'
lines = open(p).read().splitlines(True)
out = []
for ln in lines:
    if '/data ' in ln and ('userdata' in ln):
        # 去掉这三个 flag
        ln = re.sub(r',fileencryption=[^,\s]+', '', ln)
        ln = re.sub(r',metadata_encryption=[^,\s]+', '', ln)
        ln = re.sub(r',keydirectory=[^,\s]+', '', ln)
        ln = re.sub(r',inlinecrypt(?=,)', '', ln)
        ln = ln.replace(',inlinecrypt,gc_merge', ',gc_merge')
    out.append(ln)
open(p, 'w').writelines(out)
print('patched fstab')
PY
echo "=== 改后的 userdata 行 ==="
grep -nE 'by-name/userdata' "$F"

#
# 2) 重新打包 cpio（保持原格式 newc）并 lz4 legacy 压缩
#
cd /root/fuxi/rd
find . -mindepth 1 | cpio -o -H newc --quiet > /root/fuxi/ramdisk_new.cpio 2>/dev/null
ls -l /root/fuxi/ramdisk_new.cpio
lz4 -l -9 -f /root/fuxi/ramdisk_new.cpio /root/fuxi/vendor_ramdisk_new.lz4 2>&1 | tail -2
ls -l /root/fuxi/vendor_ramdisk_new.lz4

#
# 3) 用原 vendor_boot 的头参数重打包
#
cd /root/fuxi
python3 /mnt/e/DSH-Fuxi/dump/tools/mkbootimg.py \
  --header_version 4 \
  --vendor_boot /root/fuxi/vendor_boot_patched.img \
  --vendor_ramdisk /root/fuxi/vendor_ramdisk_new.lz4 \
  --dtb /root/fuxi/vb_out/dtb \
  --vendor_bootconfig /root/fuxi/vb_out/bootconfig \
  --pagesize 4096 \
  --os_version 16.0.0 --os_patch_level 2026-08 2>&1 | tail -5
ls -l /root/fuxi/vendor_boot_patched.img
echo "=== 验证能解析回去 ==="
rm -rf /root/fuxi/vb_check && mkdir -p /root/fuxi/vb_check
python3 /mnt/e/DSH-Fuxi/dump/tools/unpack_bootimg.py --boot_img /root/fuxi/vendor_boot_patched.img --out /root/fuxi/vb_check 2>&1 | grep -E 'header version|page size|vendor ramdisk|dtb|bootconfig' | head -8
cp /root/fuxi/vendor_boot_patched.img /mnt/e/DSH-Fuxi/backup/vendor_boot_patched.img
echo PATCH_VB_DONE
