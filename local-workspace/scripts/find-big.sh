#!/bin/bash
# Large files in WSL that could be a UniXNU userdata image or its pieces (OS/SystemOS dmg, manifest).
find /root /home /tmp -xdev -type f -size +300M -printf '%s %TY-%Tm-%Td %p\n' 2>/dev/null | sort -k3 | awk '{printf "%8.2f GB  %s  %s\n", $1/1073741824, $2, $3}' | head -40
