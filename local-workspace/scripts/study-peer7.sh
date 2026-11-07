#!/bin/bash
# Read-only: what the peer kernel does with storage and USB.
K=/root/fuxi/peer1/files/EFI/UniXNU/Payloads/kernel.macho
O=/root/fuxi/peer-ours/files/EFI/UniXNU/Payloads/kernel.macho
strings -n 5 $K > /tmp/k.peer; strings -n 5 $O > /tmp/k.ours
wc -l /tmp/k.peer /tmp/k.ours
echo "== USB"; grep -a -i -E 'qcom-usb|usb.?(ctl|debug|console|serial)|dwc3|FUXIXNU|REBOOT|SCREENSHOT|cdc.?acm|XHCI' /tmp/k.peer | grep -v -E '^_|IOUSB|AppleUSB' | cut -c1-110 | sort -u | head -40
echo "== storage / data"; grep -a -i -E 'native-fuxi|ufs-root|data-persist|userdata|PackedRAMDisk|seed|ramdisk|rootdev|sheng-|mount.*data|Data volume' /tmp/k.peer | grep -v -E '^_' | cut -c1-110 | sort -u | head -50
echo "== fuxi strings"; grep -a -E 'fuxi' /tmp/k.peer | grep -v '^_' | cut -c1-110 | sort -u | head -50
echo "== boot args the kernel reads, peer only vs ours"
grep -a -E '^(sheng|fuxi|native|offline|qcom|unixnu)-[a-z0-9-]+$' /tmp/k.peer | sort -u > /tmp/b.peer
grep -a -E '^(sheng|fuxi|native|offline|qcom|unixnu)-[a-z0-9-]+$' /tmp/k.ours | sort -u > /tmp/b.ours
echo "peer:"; cat /tmp/b.peer | tr '\n' ' '; echo; echo "only peer:"; comm -23 /tmp/b.peer /tmp/b.ours | tr '\n' ' '; echo
echo "== launchd/root in seed?"; grep -a -c 'sbin/launchd' /tmp/k.peer
