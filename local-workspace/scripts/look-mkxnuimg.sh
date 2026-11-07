#!/bin/bash
set -uo pipefail
cd /root/hackios
echo "=== XnuLoader 文件在哪 ==="
find . -name 'XnuLoader*' 2>/dev/null
echo
echo "=== mkxnuimg.py ==="
sed -n '1,60p' mkxnuimg.py
