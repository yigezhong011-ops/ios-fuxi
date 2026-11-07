#!/bin/bash
# Fetch a run's job log and print the audit-edit lines plus the 30 lines before the last "unixnu: ... failed". Usage: <run-id>
bash /root/fuxi/crl.sh "$1" >/dev/null 2>&1
L=/root/fuxi/ci-job.log
grep -nE 'audit-amfi-pmgr-contract.py: ' $L | cut -c1-200
N=$(grep -n 'unixnu: .*failed' $L | tail -1 | cut -d: -f1)
[ -n "$N" ] && sed -n "$((N-30)),${N}p" $L | cut -c30-260
