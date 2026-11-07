#!/bin/bash
set -uo pipefail
F=/root/fuxi/fork-device/scripts/build-boot-progress.py
awk 'NR>=44 && NR<=56 {printf "%3d|%s\n", NR, $0}' "$F"
