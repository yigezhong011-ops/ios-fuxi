#!/bin/bash
# Where WSL's space goes, for a cleanup list. Read-only.
echo "== /"; du -xh --max-depth=1 / 2>/dev/null | sort -rh | head -12 | cut -c1-60
echo "== /root"; du -xh --max-depth=1 /root 2>/dev/null | sort -rh | head -14 | cut -c1-60
echo "== largest files"; find / -xdev -type f -size +400M -printf '%s %TY-%Tm-%Td %p\n' 2>/dev/null | sort -rn | head -25 | awk '{printf "%6.2f GiB %s %s\n",$1/1073741824,$2,$3}' | cut -c1-110
cd /root/fuxi || exit 1
echo "== /root/fuxi by family (MiB, dirs)"
du -xsm */ 2>/dev/null | python3 -I -c '
import re, sys
from collections import defaultdict
g = defaultdict(lambda: [0, 0])
for l in sys.stdin:
    m, n = l.split(None, 1); n = n.strip().rstrip("/")
    k = "src-*" if n.startswith("src") else "t32*" if n.startswith("t32") else "t36*" if n.startswith("t36") else "t50*" if n.startswith("t50") else "log*/carve" if re.match(r"log|carve", n) else "pkg*" if n.startswith("pkg") else "gpu-*" if n.startswith("gpu") else "g[0-9]*" if re.match(r"g\d", n) else "other"
    g[k][0] += int(m); g[k][1] += 1
for k, v in sorted(g.items(), key=lambda x: -x[1][0]):
    print(f"{v[0]:7d} MiB {v[1]:4d} dirs  {k}")
'
echo "== newest and oldest build dirs"; ls -dt --time-style=+%m-%d -l t*/ gpu*/ 2>/dev/null | awk '{print $6,$7}' | head -10; echo ...; ls -dt --time-style=+%m-%d -l t*/ 2>/dev/null | awk '{print $6,$7}' | tail -6
echo "== docker, swap, journal"; du -xsh /var/log /var/lib/docker /tmp /swapfile 2>/dev/null | cut -c1-60
