#!/bin/bash
L=/root/fuxi/wall1/new.txt
sed -n 14318,14332p $L | cut -c1-420; echo ====; sed -n 54700,54722p $L | cut -c1-300
echo ==== AVE; grep -n 'AVE' $L | cut -c1-260
echo ==== public.heic; grep -n 'public.heic' $L | head -8 | cut -c1-300
echo ==== CMPhoto; grep 'CMPhoto' $L | cut -c1-120 | sort | uniq -c | sort -rn | head -10
echo ==== encoder; grep -n -i -E 'encoder|videotoolbox' $L | grep -v VTCompressionSessionClient | cut -c1-260 | head -20
echo ==== render; grep -n -i -E 'WidgetRenderer|snapshot.*fail|archiv.*fail|failed to archive|unable to archive' $L | cut -c1-240 | head -30
