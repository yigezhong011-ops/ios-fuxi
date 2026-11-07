#!/bin/bash
# Prepare our fork (yigezhong011-ops/fuxi-touch) to run OddlyLabs' own image job (.github/workflows/build.yml):
# upstream main (panic_screen = true, firmware + v0 boot image) with the CI artifact encrypted to OUR key.
# The private key stays on E: (/mnt/e/DSH-Fuxi/keys); only the public key is committed.
set -euo pipefail
cd /root/fuxi/fuxi-ours
KEYS=/mnt/e/DSH-Fuxi/keys
mkdir -p "$KEYS"
if [ ! -f "$KEYS/boot-image-private.pem" ]; then
  openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:4096 -out "$KEYS/boot-image-private.pem"
fi
openssl pkey -in "$KEYS/boot-image-private.pem" -pubout -out "$KEYS/boot-image-recipient.pem"

git fetch origin
git switch -c image-ours origin/main
cp "$KEYS/boot-image-recipient.pem" ci/boot-image-recipient.pem
grep -n 'panic_screen' board.toml
git -c user.name=yigezhong011-ops -c user.email=yigezhong011-ops@users.noreply.github.com \
  commit -am "ci: encrypt the boot image to our own key"
git push mine image-ours
git log --oneline -3
