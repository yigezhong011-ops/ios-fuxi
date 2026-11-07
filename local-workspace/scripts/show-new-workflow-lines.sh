#!/bin/bash
set -uo pipefail
cd /root/fuxi/uni-fork || exit 1
awk 'NR>=272 && NR<=298 {printf "%4d| %s\n", NR, $0}' .github/workflows/macos.yml
