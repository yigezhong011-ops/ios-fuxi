#!/bin/bash
# The twelve bootstrap symbols live in bsd_init.o (the patch); the archive must
# carry only the symbols that nothing else provides.
set -euo pipefail
W=/tmp/stubgen5
rm -rf "$W"; mkdir -p "$W"
cat > "$W/stubs.c" <<'EOF'
/* Link-only stubs for the fuxi port: symbols whose providers are board
 * components this port does not build (owner-root verification, the touch
 * driver). The bootstrap symbols are defined by the bsd_init.c patch instead. */

int   native_owner_root_accepted = 0;
unsigned int native_touch_edge_stats[4] = {0, 0, 0, 0};
unsigned int native_ufs_integrity_failures = 0;
unsigned int native_ufs_blocks_published = 0;
unsigned long long native_ufs_verified_blocks = 0;
unsigned long long native_ufs_verify_ticks = 0;
unsigned long long native_ufs_read_ticks = 0;
unsigned long long native_virtio_verified_blocks = 0;
int boot_log_crash_collect() { return 0; }

int NativeAdrenoGpuContextPagetable(unsigned long long *ttbr0, unsigned int *asid) {
    if (ttbr0) *ttbr0 = 0;
    if (asid) *asid = 0;
    return 0;
}
EOF

CC=/opt/unixnu-linux/llvm/bin/clang
AR=/opt/unixnu-linux/CommandLineTools/usr/bin/ar
$CC -target arm64-apple-ios17.0 -mkernel -O2 -c "$W/stubs.c" -o "$W/stubs.o"
$AR rcs "$W/libFuxiLinkStubs.a" "$W/stubs.o"
$AR t "$W/libFuxiLinkStubs.a"
$CC -target arm64-apple-ios17.0 -c -x c /dev/null -o /dev/null 2>/dev/null || true
/opt/unixnu-linux/llvm/bin/llvm-nm "$W/stubs.o" 2>/dev/null | head -14 || /usr/bin/nm "$W/stubs.o" | head -14

cd /root/fuxi/fork-device
git fetch -q origin old
git reset -q --hard origin/old
cp "$W/libFuxiLinkStubs.a" package/libFuxiLinkStubs.a
git add -f package/libFuxiLinkStubs.a
git -c user.name=dsh -c user.email=dsh@local commit -q -m "package: keep only the symbols nothing else provides"
git push -q origin old
echo "已推送"
