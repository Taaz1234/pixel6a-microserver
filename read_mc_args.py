import os

p_file = "/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs/root/.ampdata/instances/Minecraft01/provisionargs.kvp"
if os.path.exists(p_file):
    with open(p_file, "r") as f:
        print("provisionargs.kvp:")
        print(f.read())
else:
    print("No provisionargs.kvp")
