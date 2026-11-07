#!/bin/bash
set -euo pipefail
F=/root/uefi-fuxi/Platforms/Xiaomi/fuxiPkg/Drivers/FuxiRamDiskDxe/FuxiRamDiskDxe.c
python3 - "$F" <<'PY'
import pathlib, sys
p = pathlib.Path(sys.argv[1])
t = p.read_text()
anchor = '  if (mVolumeBase == NULL) {\n    Print (L"FUXIRAMDISK: no hint volume, scanning the memory map\\n");'
assert anchor in t, 'anchor missing'
new = '''  //
  // fastboot loads the Android boot image at the header's kernel address
  // (0x0C000000 on fuxi). v3 keeps the ramdisk directly after the kernel, so
  // read that header and take the ramdisk offset without scanning all of RAM.
  //
  if (mVolumeBase == NULL) {
    UINT64  Img     = 0x0C000000ULL;
    UINT64  Total   = 0;
    UINT8   *Hdr    = (UINT8 *)(UINTN)Img;

    if (CompareMem (Hdr, "ANDROID!", 8) == 0) {
      UINT32  KernelSize = *(UINT32 *)(UINTN)(Img + 8);
      UINT64  Ramdisk    = Img + ((UINT64)KernelSize + 0xFFFULL & ~0xFFFULL);

      Print (L"FUXIRAMDISK: boot image at %lx, kernel=%lu, ramdisk at %lx\\n",
             Img, (UINT64)KernelSize, Ramdisk);
      if (IsPayloadVolume ((UINT8 *)(UINTN)Ramdisk, &Total)) {
        mVolumeBase  = (UINT8 *)(UINTN)Ramdisk;
        mVolumeBytes = (UINTN)(Total * FUXI_BLOCK_SIZE);
        Print (L"FUXIRAMDISK: payload from the boot image header at %lx\\n", Ramdisk);
      }
    } else {
      Print (L"FUXIRAMDISK: no ANDROID! header at %lx\\n", Img);
    }
  }

''' + anchor
t = t.replace(anchor, new, 1)
p.write_text(t)
print('patched header-based lookup')
PY
grep -n -A2 'boot image at' "$F" | head -6
