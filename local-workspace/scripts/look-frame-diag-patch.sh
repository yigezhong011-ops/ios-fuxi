#!/bin/bash
# Read only: the start of the suspect patch, a git apply test of it in an empty repo, and how the recorded patches are validated.
U=/root/fuxi/up-latest; B=origin/feat/metal2vulkan-963f0e64
git -C $U show $B:patches/mesa/turnip-frame-diagnostics.patch > /tmp/fd.patch
head -5 /tmp/fd.patch | cut -c1-80
grep -nE '^(diff --git|--- |\+\+\+ )' /tmp/fd.patch | cut -c1-90 | head -20
rm -rf /tmp/fdt; mkdir /tmp/fdt; git -C /tmp/fdt init -q; git -C /tmp/fdt apply --include='nothing' /tmp/fd.patch; echo "apply with exclude-all rc=$?"
git -C /tmp/fdt apply --check /tmp/fd.patch 2>&1 | head -3 | cut -c1-100
git -C $U log -3 --format='%h %ad %s' --date=short $B -- patches/mesa/turnip-frame-diagnostics.patch | cut -c1-100
git -C $U show $B:scripts/build-boot-runtime.py | grep -n 'validate_recorded_patches' | head -3
git -C $U grep -n 'def validate_recorded_patches' $B -- scripts | cut -c1-110
f=$(git -C $U grep -l 'def validate_recorded_patches' $B -- scripts | head -1 | sed "s#^$B:##"); git -C $U show $B:$f | sed -n "/def validate_recorded_patches/,/^def [a-z_]*(/p" | head -40 | cut -c1-120
