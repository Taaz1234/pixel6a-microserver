import os

mc_dir = "/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs/root/.ampdata/instances/Minecraft01"

print(f"Checking {mc_dir}:")
if os.path.exists(mc_dir):
    for root, dirs, files in os.walk(mc_dir):
        print(f"Dir: {root}")
        print(f"Files: {files}")
else:
    print("Directory Minecraft01 does not exist.")
