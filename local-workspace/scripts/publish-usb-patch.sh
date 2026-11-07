#!/bin/bash
# Copy the deliverable (patch + write-up) to E: and publish it in the progress repo.
set -uo pipefail
E=/mnt/e/DSH-Fuxi
D=$E/PATCH-fuxi-usb-power
mkdir -p "$D"
cp /root/fuxi/patches/0001-fuxi-usb-power.patch "$D/"
cp /root/fuxi/patches/0002-unixnupkg-log-kit.patch "$D/" 2>/dev/null || true
cp "$E/PATCH-fuxi-usb-power.md" "$D/README.md"
ls -l "$D"
echo
echo "=== 补丁能在干净树上应用吗（dry run）==="
git -C /root/build/uefi-fuxi stash list >/dev/null 2>&1 || true
git -C /root/build/uefi-fuxi apply --reverse --check "$D/0001-fuxi-usb-power.patch" && echo "  反向检查通过（补丁与当前树一致）" || echo "  反向检查失败"
