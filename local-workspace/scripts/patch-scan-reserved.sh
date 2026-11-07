#!/bin/bash
set -euo pipefail
D=/root/uefi-fuxi/Platforms/Xiaomi/fuxiPkg/Drivers/FuxiRamDiskDxe/FuxiRamDiskDxe.c
python3 - "$D" <<'PY'
import pathlib, sys
p = pathlib.Path(sys.argv[1])
t = p.read_text()
old = """    if (!Scannable (Entry->Type)) {
      continue;
    }"""
new = """    //
    // ABL keeps the payload in a large reserved range (0xA8000000-0xB7FFFFFF on
    // fuxi), so accept any descriptor big enough to hold the volume even when
    // its type is not normally scannable. MMIO apertures are far smaller.
    //
    if (!Scannable (Entry->Type) && (Entry->NumberOfPages < (64ULL * 1024 * 1024 / 4096))) {
      continue;
    }"""
assert old in t, 'scan anchor missing'
t = t.replace(old, new, 1)
p.write_text(t)
print('patched: scan large reserved regions too')
PY
grep -n -A2 'ABL keeps the payload' "$D" | head -6
