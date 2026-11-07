#!/usr/bin/env python3
"""Patch 0112 (v3): always write CTL0 START, based on the post-0087/0108 text."""
import difflib, re, subprocess, tempfile, pathlib

fragment = '''static uint32_t fbcon_cols, fbcon_rows, fbcon_col, fbcon_row;
#if defined(FUXI)
static volatile uint32_t *fuxi_ctl0;
static volatile uint32_t *fuxi_intf1;
/* The inherited M3 panel is command mode. Validated CTL0 starts a new frame. */
void fuxi_display_kick(void)
{
    /* GPU-SCANOUT owns manual START until reset; console must stay muted. */
    if (fuxi_gpu_scanout_owned()) return;
    if (fuxi_intf1 == NULL || (fuxi_intf1[0x2b4 / 4] & 0x80000000u)) {
        __asm__ volatile("dsb sy" ::: "memory");
        return;
    }
    if (fuxi_ctl0 != NULL && !(fuxi_ctl0[0x1c / 4] & 1)) {
        __asm__ volatile("dsb sy" ::: "memory");
        fuxi_ctl0[0x1c / 4] = 1;
        __asm__ volatile("dsb sy" ::: "memory");
    }
}
#endif

static void
'''

old = fragment
new = fragment.replace(
    'static volatile uint32_t *fuxi_ctl0;\nstatic volatile uint32_t *fuxi_intf1;\n',
    'static volatile uint32_t *fuxi_ctl0;\nstatic volatile uint32_t *fuxi_intf1;\nstatic int fuxi_kick_count;\n', 1)
new = new.replace(
    '''    if (fuxi_ctl0 != NULL && !(fuxi_ctl0[0x1c / 4] & 1)) {
        __asm__ volatile("dsb sy" ::: "memory");
        fuxi_ctl0[0x1c / 4] = 1;
        __asm__ volatile("dsb sy" ::: "memory");
    }
''',
    '''    if (fuxi_ctl0 != NULL) {
        volatile uint32_t *start = &fuxi_ctl0[0x1c / 4];
        uint32_t before = *start;
        __asm__ volatile("dsb sy" ::: "memory");
        *start = 1;
        __asm__ volatile("dsb sy" ::: "memory");
        if (fuxi_kick_count < 8) {
            fuxi_kick_count++;
            printf("FUXI KICK %d: intf1=%#x start before=%#x after=%#x\\n",
                fuxi_kick_count, fuxi_intf1 ? fuxi_intf1[0x2b4 / 4] : 0,
                before, *start);
        }
    }
''', 1)
assert new != old

diff = list(difflib.unified_diff(
    old.splitlines(keepends=True), new.splitlines(keepends=True),
    fromfile='a/pexpert/arm/pe_serial.c', tofile='b/pexpert/arm/pe_serial.c', n=3))
hdr = diff[2]
m = re.match(r'@@ -(\d+),(\d+) \+(\d+),(\d+) @@', hdr)
old_n, new_n = int(m.group(2)), int(m.group(4))
diff[2] = f'@@ -722,{old_n} +722,{new_n} @@\n'
text = ''.join(diff)
pathlib.Path('/root/fuxi/0112-fuxi-kick-always.patch').write_bytes(text.encode())
print(text)

work = pathlib.Path(tempfile.mkdtemp())
(work / 'pexpert/arm').mkdir(parents=True)
(work / 'pexpert/arm/pe_serial.c').write_text(old)
r = subprocess.run(['git', 'apply', '--check', '--verbose',
                    '/root/fuxi/0112-fuxi-kick-always.patch'],
                   cwd=work, capture_output=True, text=True)
print('=== git apply --check ===')
print('rc =', r.returncode)
print(r.stdout.strip()[:300])
print(r.stderr.strip()[:400])
