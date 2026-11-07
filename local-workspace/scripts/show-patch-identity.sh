#!/bin/bash
# mesa_patch_identity.py at 793d: how the patch list is validated. Read-only.
cd /root/fuxi/src-unixnu; R=793d6bddf7ea90678e3a61e2b2bd4350e5fdce16
git show $R:scripts/mesa_patch_identity.py | cut -c1-170
echo "== users of the patch list"
git show $R:scripts/build-turnip-darwin.py | sed -n 25,40p | cut -c1-170
