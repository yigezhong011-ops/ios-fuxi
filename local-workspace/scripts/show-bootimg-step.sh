#!/bin/bash
set -uo pipefail
F=/root/dev-odd/.github/workflows/build.yml
echo "=== Pack the boot image 那一步 ==="
awk '/Pack the boot image/,/Encrypt the boot image/' "$F" | head -20 | cut -c1-170
