import os

rootfs = "/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

wrapper_code = """#!/bin/bash
found_c=0
cmd=""
for arg in "$@"; do
    if [ $found_c -eq 1 ]; then
        if [ -z "$cmd" ]; then
            cmd="$arg"
        else
            cmd="$cmd $arg"
        fi
    elif [ "$arg" = "-c" ] || [ "$arg" = "--command" ]; then
        found_c=1
    fi
done

# Extract inner command if enclosed in single or double quotes
if [[ "$cmd" =~ ^\\'(.*)\\'$ ]]; then
    cmd="${BASH_REMATCH[1]}"
elif [[ "$cmd" =~ ^\\"(.*)\\"$ ]]; then
    cmd="${BASH_REMATCH[1]}"
fi

export HOME=/root
export TMPDIR=/tmp
export TEMP=/tmp
export TMP=/tmp
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/cubecoders/amp

eval "$cmd"
exit $?
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
        print("Updated su wrapper at:", p)
    except Exception as e:
        print(f"Error {p}: {e}")
