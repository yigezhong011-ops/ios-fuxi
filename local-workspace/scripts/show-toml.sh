#!/bin/bash
# The payload toml without its args line, its cluster size and file size (room to grow in place), and the msgbuf start.
export MTOOLS_SKIP_CHECK=1
V=${1:-/root/fuxi/t36-bl2-usb/vol.img}
mtype -i $V ::/EFI/UniXNU/unixnu.toml | sed -E 's/args = "[^"]*"/args = <...>/'
minfo -i $V :: | grep -iE 'sectors per cluster|bytes per sector|sector size'
D=$(ls -d /root/fuxi/logs-usb/*/ | head -1)
echo "### msgbuf starts"; tr -d '\0' < ${D}msgbuf.txt | head -2 | cut -c1-120
