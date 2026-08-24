import os
import json

instances_path = "/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs/root/.ampdata/instances.json"

if os.path.exists(instances_path):
    with open(instances_path, "r") as f:
        data = json.load(f)
        print("instances.json content:")
        print(json.dumps(data, indent=2))
else:
    print("instances.json NOT FOUND!")
