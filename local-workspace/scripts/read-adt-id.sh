#!/bin/bash
# Read-only: what identity the candidate's ADT carries, and how it was written.
export MTOOLS_SKIP_CHECK=1
V=/root/fuxi/t50-wall17/vol.img
mcopy -n -i $V ::/EFI/UniXNU/Payloads/kernel.macho.adt /tmp/cand.adt
strings -a /tmp/cand.adt | grep -E '^(iPhone|iPad|J[0-9]+|D[0-9]+[a-zA-Z]*AP|[A-Z][0-9]+AP|phone|tablet)' | sort -u | head -20
ls -la /tmp/cand.adt | cut -c24-
grep -n -E 'device-tree/|adt-set|set-adt|patch-adt|edit-adt|artwork' /mnt/e/DSH-Fuxi/dump/wsl/make-t36*.sh /mnt/e/DSH-Fuxi/dump/wsl/make-t50*.sh 2>/dev/null | cut -c1-190 | head -24
grep -n -E 'product|subtype|artwork|mg|gestalt|MobileGestalt' -i /root/fuxi/t50/args.txt | cut -c1-200 | head
tr ' ' '\n' < /root/fuxi/t50/args.txt | grep -i -E 'product|model|subtype|gestalt|identity|phone' | head
rm -f /tmp/cand.adt
