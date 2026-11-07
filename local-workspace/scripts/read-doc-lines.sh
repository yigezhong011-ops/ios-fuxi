#!/bin/bash
# Read only: full text of the doc lines that bear on the open problems.
U=/root/fuxi/up-latest; B=origin/main; O=/mnt/e/DSH-Fuxi/logs/m2v-read/lines.txt
s() { echo; echo "#### $1:$2"; git -C $U show $B:docs/devices/$1.md | sed -n "$2p" | cut -c1-1900; }
{
s zizhan 709
s asteroids 435
s asteroids 440
s asteroids 431
s asteroids 433
s asteroids 408
s alioth 472
s alioth 476
s alioth 480
s alioth 320
s oneplus13t-shad0w23333 788
} > $O
wc -c $O
echo; echo '== udid-version and chosen seed in our tree'
for d in /mnt/e/DSH-Fuxi/unixnu-build/fuxi /root/fuxi/t50-gpu7; do [ -d "$d" ] && grep -rnIE 'udid-version|unique-chip-id|SerialNumber|WifiAddress|BluetoothAddress' "$d" --include='*.toml' --include='*.dts*' --include='*.json' 2>/dev/null | sed -E 's/0x[0-9a-fA-F]{12,}/<id>/g' | cut -c1-140 | head -8; done
export MTOOLS_SKIP_CHECK=1; mtype -i /root/fuxi/t50-gpu7/vol.img ::/EFI/UniXNU/unixnu.toml 2>/dev/null | grep -nE 'udid|serial-number|\[adt' | sed -E 's/0x[0-9a-fA-F]{12,}/<id>/g' | cut -c1-120 | head -10
git -C /root/fuxi/up-latest grep -n -E 'udid-version|ChipID-ECID' $B -- docs/porting scripts | cut -c1-200 | head -8
