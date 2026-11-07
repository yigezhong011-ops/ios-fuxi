#!/usr/bin/env python3
"""Patch 0115 v2: inline RPMh/cmd-db dump in ft_thread, one small hunk."""
import difflib, re, subprocess, tempfile, pathlib

anchor = '''	printf("FUXI TOUCH: starting in %u s (poll %u us active, %u us idle)\\n", delay_s,
	    poll_us, idle_us);
'''

block = r'''	{
		/* RPMh: the controller's iovdd (ldob12) and avdd (ldom6) are VRM
		 * resources named in the bootloader's cmd-db; the APPS RSC carries
		 * the command. Print what the tables actually contain first. */
		#define FUXI_DB_PHYS	0x81c60000UL
		#define FUXI_DB_SIZE	0x20000UL
		#define FUXI_RSC_PHYS	0x17a00000UL
		typedef struct { uint16_t id, header_offset, data_offset, count, version, rsv[3]; } db_slave_t;
		typedef struct { uint32_t version; uint8_t magic[4]; db_slave_t slave[8]; uint32_t checksum, rsv; } db_header_t;
		typedef struct { char id[8]; uint32_t prio[2]; uint32_t address; uint16_t length, offset; } db_entry_t;
		const db_header_t *db = (const db_header_t *)ml_io_map_wcomb(FUXI_DB_PHYS, FUXI_DB_SIZE);
		uint32_t iovdd = 0, avdd = 0;
		volatile uint32_t *rsc;

		if (db != NULL && db->magic[0] == 0xdb && db->magic[1] == 0x30 &&
		    db->magic[2] == 0x03 && db->magic[3] == 0x0c) {
			for (unsigned s = 0; s < 8; s++) {
				const db_slave_t *slave = &db->slave[s];
				const db_entry_t *entry;

				if (slave->id == 0 || slave->count > 512) {
					continue;
				}
				entry = (const db_entry_t *)((const uint8_t *)(db + 1) + slave->header_offset);
				for (unsigned i = 0; i < slave->count; i++) {
					if (memcmp(entry[i].id, "ldob12\0\0", 8) == 0) {
						iovdd = entry[i].address;
					} else if (memcmp(entry[i].id, "ldom6\0\0\0", 8) == 0) {
						avdd = entry[i].address;
					}
				}
			}
			printf("FUXI RPMH: magic ok iovdd=%#x avdd=%#x\n", iovdd, avdd);
		} else {
			printf("FUXI RPMH: cmd-db not found\n");
		}
		rsc = (volatile uint32_t *)ml_io_map(FUXI_RSC_PHYS, 0x4000);
		if (rsc != NULL) {
			volatile uint32_t *slot = (volatile uint32_t *)((volatile uint8_t *)rsc + 0xd00);
			printf("FUXI RPMH: rsc slot0 %#x %#x %#x %#x %#x %#x %#x %#x\n",
			    slot[0], slot[1], slot[2], slot[3], slot[4], slot[5], slot[6], slot[7]);
		} else {
			printf("FUXI RPMH: rsc map failed\n");
		}
	}
'''

new = anchor + block
diff = list(difflib.unified_diff(
    anchor.splitlines(keepends=True), new.splitlines(keepends=True),
    fromfile='a/bsd/dev/fuxi_touch.c', tofile='b/bsd/dev/fuxi_touch.c', n=3))
# line numbers are irrelevant for a fuzzy apply, but keep them plausible
out = [diff[0], diff[1]]
for line in diff[2:]:
    m = re.match(r'@@ -(\d+),(\d+) \+(\d+),(\d+) @@', line)
    if m:
        a, n_old, b, n_new = (int(x) for x in m.groups())
        out.append(f'@@ -{648 + a - 1},{n_old} +{648 + a - 1},{n_new} @@\n')
    else:
        out.append(line)
patch = ''.join(out)
pathlib.Path('/root/fuxi/0115-fuxi-rpmh-probe.patch').write_bytes(patch.encode())
print(patch)

work = pathlib.Path(tempfile.mkdtemp())
(work / 'bsd/dev').mkdir(parents=True)
(work / 'bsd/dev/fuxi_touch.c').write_text(anchor + '\tft_sleep(delay_s * 1000u);\n')
r = subprocess.run(['git', 'apply', '--check', '--verbose', '/root/fuxi/0115-fuxi-rpmh-probe.patch'],
                   cwd=work, capture_output=True, text=True)
print('check rc =', r.returncode, r.stderr.strip()[:200])
