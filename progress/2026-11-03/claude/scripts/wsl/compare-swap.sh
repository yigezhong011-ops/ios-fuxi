#!/bin/bash
# verify_swap failures and first-swap context: the working boot (logs-1103, gpu7 on the old Data) vs the black fresh-Data boot.
for L in /root/fuxi/logs-1103 /root/fuxi/logs-gpu6fresh; do
  D=$(ls -d $L/*/ | head -1)
  echo "########## $L"
  M=$(tr -d '\0' < $D/msgbuf.txt)
  echo "verify_swap failed lines: $(echo "$M" | grep -c 'verify_swap failed')"
  echo "$M" | grep -aiE 'NativeLegacyDisplay' | grep -v 'verify_swap failed for swap' | head -12 | cut -c1-200
  echo "--- first verify_swap failure context"
  echo "$M" | grep -n -B6 -m1 'verify_swap failed' | cut -c1-200
done
D=$(ls -d /root/fuxi/logs-gpu6fresh/*/ | head -1)
echo "### fresh boot: swap/scanout rows over time"
grep -E '^(prepare calls|\[gpu clients\])' $D/slots.txt | awk 'NR%30==1' | head -12 | cut -c1-200
grep -E '^PR |^P[0-9] ' $D/slots.txt | sort -u | head -8 | cut -c1-200
