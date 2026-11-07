#!/bin/bash
# Run the toolchain bootstrap with C99 for unifdef and keep the full log so a
# failure is visible instead of being swallowed by a pipe.
export CFLAGS="-std=gnu99 -O2"
LOG=/root/bootstrap.log
: > "$LOG"
bash /mnt/e/DSH-Fuxi/unixnu-build/xnu-linux-toolchain/bootstrap.sh >>"$LOG" 2>&1
code=$?
echo "BOOTSTRAP_EXIT=$code"
echo "=== 日志尾部 ==="
tail -30 "$LOG"
echo
echo "=== \$PREFIX/bin ==="
ls "$HOME/.local/xnu-linux/bin" 2>/dev/null
