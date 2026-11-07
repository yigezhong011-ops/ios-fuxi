#!/usr/bin/env python3
"""Patch 0112: always write CTL0 START (this unit never clears it), with logging."""
import difflib
import re
from pathlib import Path

OUT = Path('/root/fuxi/0112-fuxi-kick-always.patch')

before = 'static uint32_t fbcon_cols, fbcon_rows, fbcon_col, fbcon_row;\n'

old_block = before + '''#if defined(FUXI)
static volatile uint32_t *fuxi_ctl0;
/* The inherited M3 panel is command mode. Validated CTL0 starts a new frame. */
void fuxi_display_kick(void)
{
    if (fuxi_ctl0 != NULL && !(fuxi_ctl0[0x1c / 4] & 1)) {
        __asm__ volatile("dsb sy" ::: "memory");
        fuxi_ctl0[0x1c / 4] = 1;
        __asm__ volatile("dsb sy" ::: "memory");
    }
}
#endif

static void
'''.splitlines(keepends=True)

new_block = before + '''#if defined(FUXI)
static volatile uint32_t *fuxi_ctl0;
static int fuxi_kick_count;
/* The inherited M3 panel is command mode. Validated CTL0 starts a new frame.
 * This unit leaves the START bit set after a transfer, so the guarded write
 * never fired and no frame ever reached the panel: write it on every present
 * and report what the register did. */
void fuxi_display_kick(void)
{
    if (fuxi_ctl0 != NULL) {
        volatile uint32_t *start = &fuxi_ctl0[0x1c / 4];
        uint32_t before = *start;
        __asm__ volatile("dsb sy" ::: "memory");
        *start = 1;
        __asm__ volatile("dsb sy" ::: "memory");
        if (fuxi_kick_count < 8) {
            fuxi_kick_count++;
            printf("FUXI KICK %d: start before=%#x after=%#x\\n",
                fuxi_kick_count, before, *start);
        }
    }
}
#endif

static void
'''.splitlines(keepends=True)

diff = list(difflib.unified_diff(
    old_block, new_block,
    fromfile='a/pexpert/arm/pe_serial.c',
    tofile='b/pexpert/arm/pe_serial.c',
    n=1))

# difflib header is @@ -1,N +1,M @@; shift both starts to the real region (720)
hdr = diff[2]
m = re.match(r'@@ -(\d+),(\d+) \+(\d+),(\d+) @@', hdr)
old_n, new_n = int(m.group(2)), int(m.group(4))
diff[2] = f'@@ -{720},{old_n} +{720},{new_n} @@\n'

text = ''.join(diff)
OUT.write_bytes(text.encode())
print(text)
print('old lines', old_n, 'new lines', new_n)
