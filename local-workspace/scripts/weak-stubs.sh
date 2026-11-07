#!/bin/bash
# Make every stub weak: the bootstrap link needs them, and once the archives are
# built their strong definitions must win instead of colliding.
set -euo pipefail
W=/tmp/stubgen6
rm -rf "$W"; mkdir -p "$W"
cat > "$W/stubs.c" <<'EOF'
/* Weak link stubs for the fuxi port. The bootstrap link runs before the board
 * archives exist, so it needs these; once the archives are built their strong
 * definitions take precedence. */

#define WEAK __attribute__((weak))

WEAK int   native_owner_root_accepted = 0;
WEAK unsigned int native_touch_edge_stats[4] = {0, 0, 0, 0};
WEAK unsigned int native_ufs_integrity_failures = 0;
WEAK unsigned int native_ufs_blocks_published = 0;
WEAK unsigned long long native_ufs_verified_blocks = 0;
WEAK unsigned long long native_ufs_verify_ticks = 0;
WEAK unsigned long long native_ufs_read_ticks = 0;
WEAK unsigned long long native_virtio_verified_blocks = 0;
WEAK int boot_log_crash_collect() { return 0; }

WEAK int NativeAdrenoGpuContextPagetable(unsigned long long *ttbr0, unsigned int *asid) {
    if (ttbr0) *ttbr0 = 0;
    if (asid) *asid = 0;
    return 0;
}
EOF

CC=/opt/unixnu-linux/llvm/bin/clang
AR=/opt/unixnu-linux/CommandLineTools/usr/bin/ar
$CC -target arm64-apple-ios17.0 -mkernel -O2 -c "$W/stubs.c" -o "$W/stubs.o"
$AR rcs "$W/libFuxiLinkStubs.a" "$W/stubs.o"
ls -l "$W/libFuxiLinkStubs.a"

cd /root/fuxi/fork-device
git fetch -q origin old
git reset -q --hard origin/old
cp "$W/libFuxiLinkStubs.a" package/libFuxiLinkStubs.a
git add -f package/libFuxiLinkStubs.a
git -c user.name=dsh -c user.email=dsh@local commit -q -m "package: make the link stubs weak so real archives win"
git push -q origin old
echo "已推送（归档）"
