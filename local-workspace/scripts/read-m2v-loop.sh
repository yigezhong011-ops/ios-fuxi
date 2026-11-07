#!/bin/bash
# Read only: the old report thread, and how the branch's render server start continues.
cd /root/fuxi/m2v-deep; N=a/NativeAdrenoMetalPlugin.mm
sed -n 425,490p old.mm | cut -c1-140
echo ======
grep -n -E 'pthread_create|std::thread|streamText|sleep\(|usleep|gpu->mark\(|g->mark\(|detach' $N | cut -c1-130
echo ======
n=$(grep -n 'CA_ALLOW_EDR_MIRRORING", "0"' $N | cut -d: -f1); sed -n "$((n+1)),$((n+12))p" $N | cut -c1-120
echo ...; sed -n "$((n+40)),$((n+110))p" $N | cut -c1-120
