# Sweeps the unlock swipe's start height and speed in one boot and logs the screen's encoded size after each. Unattended, temp boot only.
param([string]$Name = 't50-auto-gpu7tap')
$s = @('at 110', 'probe start')
foreach ($d in 120, 350) {
  foreach ($y in 799, 795, 785, 775, 765, 755) {
    $s += "swipe 180 $y 180 300 $d"; $s += 'wait 2'; $s += "probe y$y-d$d"
    # Leaves the search screen if a swipe opened it; x=180 y=130 is the gap between the two desktop widgets.
    $s += 'tap 180 130'; $s += 'wait 1'; $s += "probe after-y$y-d$d"
  }
}
$s += 'shot end'
& E:\DSH-Fuxi\dump\wsl\ctl-run.ps1 -Name $Name -Steps ($s -join ';')
