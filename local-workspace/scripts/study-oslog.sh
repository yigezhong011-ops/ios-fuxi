#!/bin/bash
# How does the plugin export os_log, and what would switching it on take? Read-only.
A=/root/fuxi/src-adrenometal; P=7e0d3d2ebaecd736784de0baa09254b7f63bc150; U=/root/fuxi/src-unixnu
git -C $A show $P:NativeOsLogExport.mm > /root/fuxi/oslog-src.txt
wc -l /root/fuxi/oslog-src.txt
sed -n 1,60p /root/fuxi/oslog-src.txt | cut -c1-210
echo "== switches and targets"
grep -n -E 'getenv|ngpu/|access\(|/private/|sysctl|PE_parse|socket|connect\(|open\(|sheng-' /root/fuxi/oslog-src.txt | cut -c1-190 | head -24
echo "== who starts it"
git -C $A grep -n -E 'NativeOsLogExport|oslog_export|OsLogExport|os_log_export' $P | sed "s/^$P://" | cut -c1-190 | head -12
echo "== reader on the host, and sheng-diag-export"
git -C $U ls-tree -r --name-only origin/main | grep -i -E 'diag|oslog|os-log|export' | cut -c1-110 | head -14
git -C $A grep -n -E 'sheng-diag-export|diag-export|diag_export' $P | sed "s/^$P://" | cut -c1-190 | head -10
strings -a /root/fuxi/t50-mine/kernel.macho | grep -E 'sheng-diag|diag-export|sheng-gpu-trace' | cut -c1-120 | sort -u | head
grep -a -n -E 'sheng-diag|diag-export' /mnt/e/DSH-Fuxi/*.md | cut -c1-170 | head -8
echo "== is it in the built plugin of our addon?"
ls -la /root/fuxi/ 2>/dev/null | grep -i -E 'addon|plugin' | cut -c1-100 | head
