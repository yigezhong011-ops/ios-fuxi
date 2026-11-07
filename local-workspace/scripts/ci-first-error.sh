#!/bin/bash
# The 30 lines before the first "##[error]" of a unixnu-ci run's job log. Usage: ci-first-error.sh <run-id>
bash /root/fuxi/crl.sh "$1" >/dev/null 2>&1
E=$(grep -n '##\[error\]' /root/fuxi/ci-job.log | head -1 | cut -d: -f1)
[ -n "$E" ] && sed -n "$((E-30)),${E}p" /root/fuxi/ci-job.log | cut -c30-260
