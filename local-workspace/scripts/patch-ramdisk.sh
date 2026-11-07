#!/bin/bash
set -euo pipefail
F=/root/uefi-fuxi/Platforms/Xiaomi/fuxiPkg/Drivers/FuxiRamDiskDxe/FuxiRamDiskDxe.c
cp "$F" "$F.orig"
python3 - "$F" <<'PY'
import pathlib, sys
p = pathlib.Path(sys.argv[1])
t = p.read_text()
old = """  if (mVolumeBase == NULL) {
    Print (L"SIGNAL: no volume from the hint");"""
new = """  //
  // SEC only publishes the payload HOB when it can derive the address from the
  // device tree. Fall back to scanning the UEFI memory map for the FUXIESP
  // volume, which is what fastboot actually loaded.
  //
  if (mVolumeBase == NULL) {
    Print (L"FUXIRAMDISK: no hint volume, scanning the memory map\\n");
    if (LocatePayload ()) {
      Print (L"FUXIRAMDISK: payload at %lx from the memory map scan\\n", (UINT64)(UINTN)mVolumeBase);
    }
  }

  if (mVolumeBase == NULL) {
    Print (L"SIGNAL: no volume from the hint");"""
assert old in t, 'anchor missing'
t = t.replace(old, new, 1)
# LocatePayload is defined before the entry point but not prototyped; add a prototype.
proto_anchor = "BOOLEAN\nLocatePayload ("
assert proto_anchor in t
p.write_text(t)
print('patched LocatePayload fallback')
PY
grep -n -A3 'no hint volume' "$F"
