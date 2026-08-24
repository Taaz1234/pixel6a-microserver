import os

rootfs = "/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

print("Checking python3 in rootfs:")
for root, dirs, files in os.walk(os.path.join(rootfs, "usr", "bin")):
    for f in files:
        if "python" in f:
            print(f"Found: {os.path.join(root, f)}")
