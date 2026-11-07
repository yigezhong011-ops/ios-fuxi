#!/usr/bin/env python3
"""Patch 0116 v2: kern.exec_inject, plus clearing the code-signing flags that make
dyld ignore DYLD_INSERT_LIBRARIES for the injected programs.

Why: exec_inject is proven to fire ("FUXI INJECT: backboardd gets
/redwood/lib/libredwood-gl.dylib" in a panic build), but the picture did not change,
which means dyld did not load the library. dyld refuses DYLD_* variables for a
process whose code-signing flags say hard/restricted (CS_HARD / CS_RESTRICT /
CS_ENFORCEMENT), and those come from the platform binary's own signature. Our kernel
sets them at exec; clearing them for the programs we inject into is what makes the
environment variable effective.

Gated to the same list as the injection, so nothing else in the system changes.
"""
import difflib
import pathlib
import re
import subprocess
import tempfile

SRC = pathlib.Path('/root/fuxi/regenerate/kern_exec.base.c')
text = SRC.read_text()

HELPER = r'''
/*
 * Bring-up aid: the sysctl kern.exec_inject holds "LIBRARY NAME NAME ..."; every program
 * whose file name is one of the NAMEs is started with DYLD_INSERT_LIBRARIES=LIBRARY in its
 * environment, and has the code-signing flags that make dyld ignore that variable cleared.
 * launchd refuses to pass DYLD_ variables from a job description, which is why the kernel
 * adds this one. Set by the loader (or by init) before launchd.
 */
static char exec_inject_conf[512] =
    "/redwood/lib/libredwood-gl.dylib backboardd";
SYSCTL_STRING(_kern, OID_AUTO, exec_inject, CTLFLAG_RW | CTLFLAG_LOCKED, exec_inject_conf,
    sizeof(exec_inject_conf),
    "LIBRARY NAME... [; LIBRARY NAME...]: programs started with the library inserted");

/* true when this program's file name appears in one of the groups */
static bool
exec_inject_target(struct image_params *imgp)
{
	const char *name, *p = exec_inject_conf;
	size_t namelen;

	if (*p == 0 || imgp->ip_ndp == NULL) {
		return false;
	}
	name = imgp->ip_ndp->ni_cnd.cn_nameptr;
	namelen = imgp->ip_ndp->ni_cnd.cn_namelen;
	if (namelen == 0) {
		return false;
	}
	while (*p != 0) {
		while (*p == ' ' || *p == ';') {
			p++;
		}
		while (*p != 0 && *p != ' ' && *p != ';') {
			p++;                    /* the group's library */
		}
		while (*p == ' ') {
			const char *word = ++p;

			while (*p != 0 && *p != ' ' && *p != ';') {
				p++;
			}
			if ((size_t)(p - word) == namelen && strncmp(word, name, namelen) == 0) {
				return true;
			}
		}
	}
	return false;
}

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

# 1) the helper, before exec_extract_strings
anchor1 = '__attribute__((noinline))\nstatic int\nexec_extract_strings(struct image_params *imgp)\n{\n'
assert anchor1 in text, 'anchor 1 not found'
new = text.replace(anchor1, HELPER + anchor1, 1)

# 2) the local buffer
old_decl = '\tint error = 0;\n\tint     ptr_size = (imgp->ip_flags & IMGPF_WAS_64BIT_ADDR) ? 8 : 4;'
assert old_decl in new, 'anchor 2 not found'
new = new.replace(old_decl, '\tchar            inject_env[512];\n' + old_decl, 1)

# 3) the env var, after the environment loop
m = re.search(r'\n\t\timgp->ip_envc\+\+;\n\t\}\n', new)
assert m, 'anchor 3 not found'
new = new[:m.end()] + '\n' + CALL + new[m.end():]

# 4) clear the flags dyld looks at, right after the kernel has set them all
flag_anchor = '''	if (proc_getcsflags(p) & CS_EXEC_SET_ENFORCEMENT) {
		imgp->ip_csflags |= CS_ENFORCEMENT;
	}
'''
assert flag_anchor in new, 'anchor 4 (csflags) not found'

# file-scope prototype: exec_inject_target is defined further down
fn_anchor = 'static int\nexec_mach_imgact(struct image_params *imgp)\n{\n'
assert fn_anchor in new, 'exec_mach_imgact definition not found'
new = new.replace(fn_anchor,
                  '/* defined below, with the rest of the injection code */\n'
                  'static bool exec_inject_target(struct image_params *imgp);\n\n'
                  + fn_anchor, 1)
# prototype_fix
flag_add = flag_anchor + '''	/*
	 * Bring-up aid: dyld refuses DYLD_* variables for a process marked hard or
	 * restricted, and a platform binary carries those bits in its own signature.
	 * The programs exec_inject names get them cleared, so the library the kernel
	 * inserts is actually loaded.
	 */
		if (exec_inject_target(imgp)) {
		imgp->ip_csflags &= ~(CS_HARD | CS_RESTRICT | CS_ENFORCEMENT);
	}
'''
new = new.replace(flag_anchor, flag_add, 1)

out = pathlib.Path('/root/fuxi/0116-kern-exec-inject.patch')
diff = list(difflib.unified_diff(text.splitlines(keepends=True), new.splitlines(keepends=True),
                                 fromfile='a/bsd/kern/kern_exec.c', tofile='b/bsd/kern/kern_exec.c', n=3))
out.write_text(''.join(diff))
print('patch written: %s (%d lines)' % (out, len(diff)))

work = pathlib.Path(tempfile.mkdtemp())
(work / 'bsd/kern').mkdir(parents=True)
(work / 'bsd/kern/kern_exec.c').write_text(text)
r = subprocess.run(['git', 'apply', '--check', '-v', str(out)], cwd=work, capture_output=True, text=True)
print('git apply --check: rc =', r.returncode)
print(r.stderr.strip()[:300])
