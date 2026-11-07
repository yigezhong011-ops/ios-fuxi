#!/usr/bin/env python3
"""Generate the kern.exec_inject patch for xnu-8796.141.3 from Apple's own file.

The feature is HackiOS's (oosexgang/hackios-xnu-kernel, xnu/hakios.patch, lines
615-692): a sysctl holding "LIBRARY NAME NAME ..." that makes exec() add
DYLD_INSERT_LIBRARIES for the named programs, which is how a platform binary like
backboardd can be made to load a library launchd would not pass an environment to.

This script takes the stock file, inserts the same code at the same two anchors,
and writes a unified diff that `git apply` takes.
"""
import difflib
import pathlib
import re
import subprocess
import tempfile

SRC = pathlib.Path('/mnt/e/DSH-Fuxi/dump/kern_exec-8796.141.3.c')
text = SRC.read_text()

HELPER = r'''
/*
 * Bring-up aid: the sysctl kern.exec_inject holds "LIBRARY NAME NAME ..."; every program
 * whose file name is one of the NAMEs is started with DYLD_INSERT_LIBRARIES=LIBRARY in its
 * environment, so that dyld loads our library into it. Several such groups may follow each
 * other, separated by ";". launchd refuses to pass DYLD_ variables from a job description,
 * which is why the kernel adds this one. Set by the loader (or by init) before launchd.
 */
static char exec_inject_conf[512] =
    "/redwood/lib/libredwood-gl.dylib backboardd";
SYSCTL_STRING(_kern, OID_AUTO, exec_inject, CTLFLAG_RW | CTLFLAG_LOCKED, exec_inject_conf,
    sizeof(exec_inject_conf),
    "LIBRARY NAME... [; LIBRARY NAME...]: programs started with the library inserted");

static bool
exec_inject_env(struct image_params *imgp, char *env, size_t size)
{
	const char *name, *p = exec_inject_conf;
	size_t namelen, used;
	bool any = false;

	if (*p == 0 || imgp->ip_ndp == NULL) {
		return false;
	}
	name = imgp->ip_ndp->ni_cnd.cn_nameptr;
	namelen = imgp->ip_ndp->ni_cnd.cn_namelen;
	used = strlcpy(env, "DYLD_INSERT_LIBRARIES=", size);
	while (*p != 0) {
		const char *library;
		size_t liblen;
		bool matched = false;

		while (*p == ' ' || *p == ';') {
			p++;
		}
		library = p;
		while (*p != 0 && *p != ' ' && *p != ';') {
			p++;
		}
		liblen = (size_t)(p - library);
		while (*p == ' ') {
			const char *word = ++p;

			while (*p != 0 && *p != ' ' && *p != ';') {
				p++;
			}
			if (!matched && (size_t)(p - word) == namelen && namelen != 0 && liblen != 0 &&
			    strncmp(word, name, namelen) == 0) {
				matched = true;
			}
		}
		if (matched && liblen != 0 && used + 1 + liblen < size) {
			/* diagnostic build: prove on the screen that this fired */
			panic("FUXI INJECT: %.*s gets %.*s", (int)namelen, name, (int)liblen, library);
			if (any) {
				env[used++] = ':';
			}
			memcpy(env + used, library, liblen);
			used += liblen;
			env[used] = 0;
			any = true;
		}
	}
	return any;
}

'''

CALL = r'''	/* one more variable for the programs that get our library inside them */
	if (exec_inject_env(imgp, inject_env, sizeof(inject_env))) {
		error = exec_add_user_string(imgp, CAST_USER_ADDR_T(inject_env), UIO_SYSSPACE, TRUE);
		if (error) {
			goto bad;
		}
		if (imgp->ip_argspace < new_ptr_size) {
			error = E2BIG;
			goto bad;
		}
		imgp->ip_argspace -= new_ptr_size;
	}
'''

# anchor 1: right before exec_extract_strings' definition
anchor1 = '__attribute__((noinline))\nstatic int\nexec_extract_strings(struct image_params *imgp)\n{\n'
assert anchor1 in text, 'anchor 1 (exec_extract_strings) not found'
new = text.replace(anchor1, HELPER + anchor1, 1)

# the function needs a local buffer for the string
old_decl = '\tint error = 0;\n\tint     ptr_size = (imgp->ip_flags & IMGPF_WAS_64BIT_ADDR) ? 8 : 4;'
assert old_decl in new, 'anchor 2 (locals) not found'
new = new.replace(old_decl, '\tchar            inject_env[512];\n' + old_decl, 1)

# anchor 3: after the environment copy loop, before the function returns
m = re.search(r'\n\t\timgp->ip_envc\+\+;\n\t\}\n', new)
assert m, 'anchor 3 (environment loop) not found'
insert_at = m.end()
new = new[:insert_at] + '\n' + CALL + new[insert_at:]

out = pathlib.Path('/root/fuxi/0116-kern-exec-inject.patch')
diff = list(difflib.unified_diff(text.splitlines(keepends=True), new.splitlines(keepends=True),
                                 fromfile='a/bsd/kern/kern_exec.c', tofile='b/bsd/kern/kern_exec.c', n=3))
out.write_text(''.join(diff))
print('patch written: %s (%d lines)' % (out, len(diff)))

# verify with git apply against a tree holding the stock file
work = pathlib.Path(tempfile.mkdtemp())
(work / 'bsd/kern').mkdir(parents=True)
(work / 'bsd/kern/kern_exec.c').write_text(text)
r = subprocess.run(['git', 'apply', '--check', '-v', str(out)], cwd=work, capture_output=True, text=True)
print('git apply --check: rc =', r.returncode)
print(r.stderr.strip()[:300])
