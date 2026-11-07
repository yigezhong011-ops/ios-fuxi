$f = 'E:\DSH-Fuxi\unixnu\fail2.log'
$lines = Get-Content $f
Write-Output ("lines: {0}" -f $lines.Count)
Write-Output "=== ##[error] 和 sed / DEVICE_DIR 相关 ==="
$lines | Select-String -Pattern '##\[error\]|sed:|DEVICE_DIR|fuxi_defconfig|BOOT_PROGRESS|No such file' |
  Select-Object -Last 15 | ForEach-Object { $_.Line.Trim().Substring(0,[Math]::Min(220,$_.Line.Trim().Length)) }
