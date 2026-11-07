#!/bin/bash
# Which scripts (UniXNU and the device repository) need a prelinked reference candidate, and the default paths they look in.
for d in /root/fuxi/ux/scripts /root/fuxi/ux-device/scripts; do
  echo "### $d"
  echo "build-sheng-platform-power.py runs:"; grep -nE "run\(\[" $d/build-sheng-platform-power.py 2>/dev/null | cut -c1-160
  for f in $(grep -l 'No reference candidate available' $d/*.py); do
    echo "-- $(basename $f)"; grep -nE "candidate\.macho'|prelink'\)\.glob" $f | cut -c1-200
  done
done
