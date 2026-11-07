#!/bin/bash
set -uo pipefail
cd /root/fuxi/fork-device
awk 'NR>=140 && NR<=180 {printf "%4d| %s\n", NR, $0}' board.toml | cut -c1-170
