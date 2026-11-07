#!/bin/bash
# Read-only: the screenshot entry points in the t50 kernel, what holds the current swap surface, and functions nothing calls (candidate room for code).
set -u
K=/root/fuxi/t50/kernel.macho; A=/root/fuxi/t50.dis; N=/tmp/t50-syms.txt
[ -s "$N" ] || llvm-nm --defined-only "$K" > "$N" 2>/dev/null
echo '== usb screenshot symbols'; grep -i -E 'qcom_usb.*(shot|framebuffer|screenshot)|usb_shot|shot_' "$N" | cut -c1-90 | head -30
echo '== legacy display swap state'; grep -E 'native_legacy_[a-z_]*(swap|surface|scanout|transfer|front|copy|present|gop)[a-z_]*$' "$N" | cut -c1-90 | head -40
echo '== legacy display functions'; grep -i -E '(NativeLegacy|Legacy).*(swap|Swap|copy|Copy|present|Present|transfer)' "$N" | grep -v -E 'MetaClass|vtable' | cut -c1-110 | head -30
echo '== register_screenshot body'; awk 'index($0,"<_qcom_usb_debug_register_screenshot>:"){p=1} p{print; c++} p&&/^$/{exit} c>30{exit}' "$A" | cut -c1-100
echo '== capture call in the shot path'; grep -n -E 'blr\s' "$A" | awk -F: '$1>0' | head -0
awk 'index($0,"<_qcom_usb_shot_begin>:")||index($0,"<_qcom_usb_screenshot_capture>:"){p=1} p{print; c++} p&&/^$/{exit} c>60{exit}' "$A" | cut -c1-100
echo '== functions never the target of bl/b and over 512 bytes, in the driver range'
python3 -I - "$A" "$N" <<'PY'
import re, sys
A, N = sys.argv[1:3]
syms = []
for l in open(N):
    p = l.split()
    if len(p) == 3 and p[1] in 'sStT':
        syms.append((int(p[0], 16), p[2]))
syms.sort()
text = open(A).read()
targets = set(re.findall(r'\b(?:bl|b)\s+0x([0-9a-f]+)', text))
adrp = re.findall(r'(fffffff[0-9a-f]+):\s+adr\s+x\d+, 0x([0-9a-f]+)', text)
targets |= {t for _, t in adrp}
out = []
for (a, n), (b, _) in zip(syms, syms[1:]):
    if not 0xfffffff00bd00000 <= a < 0xfffffff00c200000:
        continue
    size = b - a
    if 512 <= size < 0x8000 and format(a, 'x') not in targets and re.search(r'probe|diag|test|debug|dump|audit|trace|stat', n, re.I):
        out.append((size, n, hex(a)))
out.sort(reverse=True)
for s, n, a in out[:30]:
    print(s, a, n[:70])
PY
