#!/usr/bin/env python3
import pathlib
src = pathlib.Path('/mnt/e/DSH-Fuxi/dump/wsl/mesa-ios-build.sh').read_text()
anchor = '''# the libdrm stand-in lives inside the tree, named as the freedreno-darwin patch expects
rm -rf mesa-$VERSION/src/redwood-drm
cp -r "$KIT"/fuxi-drm mesa-$VERSION/src/redwood-drm
'''
print('anchor found:', anchor in src)
# show the region char by char for the first occurrence
i = src.find('# the libdrm stand-in')
print(repr(src[i:i + len(anchor) + 10]))
