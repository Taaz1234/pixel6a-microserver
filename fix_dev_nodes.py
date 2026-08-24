import os
import subprocess

rootfs = "/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"
dev = os.path.join(rootfs, "dev")
os.makedirs(dev, exist_ok=True)

for name in ["urandom", "random", "null", "zero"]:
    p = os.path.join(dev, name)
    if os.path.exists(p):
        os.remove(p)

os.system(f"mknod -m 666 {os.path.join(dev, 'urandom')} c 1 9")
os.system(f"mknod -m 666 {os.path.join(dev, 'random')} c 1 8")
os.system(f"mknod -m 666 {os.path.join(dev, 'null')} c 1 3")
os.system(f"mknod -m 666 {os.path.join(dev, 'zero')} c 1 5")

print("[+] Device nodes in rootfs/dev:")
os.system(f"ls -la {dev}")
