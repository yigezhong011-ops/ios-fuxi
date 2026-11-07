$f = 'E:\DSH-Fuxi\unixnu\fail1.log'
$lines = Get-Content $f
Write-Output ("lines: {0}" -f $lines.Count)
Write-Output "=== error / fail 行 ==="
$lines | Select-String -Pattern 'error|Error|ERROR|fatal|failed|FAIL|Traceback|not found|missing' |
  Select-Object -Last 25 | ForEach-Object { $_.Line.Trim().Substring(0,[Math]::Min(220,$_.Line.Trim().Length)) }
Write-Output "=== 最后 30 行 ==="
$lines[([Math]::Max(0,$lines.Count-30))..($lines.Count-1)] | ForEach-Object { $_.Trim().Substring(0,[Math]::Min(220,$_.Trim().Length)) }
