#!/bin/bash
# Read-only: the prepared flat 7570 animation: what it references and how it lays the images out; the image sizes; how Bokeh's addon entries looked.
O=/mnt/e/DSH-Fuxi/wallpaper-overlay
python3 -I - <<'PY'
import re, struct
t = open('/mnt/e/DSH-Fuxi/wallpaper-overlay/main.caml').read()
print(len(t)); print(t[:900])
print('refs', sorted(set(re.findall(r'"([^" ]*\.(?:png|PNG|HEIC|jpg))"', t))))
print('bounds', Counter if False else sorted(set(re.findall(r'bounds="([^"]+)"', t)))[:14])
print('position', sorted(set(re.findall(r'position="([^"]+)"', t)))[:12])
print('states', sorted(set(re.findall(r'<LKState name="([^"]+)"', t)))[:20])
print('gravity', sorted(set(re.findall(r'contentsGravity="([^"]+)"', t)))[:6])
for n in ('J120-q92.jpg', 'J120.png'):
    b = open('/mnt/e/DSH-Fuxi/wallpaper-overlay/' + n, 'rb').read()
    if n.endswith('png'):
        print(n, struct.unpack('>II', b[16:24]))
    else:
        i = 2
        while i < len(b):
            m = b[i + 1]; l = struct.unpack('>H', b[i + 2:i + 4])[0]
            if m in (0xC0, 0xC2):
                print(n, struct.unpack('>HH', b[i + 5:i + 9])[::-1]); break
            i += 2 + l
PY
cat $O/index.xml | head -30 | cut -c1-120
cat $O/assetManifest.caml | cut -c1-200
which convert magick 2>/dev/null; python3 -c 'import PIL; print("PIL", PIL.__version__)' 2>&1 | tail -1
