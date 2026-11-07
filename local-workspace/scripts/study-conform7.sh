#!/bin/bash
# Read-only: exact window around the resourceValuesForKeys call, and every call site of the conform selector stub.
L=$(grep -n '^0x1ca870964' /tmp/pb.txt | cut -d: -f1)
sed -n "$((L-12)),$((L+110))p" /tmp/pb.txt | cut -c1-110
echo "=== callers of stub 0x1caa46c80"
grep -n '0x1caa46c80' /tmp/pb.txt | cut -c1-110 | head -12
echo "=== conform method name hits"
grep -n -E 'ConformToResourceValues|resourceValuesForKeys' /tmp/pb.txt | cut -c1-110 | head -12
