#!/bin/bash
# The Linux Darwin toolchain ships shims for xcrun/plutil/codesign but not for
# ditto, which xnu's baseline script uses to copy a directory's contents.
set -euo pipefail
cat > /usr/bin/ditto <<'SH'
#!/bin/sh
# minimal ditto: "ditto SRC DST" copies SRC's contents into DST
if [ "$#" -lt 2 ]; then
  echo "usage: ditto SRC DST" >&2
  exit 64
fi
src=$1
dst=$2
mkdir -p "$dst"
if [ -d "$src" ]; then
  cp -a "$src"/. "$dst"/
else
  cp -a "$src" "$dst"/
fi
SH
chmod +x /usr/bin/ditto
echo "ditto 已安装: $(command -v ditto)"
ditto --help 2>&1 | head -2 || true

# 顺便检查其它可能缺的 macOS 工具
for t in ditto xcrun plutil codesign lipo mig iig lzfse; do
  printf '%-10s %s\n' "$t" "$(command -v $t 2>/dev/null || echo '缺失')"
done
