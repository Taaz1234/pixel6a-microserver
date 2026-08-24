import os

rootfs = "/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

wrapper_code = """#!/bin/bash
cmd=""
last=""
for arg in "$@"; do
    if [ "$last" = "-c" ] || [ "$last" = "--command" ]; then
        cmd="$arg"
        break
    fi
    last="$arg"
done

if [ -n "$cmd" ]; then
    export HOME=/root
    export TMPDIR=/tmp
    export TEMP=/tmp
    export TMP=/tmp
    export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/cubecoders/amp
    exec /bin/bash -c "$cmd"
fi
exit 0
"""

paths = [
    os.path.join(rootfs, "usr", "bin", "su"),
    os.path.join(rootfs, "bin", "su"),
    os.path.join(rootfs, "usr", "local", "bin", "su"),
]

for p in paths:
    try:
        if os.path.islink(p):
            os.unlink(p)
        with open(p, "w", newline="\n") as f:
            f.write(wrapper_code)
        os.chmod(p, 0o755)
        print("Written su wrapper to:", p)
    except Exception as e:
        print(f"Error {p}: {e}")
