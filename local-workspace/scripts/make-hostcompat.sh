#!/bin/bash
# The portability patch makes XNU's host tools include
# $(HOST_SDKROOT)/usr/include/compat/hostcompat.h and link -lhostcompat, but
# nothing in either toolchain ships them. Supply them from the pieces we do
# have: UniXNU's unixnu-host-prefix.h (the Darwin-isms shim) plus glibc/libbsd
# (which already provide setmode/getmode/strlcpy).
set -euo pipefail
TREE=/root/ux-out/fuxi/tree
SDK=$TREE/.cache/fakeroot
INC=$SDK/usr/include/compat
LIB=$SDK/usr/lib
mkdir -p "$INC" "$LIB"

SRC=/opt/unixnu-linux/CommandLineTools/SDKs/MacOSX.sdk/usr/include/unixnu-host-prefix.h
[ -f "$SRC" ] || { echo "缺 unixnu-host-prefix.h"; exit 1; }

cat > "$INC/hostcompat.h" <<'H'
/* Darwin-isms xnu's SETUP host tools need on glibc. */
#ifndef _HOSTCOMPAT_H_
#define _HOSTCOMPAT_H_

#include <bsd/unistd.h>          /* setmode(3) / getmode(3) */
#include <bsd/string.h>          /* strlcpy(3) / strlcat(3) */

#ifndef __APPLE__
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

static inline const char *getprogname(void)
{
	extern char *program_invocation_short_name;
	return program_invocation_short_name;
}

static inline void setprogname(const char *name)
{
	(void)name;
}
#endif

#endif
H

# 空兼容库（符号由 glibc/libbsd 提供；-lhostcompat 只需要能被找到）
WORK=$(mktemp -d)
printf 'int __unixnu_hostcompat_placeholder = 0;\n' > "$WORK/h.c"
cc -c "$WORK/h.c" -o "$WORK/h.o"
ar rcs "$LIB/libhostcompat.a" "$WORK/h.o"
rm -rf "$WORK"

echo "已生成:"
ls -l "$INC/hostcompat.h" "$LIB/libhostcompat.a"
