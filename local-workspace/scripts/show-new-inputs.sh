#!/bin/bash
set -uo pipefail
cd /root/fuxi/uni-fork || exit 1
awk '/workflow_dispatch:/{flag=1} flag{print} /^jobs:/{if(flag) exit}' .github/workflows/macos.yml | head -45 | cut -c1-130
