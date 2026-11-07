#!/bin/bash
# Files of the t32 payload volume, and how the owner trust module is checked.
export MTOOLS_SKIP_CHECK=1
mdir -/ -i /root/fuxi/t32/vol.img ::/EFI | grep -vE '^\s*$' | head -40
echo "### owner trust in UniXNU scripts"
grep -n -iE 'sign|key|ed25519|rsa|ecdsa|verify' /mnt/e/DSH-Fuxi/unixnu-build/unixnu/scripts/make-owner-trust-bundle.py | head -30
