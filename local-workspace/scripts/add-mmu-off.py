#!/usr/bin/env python3
"""Turn the MMU off before loader_main so MMIO (RSC) is reachable as physical memory."""
from pathlib import Path

F = Path('/root/ios-fuxi/shim/fuxi-loader/start.S')
src = F.read_text()

if 'fuxi_mmu_off' in src:
    print('already patched')
    raise SystemExit

anchor = '''2:
 mov x0, x19
 bl loader_main'''
assert anchor in src, 'start anchor missing'

patched = '''/* ABL may leave the MMU on with its own tables; this loader addresses
 * everything physically, so switch it off (and the caches with it). */
 mov x9, x0
 mrs x1, sctlr_el1
 bic x1, x1, #1
 bic x1, x1, #4
 bic x1, x1, #0x1000
 dsb sy
 msr sctlr_el1, x1
 isb
 dsb sy
 isb
 mov x0, x9
fuxi_mmu_off:
2:
 mov x0, x19
 bl loader_main'''

src = src.replace(anchor, patched, 1)
F.write_text(src)
print('MMU-off added to start.S')
