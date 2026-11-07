#!/bin/bash
# Build the stub archive with the cctools archiver and commit it.
set -uo pipefail
DEV=/root/fuxi/fork-device
cd "$DEV" || exit 1

CC=/opt/unixnu-linux/llvm/bin/clang
AR=/opt/unixnu-linux/CommandLineTools/usr/bin/ar
mkdir -p package

$CC -target arm64-apple-ios17.0 -mkernel -O2 -c /tmp/stubs.c -o /tmp/stubs.o
echo "目标文件:"; file /tmp/stubs.o | cut -c1-110
$AR rcs package/libFuxiLinkStubs.a /tmp/stubs.o
echo "归档:"; file package/libFuxiLinkStubs.a | cut -c1-110
ls -l package/libFuxiLinkStubs.a
echo "成员:"; $AR t package/libFuxiLinkStubs.a

git add -A
git -c user.name=dsh -c user.email=dsh@local commit -qm "package: add the link stub archive built for arm64 Mach-O"
git push -q origin old && echo "已推送"
