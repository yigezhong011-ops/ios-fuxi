#!/bin/bash
# Read-only: what UsbPwrEnablerDxe writes, the depex GUID, the V2 USB notes, and which nuwa USB drivers the firmware already holds.
set -u
U=/mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi; D=$U/Silicon/Qualcomm/NicobarPkg/Drivers/UsbPwrEnablerDxe; R=/root/fuxi/ref-unixnu-fuxi-bare
ls -la "$D" | cut -c24-
python3 -I - "$D/UsbPwrEnablerDxe.efi" <<'PY' > /tmp/usbpwr.txt
import struct, subprocess, sys
d = open(sys.argv[1], 'rb').read()
pe = struct.unpack_from('<I', d, 0x3c)[0]
n = struct.unpack_from('<H', d, pe + 6)[0]; opt = struct.unpack_from('<H', d, pe + 20)[0]
entry = struct.unpack_from('<I', d, pe + 40)[0]
at = pe + 24 + opt
print('entry', hex(entry))
for i in range(n):
    name = d[at:at + 8].rstrip(b'\0').decode(); vs, va, rs, rp = struct.unpack_from('<IIII', d, at + 8); at += 40
    print(name, hex(va), hex(vs), hex(rp), hex(rs))
    if name == '.text':
        open('/tmp/usbpwr.text', 'wb').write(d[rp:rp + rs])
        print('TEXTVA', hex(va))
PY
cat /tmp/usbpwr.txt
VA=$(grep TEXTVA /tmp/usbpwr.txt | cut -d' ' -f2)
llvm-objcopy -I binary -O elf64-littleaarch64 -B aarch64 --rename-section .data=.text,code /tmp/usbpwr.text /tmp/usbpwr.o 2>/dev/null
llvm-objdump -d --no-show-raw-insn --adjust-vma=$VA /tmp/usbpwr.o 2>/dev/null > /tmp/usbpwr.dis; wc -l /tmp/usbpwr.dis
echo '== 32-bit constants and MMIO-like moves'; grep -E 'mov[zk]?\s+[wx][0-9]+, #0x[0-9a-f]{3,}|movk' /tmp/usbpwr.dis | cut -c1-70 | head -50
echo '== loads via adrp, stores'; grep -c -E '\bstr\b' /tmp/usbpwr.dis; grep -E '\bbr\b|\bblr\b' /tmp/usbpwr.dis | cut -c1-60 | head -24
grep -rl '13a3f0f6-264a-3ef0\|13A3F0F6-264A-3EF0\|0x13a3f0f6' "$U/Silicon/Qualcomm" "$U/Platforms" --include=*.dec --include=*.inc --include=*.h 2>/dev/null | cut -c30- | head -5
grep -rn -i '13a3f0f6' "$U/Silicon/Qualcomm" --include=*.dec 2>/dev/null | cut -c30-170 | head -5
echo '== V2 USB-RESTORE'; git -C "$R" show V2:USB-RESTORE-20261102.md | cut -c1-200 | head -70
echo '== V2 notes on normal boot'; git -C "$R" grep -n -i -E '正常启动|冷启动|cold boot|normal boot|fastboot boot|VBUS|repeater|UsbConfigDxe' V2 -- '*.md' 'package/*' 'scripts/*.py' 2>/dev/null | grep -v -E 'facts/|never flash' | cut -c1-190 | head -24
echo '== nuwa'; ls "$U/Binaries/nuwa/QcomPkg/Drivers" | grep -i -E 'usb|^uc|pmic|clock|charger|Tlmm|Spmi' | tr '\n' ' '; echo
sed -n 76,90p "$U/Platforms/Xiaomi/fuxiPkg/Include/DXE.inc" | tr -d '\r' | cut -c1-90
