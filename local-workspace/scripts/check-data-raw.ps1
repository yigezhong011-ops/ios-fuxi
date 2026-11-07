# Read-only: is the Data copy aligned with the phone's window? The store head must sit at file block 1024, the APFS container at block 1153.
$p = 'E:\DSH-Fuxi\logs\data-raw.img'
$l = (Get-Item $p).Length
"len $l extra " + ($l - 17179869184)
$fs = [IO.File]::OpenRead($p)
$b = New-Object byte[] 8
[void]$fs.Seek(1024 * 4096, 'Begin'); [void]$fs.Read($b, 0, 8)
'at block 1024: ' + [Text.Encoding]::ASCII.GetString($b)
$c = New-Object byte[] 4
[void]$fs.Seek(1153 * 4096 + 32, 'Begin'); [void]$fs.Read($c, 0, 4)
'at block 1153+32: ' + [Text.Encoding]::ASCII.GetString($c)
$t = New-Object byte[] 93
[void]$fs.Seek(17179869184, 'Begin'); [void]$fs.Read($t, 0, 93)
'tail: ' + ([Text.Encoding]::ASCII.GetString($t) -replace '[^\x20-\x7e]', '.')
$fs.Close()
(Get-Date).ToString('HH:mm:ss')
& 'E:\DSH-Fuxi\tools\platform-tools\fastboot.exe' devices | Measure-Object | ForEach-Object { 'fastboot ' + $_.Count }
'E free GB ' + [math]::Round((Get-PSDrive E).Free / 1GB, 1)
