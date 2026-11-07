#!/bin/bash
# Keep the Linux-only portability patches off the branch CI builds: they assume
# the Linux toolchain's iig output and the shimmed host build.
set -uo pipefail
DEV=/root/fuxi/fork-device
cd "$DEV" || exit 1
git fetch -q origin
git checkout -q old
git reset -q --hard origin/old

LINUX_ONLY="portable-iig-local-methods.patch linux-host-tools.patch llvm-clang-arm64-crypto-asm.patch portable-kalloc-type-builtins.patch"

echo "=== 保存到 linux 分支 ==="
git checkout -q -B linux
for p in $LINUX_ONLY; do
  [ -f "patches/xnu/$p" ] && echo "  保留 $p"
done
git -c user.name=dsh -c user.email=dsh@local add -A
git -c user.name=dsh -c user.email=dsh@local commit -qm "patches: Linux-only portability patches" 2>/dev/null || true
git push -q -f origin linux && echo "  已推送 linux 分支"

echo "=== 从 old 移除 ==="
git checkout -q old
for p in $LINUX_ONLY; do
  if [ -f "patches/xnu/$p" ]; then
    git rm -q "patches/xnu/$p"
    echo "  移除 $p"
  fi
done
git -c user.name=dsh -c user.email=dsh@local commit -qm "patches: drop the Linux-only patches from the CI branch" 2>/dev/null || true
git push -q origin old && echo "  已推送 old 分支"

echo "=== old 分支现在保留的补丁 ==="
ls patches/xnu/ | grep -E 'fuxi-link-stubs|portable|linux-host|llvm' || echo "  （仅 fuxi-link-stubs）"
ls patches/xnu/ | wc -l
