#!/bin/bash
set -euo pipefail
RAW=/root/fuxi/root-patch.raw
M=/root/fuxi/mnt/gltest
ART=/mnt/e/DSH-Fuxi/gles-stack
OUT=/mnt/e/DSH-Fuxi/gles-root3.simg

mkdir -p "$M"
for m in $(mount | awk '/hfsplus/{print $3}'); do umount -l "$m" 2>/dev/null || true; done
mount -t hfsplus -o loop,force,rw "$RAW" "$M"

echo "=== 1) 还原原始 backboardd（这个镜像不测桥注入）==="
cp /root/fuxi/backboardd.orig "$M/usr/libexec/backboardd"
chown 0:0 "$M/usr/libexec/backboardd"
chmod 755 "$M/usr/libexec/backboardd"

echo "=== 2) 装 GL 测试程序 ==="
mkdir -p "$M/usr/local/bin" "$M/redwood"
cp "$ART/fuxi_gl_test" "$M/usr/local/bin/fuxi_gl_test"
chown 0:0 "$M/usr/local/bin/fuxi_gl_test"
chmod 755 "$M/usr/local/bin/fuxi_gl_test"

echo "=== 3) launchd job（开机跑一次）==="
cat > "$M/System/Library/LaunchDaemons/com.fuxi.gltest.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>com.fuxi.gltest</string>
	<key>ProgramArguments</key>
	<array>
		<string>/usr/local/bin/fuxi_gl_test</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
	<key>KeepAlive</key>
	<false/>
	<key>ThrottleInterval</key>
	<integer>600</integer>
	<key>UserName</key>
	<string>root</string>
	<key>StandardOutPath</key>
	<string>/redwood/gl-test.out</string>
	<key>StandardErrorPath</key>
	<string>/redwood/gl-test.err</string>
</dict>
</plist>
PLIST
chown 0:0 "$M/System/Library/LaunchDaemons/com.fuxi.gltest.plist"
chmod 644 "$M/System/Library/LaunchDaemons/com.fuxi.gltest.plist"
ls -l "$M/System/Library/LaunchDaemons/com.fuxi.gltest.plist" "$M/usr/local/bin/fuxi_gl_test"

echo "=== 4) 卸载 + 修卷头 ==="
sync
umount "$M"
python3 - "$RAW" <<'PY'
import struct, sys
p = sys.argv[1]
with open(p, 'r+b') as f:
    f.seek(1024 + 8)
    cur = f.read(4)
    if cur != b'HFSJ':
        f.seek(1024 + 8); f.write(b'HFSJ'); print('卷头 %r -> HFSJ' % cur)
    f.seek(1024 + 4)
    attr = struct.unpack('>I', f.read(4))[0]
    if not attr & 0x100:
        f.seek(1024 + 4); f.write(struct.pack('>I', attr | 0x100)); print('置未挂载位')
PY
fsck.hfsplus -f -y "$RAW" 2>&1 | tail -2

echo "=== 5) 转稀疏镜像 ==="
rm -f "$OUT"
img2simg "$RAW" "$OUT"
ls -lh "$OUT"
echo GLTEST_ROOT_OK
