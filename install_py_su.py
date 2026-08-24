import os

rootfs = "/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

py_su = """#!/usr/bin/env python3
import sys
import subprocess
import os

args = sys.argv[1:]
cmd = None
for i, arg in enumerate(args):
    if arg in ("-c", "--command") and i + 1 < len(args):
        cmd = args[i + 1]
        break

if cmd:
    if (cmd.startswith("'") and cmd.endswith("'")) or (cmd.startswith('"') and cmd.endswith('"')):
        cmd = cmd[1:-1]
    
    env = os.environ.copy()
    env["HOME"] = "/root"
    env["TMPDIR"] = "/tmp"
    env["TEMP"] = "/tmp"
    env["TMP"] = "/tmp"
    env["PATH"] = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/cubecoders/amp"
    
    res = subprocess.run(["/bin/bash", "-c", cmd], env=env)
    sys.exit(res.returncode)
sys.exit(0)
"""

for p in ["usr/bin/su", "bin/su", "usr/local/bin/su"]:
    full_p = os.path.join(rootfs, p)
    try:
        if os.path.islink(full_p):
            os.unlink(full_p)
        with open(full_p, "w") as f:
            f.write(py_su)
        os.chmod(full_p, 0o755)
        print(f"Installed python su wrapper at {full_p}")
    except Exception as e:
        print(f"Error {p}: {e}")
