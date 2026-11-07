#!/bin/bash
# Read-only: the peer image's real toml, ADT and kernel, as opposed to leftovers in free clusters.
P=/root/fuxi/peer1/files/EFI/UniXNU
O=/root/fuxi/peer-ours/files/EFI/UniXNU
echo "== toml args"; grep -a '^args' $P/unixnu.toml | sed 's/ /\n/g' | sort > /tmp/a.peer; cat /tmp/a.peer | tr '\n' ' '; echo
grep -a '^args' $O/unixnu.toml | sed 's/ /\n/g' | sort > /tmp/a.ours
echo "== only in peer"; comm -23 /tmp/a.peer /tmp/a.ours | tr '\n' ' '; echo
echo "== only in ours"; comm -13 /tmp/a.peer /tmp/a.ours | tr '\n' ' '; echo
echo "== ADT strings peer"
strings -n 3 $P/Payloads/kernel.macho.adt | grep -n -E -A1 '^(model|target-type|product-name|product-description|artwork-device-idiom|compatible-device-fallback)$' | cut -c1-80 | head -30
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/adt-node-props.py /device-tree/product $P/Payloads/kernel.macho.adt 2>&1 | head -24
echo "== ADT strings ours"
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/adt-node-props.py /device-tree/product $O/Payloads/kernel.macho.adt 2>&1 | head -14
echo "== kernel"
K=$P/Payloads/kernel.macho
file $K | cut -c1-140
strings -n 8 $K | grep -m3 -E 'Darwin Kernel Version'
for k in sheng-data-persist sheng-data-reset sheng-setup sheng-backlight fuxi-backlight sheng-log sheng-gpu-addon sheng-fb-gpu qcom-usb-debug SXNU1R PE_halt_restart control_hook_owned gpuaddon DWC3 fuxi; do printf '%-22s %s\n' $k "$(grep -a -c -- "$k" $K)"; done
echo "== trustcache same as a known one?"
sha256sum $P/Payloads/kernel.macho.trustcache $O/Payloads/kernel.macho.trustcache | cut -c1-16
echo "== ours comparison"
strings -n 8 $O/Payloads/kernel.macho | grep -m2 -E 'Darwin Kernel Version'
