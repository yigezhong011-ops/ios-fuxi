#!/usr/bin/env python3
"""Rebuild the post-0082 pe_serial.c fragment, then verify 0112 applies cleanly."""
import difflib, re, subprocess, tempfile, pathlib

P82 = pathlib.Path('/root/ios-fuxi/xnu/patches/0082-fuxi-ram-bringup.patch').read_text().splitlines()

# locate the pe_serial.c hunk that introduces fuxi_display_kick
start = None
for i, line in enumerate(P82):
    if line.startswith('--- a/pexpert/arm/pe_serial.c'):
        start = i
        break
assert start is not None, 'pe_serial.c hunk not found in 0082'

# collect the first hunk body (context + additions describe the post-0082 file)
body = []
i = start + 2
assert P82[i].startswith('@@'), P82[i]
i += 1
while i < len(P82) and not P82[i].startswith('@@') and not P82[i].startswith('--- a/'):
    line = P82[i]
    if line.startswith('+'):
        body.append(line[1:])
    elif line.startswith(' '):
        body.append(line[1:])
    i += 1

post = '\n'.join(body) + '\n'
pathlib.Path('/root/fuxi/pe_serial_fragment_post0082.c').write_text(post)
print('=== 0082 之后的片段 ===')
print(post)

# now build the replacement on exactly that text
old = post
new = post.replace(
    'static volatile uint32_t *fuxi_ctl0;\n'
    '/* The inherited M3 panel is command mode. Validated CTL0 starts a new frame. */\n'
    'void fuxi_display_kick(void)\n'
    '{\n'
    '    if (fuxi_ctl0 != NULL && !(fuxi_ctl0[0x1c / 4] & 1)) {\n'
    '        __asm__ volatile("dsb sy" ::: "memory");\n'
    '        fuxi_ctl0[0x1c / 4] = 1;\n'
    '        __asm__ volatile("dsb sy" ::: "memory");\n'
    '    }\n'
    '}\n',
    'static volatile uint32_t *fuxi_ctl0;\n'
    'static int fuxi_kick_count;\n'
    '/* The inherited M3 panel is command mode. Validated CTL0 starts a new frame.\n'
    ' * This unit leaves the START bit set after a transfer, so the guarded write\n'
    ' * never fired and no frame reached the panel: write it on every present. */\n'
    'void fuxi_display_kick(void)\n'
    '{\n'
    '    if (fuxi_ctl0 != NULL) {\n'
    '        volatile uint32_t *start = &fuxi_ctl0[0x1c / 4];\n'
    '        uint32_t before = *start;\n'
    '        __asm__ volatile("dsb sy" ::: "memory");\n'
    '        *start = 1;\n'
    '        __asm__ volatile("dsb sy" ::: "memory");\n'
    '        if (fuxi_kick_count < 8) {\n'
    '            fuxi_kick_count++;\n'
    '            printf("FUXI KICK %d: start before=%#x after=%#x\\n",\n'
    '                fuxi_kick_count, before, *start);\n'
    '        }\n'
    '    }\n'
    '}\n', 1)
assert old != new, 'replacement did not match'

diff = list(difflib.unified_diff(
    old.splitlines(keepends=True), new.splitlines(keepends=True),
    fromfile='a/pexpert/arm/pe_serial.c', tofile='b/pexpert/arm/pe_serial.c', n=3))
hdr = diff[2]
m = re.match(r'@@ -(\d+),(\d+) \+(\d+),(\d+) @@', hdr)
old_n, new_n = int(m.group(2)), int(m.group(4))
# the fragment starts at file line 720 (the hunk of 0082 starts there)
diff[2] = f'@@ -720,{old_n} +720,{new_n} @@\n'
text = ''.join(diff)
pathlib.Path('/root/fuxi/0112-fuxi-kick-always.patch').write_bytes(text.encode())
print('=== 新补丁 ===')
print(text)

# verify with git apply in a scratch tree
work = pathlib.Path(tempfile.mkdtemp())
(work / 'pexpert/arm').mkdir(parents=True)
(work / 'pexpert/arm/pe_serial.c').write_text(old)
r = subprocess.run(['git', 'apply', '--check', '--verbose',
                    '/root/fuxi/0112-fuxi-kick-always.patch'],
                   cwd=work, capture_output=True, text=True)
print('=== git apply --check ===')
print('rc =', r.returncode)
print(r.stdout.strip()[:400])
print(r.stderr.strip()[:600])
