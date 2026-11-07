#!/usr/bin/env python3
"""Fill the modem-related SoC addresses the generator could not read, using the
board's own reserved-memory nodes."""
import subprocess
from pathlib import Path

F = Path('/root/hakios-xnu-kernel/devices/fuxi/soc.args')
text = F.read_text()
add = {
    'soc_cmd_db': '0x81c60000',      # aop_cmd_db_region@81c60000
    'soc_mpss_mem': '0x8a800000',    # mpss_region (reg)
    'modem_ipa_fw_at': '0x9b080000',  # ipa_fw_region@9b080000
    'soc_pas_mpss': '0x4',           # PAS id, same family convention
}
lines = text.splitlines()
have = {l.split('=')[0] for l in lines if '=' in l}
for key, value in add.items():
    if key not in have:
        lines.append('%s=%s' % (key, value))
        print('加入', key, value)

# keep the reference's ordering style: sorted by key
lines = sorted({l for l in lines if l.strip() and not l.startswith('#')})
F.write_text('\n'.join(lines) + '\n')
print('\n'.join(lines))
