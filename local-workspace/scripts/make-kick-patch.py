#!/usr/bin/env python3
"""Patch 0112: always write CTL0 START (this unit never clears it), with logging."""
import difflib
from pathlib import Path

OUT = Path('/root/fuxi/0112-fuxi-kick-always.patch')

old_block = '''#if defined(FUXI)
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
'''.splitlines(keepends=True)

new_block = '''#if defined(FUXI)
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
'''.splitlines(keepends=True)

# build the diff with enough context
diff = list(difflib.unified_diff(
    ['/* context above */\n'] + old_block + ['/* context below */\n'],
    ['/* context above */\n'] + new_block + ['/* context below */\n'],
    fromfile='a/pexpert/arm/pe_serial.c',
    tofile='b/pexpert/arm/pe_serial.c',
    n=3))

# drop the synthetic context markers so the hunk matches the real file region
diff = diff[2:]
diff.insert(0, '--- a/pexpert/arm/pe_serial.c\n')
diff.insert(1, '+++ b/pexpert/arm/pe_serial.c\n')
# recompute the hunk header: the real file has the block at @@ -720,...
body = diff[2:]
first = body[0]
if first.startswith('@@'):
    body = body[1:]
text = '--- a/pexpert/arm/pe_serial.c\n+++ b/pexpert/arm/pe_serial.c\n@@ -720,18 +720,25 @@\n' + ''.join(body[1:])
OUT.write_bytes(text.encode())
print(text)
