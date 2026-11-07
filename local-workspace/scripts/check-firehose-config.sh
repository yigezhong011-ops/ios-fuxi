#!/bin/bash
set -uo pipefail
echo "=== iOS 16 profile 的 configs ==="
ls /root/fuxi/uni-star/profiles/os/ios-16.7.16-20H392/configs/
echo
echo "=== ios.config 里的 firehose / log ==="
grep -n -i 'firehose\|CONFIG_LOG\|stackshot' /root/fuxi/uni-star/profiles/os/ios-16.7.16-20H392/configs/ios.config | head -10 | cut -c1-140
echo
echo "=== 对照 iPadOS 17 的 ios.config ==="
grep -n -i 'firehose' /root/fuxi/uni-star/profiles/os/ipados-17.7.11-21H461/configs/ios.config 2>/dev/null | head -6 | cut -c1-140
echo
echo "=== arch common.config 里的 firehose ==="
find /root/fuxi/uni-star -name 'common.config' -path '*arch*' | head -2 | while read f; do echo "--- $f"; grep -n -i 'firehose' "$f" | head -6 | cut -c1-140; done
