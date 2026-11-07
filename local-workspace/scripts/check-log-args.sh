#!/bin/bash
# Which log-capture switches does the t32 kernel know, and are they on in the current payload args?
K=/root/fuxi/t32/kernel.macho
for s in sheng-log boot-ui-trace boot-ui-focus BootProcessWorker read-sheng-log; do
  printf '%s: %s\n' "$s" "$(grep -c -a -- "$s" $K)"
done
echo "--- strings around sheng-log / boot-ui"
strings -n 6 $K | grep -E '^(sheng-log|boot-ui)[a-z0-9-]*' | sort -u | head -20
echo "--- args in the daily image's unixnu.toml"
mtype -i /root/fuxi/chk-gpu4/vol.img ::/EFI/UniXNU/unixnu.toml | tr ' ' '\n' | grep -E 'sheng-log|boot-ui|persist' | head
