#!/bin/bash
set -euo pipefail
F=/root/uefi-fuxi/Platforms/Xiaomi/fuxiPkg/Drivers/FuxiRamDiskDxe/FuxiRamDiskDxe.c
python3 - "$F" <<'PY'
import pathlib, sys
p = pathlib.Path(sys.argv[1])
t = p.read_text()
old = '''  if (mVolumeBase == NULL) {
    Print (L"FUXIRAMDISK: no hint volume, scanning the memory map\\n");
    if (LocatePayload ()) {
      Print (L"FUXIRAMDISK: payload at %lx from the memory map scan\\n", (UINT64)(UINTN)mVolumeBase);
    }
  }

  if (mVolumeBase == NULL) {
    Print (L"SIGNAL: no volume from the hint\\n");
    Print (L"  hob=%d base=%lx\\n", mHintSeen ? 1 : 0, mHintValue);
    gBS->Stall (3000000);
    return EFI_SUCCESS;
  }'''
new = '''  if (mVolumeBase == NULL) {
    Print (L"FUXIRAMDISK: no hint volume, scanning the memory map\\n");
    if (LocatePayload ()) {
      Print (L"FUXIRAMDISK: payload at %lx from the memory map scan\\n", (UINT64)(UINTN)mVolumeBase);
    }
  }

  if (mVolumeBase == NULL) {
    Print (L"\\n=== SIGNAL: no volume from the hint ===\\n");
    Print (L"  hob=%d base=%lx\\n", mHintSeen ? 1 : 0, mHintValue);
    Print (L"  dt  = %lx\\n", mHintValue);
    Print (L"  halting so this stays on screen\\n");
    //
    // Diagnostics only: keep the message visible instead of letting the boot
    // manager clear the console.
    //
    for (;;) {
      gBS->Stall (1000000);
    }
  }'''
assert old in t, 'anchor missing'
t = t.replace(old, new, 1)
p.write_text(t)
print('patched: halt on failure')
PY
grep -n -A3 'SIGNAL: no volume' "$F" | head -8
