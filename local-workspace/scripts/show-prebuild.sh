#!/bin/bash
# The pre-build script of the 11-01 CI run (saved job log), timestamps stripped.
L=$(grep -n 'Run pre-build steps' /root/fuxi/job.log | head -1 | cut -d: -f1)
sed -n "${L},$((L+50))p" /root/fuxi/job.log | sed 's/^[^Z]*Z //; s/\x1b\[[0-9;]*m//g'
