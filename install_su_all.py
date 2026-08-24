import os
import shutil

rootfs = "/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

wrapper_content = """#!/bin/bash
echo "[DEBUG SU] $@" >> /tmp/su_debug.log

while [ $# -gt 0 ]; do
    if [ "$1" = "-c" ] || [ "$1" = "--command" ]; then
        shift
        export HOME=/root
        export TMPDIR=/tmp
        export TEMP=/tmp
        export TMP=/tmp
        export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/cubecoders/amp
        exec /bin/sh -c "$1"
    fi
    shift
done
exit 0
"""

for p in ["usr/bin/su", "bin/su", "usr/local/bin/su"]:
    full_p = os.path.join(rootfs, p)
    try:
        if os.path.islink(full_p):
            os.unlink(full_p)
        with open(full_p, "w") as f:
            f.write(wrapper_content)
        os.chmod(full_p, 0o755)
        print(f"Installed wrapper at {full_p}")
    except Exception as e:
        print(f"Error {p}: {e}")
