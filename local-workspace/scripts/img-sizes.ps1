# Read-only: kernel section size in each boot image's header, to compare images that hang with images that boot.
foreach ($n in 't50-auto-storefix','t50-auto-big','t50-auto-load','t50-auto-load-big','t50-auto-hanghigh','t50-auto-marker','t50-auto-marker2','t50-auto-marker4','t50-auto-cpu','t50-auto-cpu2','t50-mine-gpu-fix','t50-auto-120clock-p') {
  $p = "E:\DSH-Fuxi\$n.img"
  if (-not (Test-Path $p)) { "$n missing"; continue }
  $s = [IO.File]::OpenRead($p); $b = New-Object byte[] 12; [void]$s.Read($b, 0, 12); $s.Close()
  '{0,-22} kernel section 0x{1:x} file {2}' -f $n, [BitConverter]::ToUInt32($b, 8), (Get-Item $p).Length
}
