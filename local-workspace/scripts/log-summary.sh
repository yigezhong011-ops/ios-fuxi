#!/bin/bash
# Key state of the newest snapshot of a decoded sheng log: Data store, clients, scanout, swaps, and the msgbuf tail without repeats.
D=$(ls -d "$1"/*/ | head -1)
L=$D/latest.txt
grep -E '^(D st=|X3|X5|prepare calls|\[gpu clients\]|\[metal askers\]|T pipeline|W[0-9]+ t=|\[scanout wait\]|PR )' $L | head -20 | cut -c1-200
echo "### msgbuf (repeats collapsed)"
tr -d '\0' < $D/msgbuf.txt | sed -E 's/^\[ *[0-9.]+\]: //; s/[0-9]+/N/g' | uniq -c | tail -25 | cut -c1-200
