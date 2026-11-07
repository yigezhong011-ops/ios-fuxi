#!/bin/bash
# Rebuild the link stub archive with the symbols the display and boot-progress
# archives reference once the verified-root pieces are off.
set -euo pipefail
W=/tmp/stubgen4
rm -rf "$W"; mkdir -p "$W"
cat > "$W/stubs.c" <<'EOF'
/* Link-only stubs for the fuxi port. These answer symbols whose providers are
 * board components this port does not build (owner-root verification, the touch
 * driver, the Adreno context probe). */

/* the original twelve, from the bootstrap link */
int boot_log_tick(void) { return 0; }
int fuxi_usb_append(void) { return 0; }
void fuxi_usb_debug_start(void) { }
void native_legacy_display_late_probe(void) { }
void native_legacy_display_probe(void) { }
int native_ram_block_gpu_addon(void) { return 0; }
int native_ram_block_volume_seed(void) { return 0; }
int native_verified_block_manifest_sha384(void) { return 0; }
int native_verified_block_root_authorized(void) { return 0; }
int native_verified_block_volume_device(void) { return 0; }
void native_verified_root_probe(void) { }
void sheng_pmgr_run(void) { }

/* referenced once owner-root verification and the verified block variants are off */
int   native_owner_root_accepted = 0;
unsigned int native_touch_edge_stats[4] = {0, 0, 0, 0};
unsigned int native_ufs_integrity_failures = 0;
unsigned int native_ufs_blocks_published = 0;
unsigned long long native_ufs_verified_blocks = 0;
unsigned long long native_ufs_verify_ticks = 0;
unsigned long long native_ufs_read_ticks = 0;
unsigned long long native_virtio_verified_blocks = 0;
int boot_log_crash_collect() { return 0; }

/* the GPU context probe normally comes from the Adreno driver */
int NativeAdrenoGpuContextPagetable(unsigned long long *ttbr0, unsigned int *asid) {
    if (ttbr0) *ttbr0 = 0;
    if (asid) *asid = 0;
    return 0;  /* kIOReturnSuccess-ish: callers treat non-zero as an error */
}
EOF

CC=/opt/unixnu-linux/llvm/bin/clang
AR=/opt/unixnu-linux/CommandLineTools/usr/bin/ar
$CC -target arm64-apple-ios17.0 -mkernel -O2 -c "$W/stubs.c" -o "$W/stubs.o"
file "$W/stubs.o" | cut -c1-100
$AR rcs "$W/libFuxiLinkStubs.a" "$W/stubs.o"
ls -l "$W/libFuxiLinkStubs.a"

cp "$W/libFuxiLinkStubs.a" /root/fuxi/fork-device/package/libFuxiLinkStubs.a
cd /root/fuxi/fork-device
git fetch -q origin old
git reset -q --hard origin/old
cp "$W/libFuxiLinkStubs.a" package/libFuxiLinkStubs.a
git add -f package/libFuxiLinkStubs.a
git -c user.name=dsh -c user.email=dsh@local commit -q -m "package: extend the link stubs to the verified-root and touch symbols"
git push -q origin old
echo "已推送"
