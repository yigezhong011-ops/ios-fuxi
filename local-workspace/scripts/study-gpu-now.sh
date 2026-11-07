#!/bin/bash
# GPU state in the latest boot and what upstream has changed since our pins. Read-only apart from git fetch.
L=$(ls -d /root/fuxi/log-oslog1/*/ | head -1)
echo "== driver rows, last slot"
python3 -I - "$L" <<'EOF'
import re, sys
from collections import Counter
d = sys.argv[1]
s = open(d + '/slots.txt', errors='replace').read()
slots = [x for x in re.split(r'(?m)^(?=#slot )', s) if x.startswith('#slot')]
last = slots[-1]
for line in last.splitlines():
    if re.match(r'(\[|G |PR |W[01] |T[0-9] |M[0-9] |E[0-9] |V[0-9] |F[0-9] )', line) and not line.startswith(('[page', '[banner', '[ext', '[data', '[stacks', '[swap', '[display', '[scanout')):
        print(' ', line[:420])
print('== distinct W1 texts over the boot')
c = Counter(re.sub(r'\d+', '#', m)[:150] for m in re.findall(r'^W1 (.*)$', s, re.M))
for k, v in c.most_common(14):
    print(f'  {v:4d} {k}')
msg = open(d + '/msgbuf.txt', errors='replace').read().replace('\0', '')
for pat in ('no linear image', 'e00002d5', 'AdrenoMetal', 'native-metal', 'metal2vulkan|m2v', 'InvalidFile|BinaryArchive', 'VK_ERROR|vk error|Validation', 'unsupported|not supported|unimplemented', 'GPU hang|gpu fault|smmu|SMMU|fault'):
    hits = re.findall(r'[ -~]{0,80}(?:%s)[ -~]{0,120}' % pat, msg)
    print('--', pat, len(hits))
    for k, v in Counter(re.sub(r'\[ *[\d.]+\]:?|\[\d+\]|\(\d+\)|0x[0-9a-f]+', '', h)[:180] for h in hits).most_common(5):
        print(f'   {v:4d} {k}')
EOF
for r in src-adrenometal:7e0d3d2 src-unixnu:793d6bddf7 src-adreno740:759d646; do
  n=${r%%:*}; p=${r##*:}
  echo "== $n since $p"
  git -C /root/fuxi/$n fetch -q --all 2>&1 | head -2
  b=$(git -C /root/fuxi/$n symbolic-ref -q --short refs/remotes/origin/HEAD || echo origin/main)
  echo "$b $(git -C /root/fuxi/$n rev-list --count $p..$b) commits, head $(git -C /root/fuxi/$n log -1 --format='%h %ad' --date=short $b)"
  git -C /root/fuxi/$n log --format='%h %ad %s' --date=short $p..$b | grep -i -E 'widget|white|wallpaper|poster|linear|texture|no.copy|slot|client|gpu|metal|coher|hang|blank|render' | cut -c1-120 | head -24
done
