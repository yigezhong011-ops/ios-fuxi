#!/usr/bin/env python3
"""Patch 0112 (v4): correct every hunk's file line numbers, verify on a padded file."""
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
fbcon_clear_row(uint32_t row)
'''

old = fragment
new = fragment.replace(
    'static volatile uint32_t *fuxi_intf1;\n',
    'static volatile uint32_t *fuxi_intf1;\nstatic int fuxi_kick_count;\n', 1)
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

# the fragment's first line is file line 720 (0082's hunk header)
BASE = 720

diff = list(difflib.unified_diff(
    old.splitlines(keepends=True), new.splitlines(keepends=True),
    fromfile='a/pexpert/arm/pe_serial.c', tofile='b/pexpert/arm/pe_serial.c', n=3))

out = [diff[0], diff[1]]
for line in diff[2:]:
    m = re.match(r'@@ -(\d+),(\d+) \+(\d+),(\d+) @@', line)
    if m:
        a, n_old, b, n_new = (int(x) for x in m.groups())
        start = BASE + a - 1
        out.append(f'@@ -{start},{n_old} +{start},{n_new} @@\n')
    else:
        out.append(line)
text = ''.join(out)
pathlib.Path('/root/fuxi/0112-fuxi-kick-always.patch').write_bytes(text.encode())
print(text)

# verify: file = 719 padding lines + fragment
work = pathlib.Path(tempfile.mkdtemp())
(work / 'pexpert/arm').mkdir(parents=True)
padding = ''.join(f'/* pad {i} */\n' for i in range(BASE - 1))
(work / 'pexpert/arm/pe_serial.c').write_text(padding + fragment)
r = subprocess.run(['git', 'apply', '--check', '--verbose',
                    '/root/fuxi/0112-fuxi-kick-always.patch'],
                   cwd=work, capture_output=True, text=True)
print('=== git apply --check (padded) ===')
print('rc =', r.returncode)
print(r.stdout.strip()[:300])
print(r.stderr.strip()[:400])
if r.returncode == 0:
    subprocess.run(['git', 'apply', '/root/fuxi/0112-fuxi-kick-always.patch'], cwd=work)
    result = (work / 'pexpert/arm/pe_serial.c').read_text()
    print('=== applied? fuxi_kick_count present:', 'fuxi_kick_count' in result)
    print('=== always-write present:', '*start = 1;' in result)
