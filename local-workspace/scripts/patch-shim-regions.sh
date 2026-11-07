#!/bin/bash
set -euo pipefail

# --- 1. BootShim: 保存并在进入 SEC 前恢复 x0（设备树地址） ---
SHIM=/root/uefi-fuxi/BootShim/BootShim.S
cp "$SHIM" "$SHIM.orig" 2>/dev/null || true
python3 - "$SHIM" <<'PY'
import pathlib, sys
p = pathlib.Path(sys.argv[1])
t = p.read_text()
if 'x19' in t:
    print('shim already patched')
else:
    t = t.replace("""_Head:
  adr   x1, _Payload    /* Set _Entry address */
  b     _Start          /* Jump to the real code */""",
"""_Head:
  adr   x1, _Payload    /* Set _Entry address */
  mov   x19, x0         /* preserve the bootloader's device tree pointer */
  b     _Start          /* Jump to the real code */""", 1)
    t = t.replace("""  dsb   sy
  ic    iallu
  dsb   sy
  isb
  br    x5""",
"""  dsb   sy
  ic    iallu
  dsb   sy
  isb
  mov   x0, x19         /* hand the device tree to SEC in x0 */
  br    x5""", 1)
    p.write_text(t)
    print('shim patched')
PY

# --- 2. 驱动：打印最大的几个内存区域，便于定位 192 MB 的 ramdisk ---
D=/root/uefi-fuxi/Platforms/Xiaomi/fuxiPkg/Drivers/FuxiRamDiskDxe/FuxiRamDiskDxe.c
python3 - "$D" <<'PY'
import pathlib, sys
p = pathlib.Path(sys.argv[1])
t = p.read_text()
anchor = '  Count = MapSize / DescSize;\n  Print (L"FUXIRAMDISK: scanning %lu memory regions\\n", (UINT64)Count);'
assert anchor in t, 'driver anchor missing'
add = anchor + '''
  {
    // Report the biggest regions first: the 192 MiB payload volume shows up as
    // one of them even when its descriptor type is not scannable.
    UINTN  Top;
    UINT64 BestPages;

    for (Top = 0; Top < 6; Top++) {
      UINTN   BestIndex = Count;
      UINT64  BestSize  = 0;

      for (Index = 0; Index < Count; Index++) {
        EFI_MEMORY_DESCRIPTOR  *E = (EFI_MEMORY_DESCRIPTOR *)((UINT8 *)Map + Index * DescSize);

        if ((E->NumberOfPages > BestSize) && ((E->Attribute & 0x1) == 0)) {
          BestSize  = E->NumberOfPages;
          BestIndex = Index;
        }
      }

      if (BestIndex == Count) {
        break;
      }

      {
        EFI_MEMORY_DESCRIPTOR  *E = (EFI_MEMORY_DESCRIPTOR *)((UINT8 *)Map + BestIndex * DescSize);
        Print (L"FUXIRAMDISK: region %d type=%d %lx-%lx (%lu KiB)\\n",
               (UINT64)Top, (UINT64)E->Type, E->PhysicalStart,
               E->PhysicalStart + (E->NumberOfPages << 12),
               (E->NumberOfPages << 12) / 1024);
        E->Attribute |= 0x1;   /* mark as reported */
      }
    }
  }
'''
t = t.replace(anchor, add, 1)
p.write_text(t)
print('driver patched: region report')
PY
grep -n 'region %d type' "$D" | head -3
grep -n 'mov   x0, x19' "$SHIM"
