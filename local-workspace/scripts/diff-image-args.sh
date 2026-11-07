#!/bin/bash
set -uo pipefail
for n in unixnu-quiet unixnu-touch; do
  mtype -i "/root/insp-$n/payload.img" ::/EFI/UniXNU/unixnu.toml 2>/dev/null \
    | grep -o 'args = "[^"]*"' | sed 's/^args = "//; s/"$//' | tr ' ' '\n' | sort > "/root/args-$n.txt"
  echo "$n: $(wc -l < /root/args-$n.txt) 个参数"
done
echo
echo "=== quiet 与 touch 的差异 ==="
diff /root/args-unixnu-quiet.txt /root/args-unixnu-touch.txt && echo "（无差异）"
echo
echo "=== touch 特有的参数 ==="
comm -13 /root/args-unixnu-quiet.txt /root/args-unixnu-touch.txt
echo
echo "=== 全部参数（touch）==="
tr '\n' ' ' < /root/args-unixnu-touch.txt | fold -w 150
