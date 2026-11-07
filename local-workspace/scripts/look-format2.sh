#!/bin/bash
set -uo pipefail
cd /root/UniXNU
echo "=========== examples/device/board.toml ==========="
cat examples/device/board.toml
echo
echo "=========== examples/device/porting.toml ==========="
cat examples/device/porting.toml
echo
echo "=========== profiles/arch/arm64/profile.toml ==========="
cat profiles/arch/arm64/profile.toml
