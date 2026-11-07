#!/bin/bash
# Set up the host toolchain HakiOS needs on Linux: theos with its Linux cctools
# toolchain and the iPhoneOS 16.5 SDK, then build the fuxi kernel.
set -uo pipefail
export THEOS=/root/theos
LOG=/root/hakios-build.log
: > "$LOG"
exec >>"$LOG" 2>&1

echo "=== $(date) 开始 ==="
echo "--- 依赖 ---"
apt-get install -y -q clang lld llvm libplist-2.0-dev libssl-dev libtinfo5 \
  libz3-dev libncurses-dev flex bison m4 autoconf automake libxml2-dev \
  zlib1g-dev libtinfo-dev 2>&1 | tail -5

echo "--- theos ---"
if [ ! -d "$THEOS" ]; then
  git clone -q --recursive --depth 1 https://github.com/theos/theos.git "$THEOS" || echo "theos 克隆失败"
fi
du -sh "$THEOS" 2>/dev/null
ls "$THEOS" 2>/dev/null | head

echo "--- theos SDKs ---"
if [ ! -d "$THEOS/sdks" ] || [ -z "$(ls -A "$THEOS/sdks" 2>/dev/null)" ]; then
  rm -rf "$THEOS/sdks"
  git clone -q --depth 1 https://github.com/theos/sdks.git "$THEOS/sdks" || echo "sdks 克隆失败"
fi
ls "$THEOS/sdks" 2>/dev/null | head -12

echo "--- Linux 工具链 ---"
if [ ! -d "$THEOS/toolchain/linux/iphone" ]; then
  mkdir -p "$THEOS/toolchain/linux"
  git clone -q --depth 1 https://github.com/theos/toolchain-linux-iphone.git "$THEOS/toolchain/linux/iphone" \
    || echo "工具链克隆失败（可能仓库名不同）"
fi
ls "$THEOS/toolchain/linux/iphone/bin" 2>/dev/null | head -8

echo "=== 完成 $(date) ==="
