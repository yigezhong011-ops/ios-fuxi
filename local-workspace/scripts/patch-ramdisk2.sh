#!/bin/bash
set -euo pipefail
F=/root/uefi-fuxi/Platforms/Xiaomi/fuxiPkg/Drivers/FuxiRamDiskDxe/FuxiRamDiskDxe.c
cp "$F" "$F.orig" 2>/dev/null || true
python3 - "$F" <<'PY'
import pathlib, sys
p = pathlib.Path(sys.argv[1])
t = p.read_text()
anchor = '  if (mVolumeBase == NULL) {\n    Print (L"SIGNAL: no volume from the hint\\n");'
assert anchor in t, 'anchor missing'
insert = '''  //
  // SEC publishes the payload HOB only when it can derive the address from the
  // device tree. Fall back to scanning the UEFI memory map for the FUXIESP
  // volume that fastboot actually loaded.
  //
  if (mVolumeBase == NULL) {
    Print (L"FUXIRAMDISK: no hint volume, scanning the memory map\\n");
    if (LocatePayload ()) {
      Print (L"FUXIRAMDISK: payload at %lx from the memory map scan\\n", (UINT64)(UINTN)mVolumeBase);
    }
  }

''' + anchor
t = t.replace(anchor, insert, 1)
p.write_text(t)
print('patched')
PY
grep -n -A4 'no hint volume' "$F"
