import os
import time

ads_dir = "/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs/root/.ampdata"

print("Checking AMP cache sizes and speed bottlenecks:")
for root, dirs, files in os.walk(ads_dir):
    if "AMPTemplates" in root or "Versions" in root or "Modpack" in root or "Cache" in root:
        size = sum(os.path.getsize(os.path.join(root, f)) for f in files if os.path.isfile(os.path.join(root, f)))
        print(f"Cached dir: {root} -> Size: {size / (1024*1024):.2f} MB")
