import json
import os

fp = "/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs/root/.ampdata/instances.json"
if os.path.exists(fp):
    with open(fp, "r") as f:
        print("instances.json:")
        print(f.read())
else:
    print("instances.json does not exist")
