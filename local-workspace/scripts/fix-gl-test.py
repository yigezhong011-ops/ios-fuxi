#!/usr/bin/env python3
"""Fix the GL test for the iOS SDK (no sys/reboot.h) and re-dispatch."""
import base64, json, pathlib, urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token.txt').read_text().strip()
API = 'https://api.github.com/repos/pyhs5g27vr-hue/ios-fuxi'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}

f = pathlib.Path('/mnt/e/DSH-Fuxi/dump/wsl/fuxi_gl_test.c')
src = f.read_text()

src = src.replace('#include <sys/reboot.h>', '''/* the iOS SDK has no <sys/reboot.h>; libSystem still exports reboot(2) */
extern int reboot(int howto);
extern int halt(void);''')

old = '''	if (ok) {
		say("fuxi_gl_test: PASS -> powering off in 5 s (this is the signal)\\n");
		if (logf) {
			fclose(logf);
			logf = NULL;
		}
		sleep(5);
		sync();
		reboot(RB_POWEROFF);
		/* if reboot is not permitted here, fall through to a visible exit */
		say("fuxi_gl_test: poweroff was refused, staying up\\n");
		return 0;
	}'''
new = '''	if (ok) {
		/* One reboot per root image: the marker keeps a passing test from looping. */
		FILE *marker = fopen("/redwood/gl-test.rebooted", "r");
		say("fuxi_gl_test: PASS -> rebooting in 5 s (this is the signal)\\n");
		if (marker != NULL) {
			fclose(marker);
			say("fuxi_gl_test: already rebooted once, staying up\\n");
			if (logf) {
				fclose(logf);
			}
			return 0;
		}
		marker = fopen("/redwood/gl-test.rebooted", "w");
		if (marker != NULL) {
			fclose(marker);
		}
		if (logf) {
			fclose(logf);
			logf = NULL;
		}
		sleep(5);
		sync();
		reboot(0);          /* RB_AUTOBOOT: the machine restarts once */
		halt();             /* if reboot is refused, stop here instead of looping */
		return 0;
	}'''
assert old in src, 'pass block not found'
src = src.replace(old, new, 1)
f.write_text(src)
print('gl_test: reboot via the bare syscall, guarded by a marker')


def put(path, data, msg):
    url = f'{API}/contents/{path}'
    body = {'message': msg, 'content': base64.b64encode(data).decode(), 'branch': 'main'}
    try:
        req = urllib.request.Request(url, headers=H)
        cur = json.load(urllib.request.urlopen(req, timeout=30))
        body['sha'] = cur['sha']
    except Exception:
        pass
    req = urllib.request.Request(url, data=json.dumps(body).encode(),
                                 headers={**H, 'Content-Type': 'application/json'}, method='PUT')
    r = json.load(urllib.request.urlopen(req, timeout=60))
    print(f'  {path} -> {r["commit"]["sha"][:8]}')


put('tools/mesa-ios/experimental/fuxi_gl_test.c', f.read_bytes(),
    'mesa-ios: gl test reboots once on success (no sys/reboot.h on iOS)')

disp = json.dumps({'ref': 'main', 'inputs': {'winsys': 'fuxi'}}).encode()
req = urllib.request.Request(f'{API}/actions/workflows/mesa-ios.yml/dispatches', data=disp,
                             headers={**H, 'Content-Type': 'application/json'}, method='POST')
urllib.request.urlopen(req, timeout=30)
print('re-dispatched')
