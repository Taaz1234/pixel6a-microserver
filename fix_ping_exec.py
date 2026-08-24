import os

rootfs = "/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

ping_script = """#!/bin/sh
exit 0
"""

targets = [
    os.path.join(rootfs, "usr", "local", "bin", "ping"),
    os.path.join(rootfs, "usr", "bin", "ping"),
    os.path.join(rootfs, "bin", "ping"),
    os.path.join(rootfs, "usr", "local", "bin", "which"),
    os.path.join(rootfs, "usr", "bin", "which"),
]

for t in targets:
    try:
        if os.path.islink(t):
            os.unlink(t)
        with open(t, "w") as f:
            f.write(ping_script)
        os.chmod(t, 0o755)
        print(f"Created executable: {t}")
    except Exception as e:
        print(f"Error {t}: {e}")
