#!/bin/bash
# Does the stock t32 kernel know the log / UI-trace boot args from the log-capture doc?
cd /root/fuxi/t32
k=$(ls -S *.macho 2>/dev/null | grep -v -E '120|buttons|bl' | head -1)
[ -z "$k" ] && k=kernel-buttons.macho
echo "kernel: $k"
strings -n 6 "$k" | grep -E 'boot-ui-trace|boot-ui-focus|sheng-log|BootProcessWorker|ui-trace' | sort -u | head -20
echo "--- args"
tr ' ' '\n' < args.txt | grep -E 'log|trace|ui' | head
