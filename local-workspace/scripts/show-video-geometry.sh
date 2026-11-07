#!/bin/bash
set -uo pipefail
F=/root/ux3/fuxi/tree/drivers/GopFramebuffer/NativeLegacyDisplay.cpp
awk 'NR>=370 && NR<=415 {printf "%4d| %s\n", NR, $0}' "$F" | cut -c1-175
