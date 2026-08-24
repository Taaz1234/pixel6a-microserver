import os
import subprocess

rootfs = "/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

print("Checking su in rootfs:")
for root, dirs, files in os.walk(os.path.join(rootfs, "bin")):
    if "su" in files:
        print(f"Found su in {root}")

for root, dirs, files in os.walk(os.path.join(rootfs, "usr", "bin")):
    if "su" in files:
        print(f"Found su in {root}")
