import os

mc_dir = "/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs/root/.ampdata/instances/Minecraft01"
print("Root files of Minecraft01:")
for f in os.listdir(mc_dir):
    fp = os.path.join(mc_dir, f)
    if os.path.isfile(fp):
        print(f, os.path.getsize(fp))
