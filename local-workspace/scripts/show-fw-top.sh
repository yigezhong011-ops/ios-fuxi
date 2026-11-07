#!/bin/bash
set -uo pipefail
awk 'NR<=27 {printf "%4d| %s\n", NR, substr($0,1,150)}' /root/fw-full.log
