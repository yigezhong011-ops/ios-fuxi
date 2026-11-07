#!/bin/bash
set -euo pipefail
D=/root/uefi-fuxi/Platforms/Xiaomi/fuxiPkg/Drivers/FuxiRamDiskDxe/FuxiRamDiskDxe.c
python3 - "$D" <<'PY'
import pathlib, sys
p = pathlib.Path(sys.argv[1])
t = p.read_text()
old = """    //
    // ABL keeps the payload in a large reserved range (0xA8000000-0xB7FFFFFF on
    // fuxi), so accept any descriptor big enough to hold the volume even when
    // its type is not normally scannable. MMIO apertures are far smaller.
    //
    if (!Scannable (Entry->Type) && (Entry->NumberOfPages < (64ULL * 1024 * 1024 / 4096))) {
      continue;
    }"""
new = """    //
    // ABL keeps the payload in the reserved range 0xA8000000-0xB7FFFFFF on fuxi.
    // Only that exact reservation is scanned: other reserved ranges cover MMIO
    // holes and reading them takes an external abort.
    //
    if (!Scannable (Entry->Type) && (Entry->PhysicalStart != 0xA8000000ULL)) {
      continue;
    }"""
assert old in t, 'scan anchor missing'
t = t.replace(old, new, 1)
p.write_text(t)
print('patched: only scan the 0xA8000000 reservation')
PY
grep -n '0xA8000000ULL' "$D" | head -3
