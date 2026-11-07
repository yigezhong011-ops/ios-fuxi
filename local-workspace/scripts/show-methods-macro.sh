#!/bin/bash
set -uo pipefail
H=/root/ux2/fuxi/tree/build/xnu/ios-obj/DEVELOPMENT_ARM64_BCM2837/iokit/DEVELOPMENT/DriverKit/IOService.h
awk 'NR>=935 && NR<=965 {printf "%4d| %s\n", NR, $0}' "$H"
