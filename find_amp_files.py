import os

rootfs = "/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

print("Searching for AMP binaries or zips in rootfs...")
for root, dirs, files in os.walk(rootfs):
    for f in files:
        if "AMP_Linux" in f or "AMP" in f and (f.endswith(".zip") or f.endswith(".tar.gz")):
            full_p = os.path.join(root, f)
            print(f"Found: {full_p} (size: {os.path.getsize(full_p)})")
