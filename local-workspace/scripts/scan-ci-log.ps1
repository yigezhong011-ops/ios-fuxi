$f = 'E:\DSH-Fuxi\ci-fail3.txt'
$lines = Get-Content $f
Write-Output ("lines: {0}" -f $lines.Count)
Write-Output "=== Required Fuxi patch failed ==="
$lines | Select-String -Pattern 'Required Fuxi patch failed' | Select-Object -First 2 | ForEach-Object { $_.Line.Trim() }
Write-Output "=== SweetFramebuffer 相关 ==="
$lines | Select-String -Pattern 'SweetFramebuffer' | Select-Object -First 8 | ForEach-Object { $_.Line.Trim().Substring(0,[Math]::Min(200,$_.Line.Trim().Length)) }
Write-Output "=== error: 行（最后 10 条）==="
$lines | Select-String -Pattern 'error:' | Select-Object -Last 10 | ForEach-Object { $_.Line.Trim().Substring(0,[Math]::Min(200,$_.Line.Trim().Length)) }
