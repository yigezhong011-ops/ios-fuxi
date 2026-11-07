#!/bin/bash
# Boot args of the source volume and of gpu4's payload; source volume timestamp.
export MTOOLS_SKIP_CHECK=1
ls -l --time-style=full-iso /root/fuxi/t32/vol.img | cut -c30-
echo "--- vol.img";  mtype -i /root/fuxi/t32/vol.img ::/EFI/UniXNU/unixnu.toml | grep -o 'args = "[^"]*"'
echo "--- gpu4";     mtype -i /root/fuxi/chk-gpu4/vol.img ::/EFI/UniXNU/unixnu.toml | grep -o 'args = "[^"]*"'
