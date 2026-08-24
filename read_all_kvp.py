import os

rootfs = "/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"
ads_dir = os.path.join(rootfs, "root", ".ampdata", "instances", "ADS01")

for f in os.listdir(ads_dir):
    if f.endswith(".kvp"):
        print(f"=== {f} ===")
        with open(os.path.join(ads_dir, f), "r") as c:
            print(c.read())
