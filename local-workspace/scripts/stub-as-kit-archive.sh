#!/bin/bash
# Put the stub archive in the device repository's package directory, which the
# tree assembly copies to kits/<board.kit>, and point the defconfig at it with the
# {tree} placeholder. No source patch, so no context to drift.
set -uo pipefail
DEV=/root/fuxi/fork-device
cd "$DEV" || exit 1
git checkout -q old
git reset -q --hard origin/old
git pull -q origin old

echo "=== board.kit 与 package 目录 ==="
grep -n '^kit\|\[board\]' -A2 board.toml | head -6
ls -d package 2>/dev/null && ls package | head -5

echo "=== 移除源码补丁 ==="
git rm -q patches/xnu/fuxi-link-stubs.patch 2>/dev/null && echo "  已移除 fuxi-link-stubs.patch"

echo "=== 生成 stub 归档（Mach-O arm64）到 package/ ==="
mkdir -p package
cat > /tmp/stubs.c <<'EOF'
int sheng_pmgr_run(void) { return 0; }
int native_verified_root_probe(void) { return 0; }
int native_verified_block_volume_device(void) { return 0; }
int native_verified_block_root_authorized(void) { return 0; }
int native_gpu_addon_prepare(void) { return 0; }
int native_ram_block_gpu_addon(void) { return 0; }
int native_ram_block_volume_seed(void) { return 0; }
int native_verified_block_manifest_sha384(void) { return 0; }
int native_mobile_graphics_client_probe(void) { return 0; }
int native_owner_publish_boot_manifest(void) { return 0; }
EOF
CC=/opt/unixnu-linux/llvm/bin/clang
AR=/opt/unixnu-linux/llvm/bin/llvm-ar
$CC -target arm64-apple-ios17.0 -mkernel -O2 -c /tmp/stubs.c -o /tmp/stubs.o 2>&1 | head -3
$AR rcs package/libFuxiLinkStubs.a /tmp/stubs.o
file package/libFuxiLinkStubs.a | cut -c1-100
ls -l package/libFuxiLinkStubs.a

echo "=== 更新 defconfig 的归档路径 ==="
python3 - <<'PY'
from pathlib import Path
p = Path('configs/fuxi_gpu_defconfig')
t = p.read_text()
old = 'CONFIG_XNU_EXTRA_LD_ARCHIVES="../../../device/build/fuxi-link-stubs/libFuxiLinkStubs.a"'
new = 'CONFIG_XNU_EXTRA_LD_ARCHIVES="{tree}/kits/sheng/libFuxiLinkStubs.a"'
if new in t:
    print('  已是新路径')
elif old in t:
    p.write_text(t.replace(old, new, 1))
    print('  已改成 {tree}/kits/sheng/libFuxiLinkStubs.a')
else:
    print('  未找到旧行，追加新行')
    p.write_text(t.rstrip() + '\n' + new + '\n')
PY

git add -A
git -c user.name=dsh -c user.email=dsh@local commit -qm "package: ship the link stubs as a kit archive instead of a source patch"
git push -q origin old && echo "已推送"
tail -3 configs/fuxi_gpu_defconfig
