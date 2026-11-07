#!/usr/bin/env python3
"""Encode the test result in *when* the phone reboots, so no log is needed:

    PASS -> reboot 45 s after the test starts
    FAIL -> reboot 105 s after the test starts
    job never ran -> no reboot at all
"""
import base64, json, pathlib, urllib.request

f = pathlib.Path('/mnt/e/DSH-Fuxi/dump/wsl/fuxi_gl_test.c')
src = f.read_text()

# replace the whole pass/fail tail with the timed-signal version
start = src.index('out:')
new_tail = '''out:
	/* The result is the *time* of the reboot:
	 *   PASS -> 45 s   FAIL -> 105 s   job never ran -> no reboot at all.
	 * Nothing has to be read off the device for that. */
	if (ok) {
		say("fuxi_gl_test: PASS -> rebooting in 45 s (the timing is the signal)\\n");
		if (logf) { fclose(logf); logf = NULL; }
		sleep(45);
		sync();
		reboot(0);
		for (;;) sleep(60);
	}
	say("fuxi_gl_test: FAIL -> rebooting in 105 s (the timing is the signal)\\n");
	if (logf) { fclose(logf); logf = NULL; }
	sleep(105);
	sync();
	reboot(0);
	for (;;) sleep(60);
}
'''
src = src[:start] + new_tail
f.write_text(src)
print('timed signal written')

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token.txt').read_text().strip()
API = 'https://api.github.com/repos/pyhs5g27vr-hue/ios-fuxi'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


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
    'mesa-ios: encode the GL test result in the reboot time (45 s pass / 105 s fail)')

disp = json.dumps({'ref': 'main', 'inputs': {'winsys': 'fuxi'}}).encode()
req = urllib.request.Request(f'{API}/actions/workflows/mesa-ios.yml/dispatches', data=disp,
                             headers={**H, 'Content-Type': 'application/json'}, method='POST')
urllib.request.urlopen(req, timeout=30)
print('dispatched')
