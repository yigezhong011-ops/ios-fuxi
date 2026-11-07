#!/bin/bash
# unifdef's source uses "constexpr" as an identifier, which C23 turned into a
# keyword. Add -std=gnu99 to its Makefile so the pinned source still builds.
set -euo pipefail
MK=$HOME/.local/xnu-linux/src/unifdef/Makefile
[ -f "$MK" ] || { echo "找不到 $MK"; exit 1; }
if grep -q 'std=gnu99' "$MK"; then
  echo "已经加过 -std=gnu99"
else
  sed -i 's/^CFLAGS=/CFLAGS=-std=gnu99 /' "$MK"
  echo "已修改 CFLAGS"
fi
grep -n '^CFLAGS' "$MK" | head -3
