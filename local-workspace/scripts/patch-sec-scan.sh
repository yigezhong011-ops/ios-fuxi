#!/bin/bash
set -euo pipefail
SEC=/root/uefi-fuxi/Silicon/Silicium/SiliciumPkg/Sec/Sec.c
python3 - "$SEC" <<'PY'
import pathlib, sys
p = pathlib.Path(sys.argv[1])
t = p.read_text()
anchor = """    if ((EntryArg != 0) && ((EntryArg & 3) == 0)) {
      UINT32  DtMagic = SwapBytes32 (*(UINT32 *)(UINTN)EntryArg);
      UINT32  DtSize  = SwapBytes32 (*(UINT32 *)(UINTN)(EntryArg + 4));
"""
assert anchor in t, 'SEC anchor missing'
new = anchor + """      //
      // fuxi: ABL loads the kernel into the 4 MiB window at 0xA7000000 and the
      // device tree we append lives inside that window (right after the gzip
      // stream). ABL passes its own tree in x0, which has none of our /chosen
      // properties, so scan the window for the DTB magic and prefer ours.
      //
      {
        UINT64  Scan;

        for (Scan = 0xA7000000ULL; Scan < 0xA7400000ULL; Scan += 8) {
          if (*(volatile UINT32 *)(UINTN)Scan == SwapBytes32 (0xD00DFEED)) {
            UINT32  ScanSize = SwapBytes32 (*(UINT32 *)(UINTN)(Scan + 4));

            if ((ScanSize > 0x1000) && (ScanSize < 0x400000)) {
              EntryArg = Scan;
              DtMagic  = 0xD00DFEED;
              DtSize   = ScanSize;
              DEBUG ((EFI_D_WARN, "SEC: appended DT found at 0x%lx\\n", Scan));
            }
            break;
          }
        }
      }

"""
t = t.replace(anchor, new, 1)
p.write_text(t)
print('SEC patched: scan the 0xA7000000 window for the DTB')
PY
grep -n 'appended DT found' "$SEC"
cd /root/UniXNU
python3 ./unixnu build firmware --uefi /root/uefi-fuxi -D /root/UniXNU-fuxi > /root/fw7.log 2>&1
echo "FW7_EXIT=$?"
grep -iE 'error' /root/fw7.log | head -3
ls -lh /root/uefi-fuxi/Build/fuxiPkg/DEBUG_CLANGPDB/FV/SILICIUM_UEFI.fd
