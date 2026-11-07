#!/bin/bash
# The age key for encrypted CI artifacts: the private key stays in E:\DSH-Fuxi\keys (never committed); prints the public key.
K=/mnt/e/DSH-Fuxi/keys/fuxi-ci-age.key
if ! grep -q '^AGE-SECRET-KEY-' "$K" 2>/dev/null; then
  rm -f "$K"
  age-keygen -o "$K" 2>/dev/null
fi
age-keygen -y "$K"
