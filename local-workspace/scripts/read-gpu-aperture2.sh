#!/bin/bash
# Read-only: immediates in GPU bringUp and prepare, and the limits in ArmSmmu4KLivePrepare.
A=/root/fuxi/t50.dis
fn() { awk -v s="^$1 <" -v m="$2" '$0 ~ s {p=1;n=0} p{n++; print} p&&n>m{exit}' "$A" | sed -E 's/<[^>]*>//' | cut -c1-70; }
echo '== bringUp'; fn fffffff00c00c0a4 260 | grep -E '#0x403|#0x8000|#0x80000|lsl #|=2147|=1027|=524288|bl\s' | head -30
echo '== prepare'; fn fffffff00c012390 26 | cut -c19-
echo '== LivePrepare'; fn fffffff00c0043f0 110 | cut -c19-
