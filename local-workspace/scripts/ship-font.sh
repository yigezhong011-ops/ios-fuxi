#!/bin/bash
# The payload's panic-screen patch needs the UEFI repo's Font.h, which CI does not
# check out: ship it with the port and put it where the script looks.
set -euo pipefail
DEV=/root/fuxi/fork-device
SRC=/mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi/Silicon/Silicium/SiliciumPkg/Library/FrameBufferSerialPortLib/Font.h
cd "$DEV"
git fetch -q origin old
git reset -q --hard origin/old

REL=uefi-fonts/Silicon/Silicium/SiliciumPkg/Library/FrameBufferSerialPortLib
mkdir -p "$REL"
cp "$SRC" "$REL/Font.h"
ls -l "$REL/Font.h"

git add -f "$REL/Font.h"
git -c user.name=dsh -c user.email=dsh@local commit -q -m "package: ship the UEFI frame-buffer font the payload patch needs"
git push -q origin old
echo "已推送"
