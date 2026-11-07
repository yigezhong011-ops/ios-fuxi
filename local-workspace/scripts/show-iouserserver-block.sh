#!/bin/bash
set -uo pipefail
F=/root/ux2/fuxi/tree/.cache/xnu-work/iokit/Kernel/IOUserServer.cpp
awk 'NR>=638 && NR<=692 {printf "%3d| %s\n", NR, $0}' "$F"
