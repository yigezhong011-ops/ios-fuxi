#!/bin/bash
set -euo pipefail
SEC=/root/uefi-fuxi/Silicon/Silicium/SiliciumPkg/Sec/Sec.c
RDRV=/root/uefi-fuxi/Platforms/Xiaomi/fuxiPkg/Drivers/FuxiRamDiskDxe/FuxiRamDiskDxe.c

cp "$SEC" "$SEC.orig" 2>/dev/null || true
python3 - "$SEC" <<'PY'
import pathlib, sys
p = pathlib.Path(sys.argv[1])
t = p.read_text()
old = "        PayloadBase = gSecEntryArg1 + 0x300000;  // the payload sits just below the device tree"
new = ("        // The boot image appends the device tree after the payload volume, and\n"
       "        // FuxiRamDiskDxe probes downward from this hint, so the tree address is\n"
       "        // the anchor: gSecEntryArg1 is not the payload on fuxi.\n"
       "        PayloadBase = EntryArg;")
assert old in t, 'SEC anchor missing'
t = t.replace(old, new, 1)
p.write_text(t)
print('SEC patched')
PY

python3 - "$RDRV" <<'PY'
import pathlib, sys
p = pathlib.Path(sys.argv[1])
t = p.read_text()
start = t.find('  //\n  // fastboot loads the Android boot image at the header')
end = t.find('  if (mVolumeBase == NULL) {\n    Print (L"FUXIRAMDISK: no hint volume, scanning the memory map')
assert start != -1 and end != -1 and start < end, 'driver block not found'
t = t[:start] + t[end:]
p.write_text(t)
print('driver header-read block removed')
PY
grep -n 'PayloadBase = ' "$SEC"
grep -n 'no hint volume' "$RDRV"
