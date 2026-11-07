#!/bin/bash
# Context of the "no linear image" path in upstream AdrenoMetal main, and the user-client version checks.
W=/root/fuxi/upstream-am; mkdir -p $W; cd $W
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
get() { curl -fsSL -H "Authorization: Bearer $TOKEN" "https://raw.githubusercontent.com/UniXNU/AdrenoMetal/main/$1" -o "$(basename $1)"; }
get NativeBridgeMetalFrontend.mm
get NativeAdrenoMetalPlugin.mm
wc -l *.mm
echo "### no linear image"
grep -n -B30 -A12 'no linear image' NativeBridgeMetalFrontend.mm | head -80
echo "### version / abi checks in plugin"
grep -n -iE 'abiversion|kVersion|protocol version|interface version|kNativeAdreno.*Version|version mismatch' NativeAdrenoMetalPlugin.mm NativeBridgeMetalFrontend.mm | head -20
