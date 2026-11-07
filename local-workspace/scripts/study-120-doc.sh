#!/bin/bash
# Read-only: zizhan's 120 Hz notes and our display rate rows.
ls /root/fuxi/ref-zizhan | head -8
F=$(find /root/fuxi/ref-zizhan /root/fuxi/up-latest -iname '*120hz*' -not -path '*/.git/*' 2>/dev/null | head -1); echo "doc: $F"
[ -n "$F" ] && cut -c1-520 "$F" | head -70
L=/root/fuxi/wall1/log/untagged-2c15ceb80/latest.txt
grep -a -n -i -E 'vsync|refresh|[0-9] ?hz|fps' $L | cut -c1-220 | head -16
