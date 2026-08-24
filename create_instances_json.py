import json
import os

instance_entry = {
    "InstanceID": "00000000-0000-0000-0000-000000000000",
    "InstanceName": "ADS01",
    "FriendlyName": "ADS01",
    "Module": "ADS",
    "IPBinding": "0.0.0.0",
    "Port": 8085,
    "Daemon": False,
    "Installed": True,
    "TargetState": "Running"
}

for base in ["/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs/root/.ampdata",
             "/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs/home/amp/.ampdata"]:
    os.makedirs(base, exist_ok=True)
    with open(os.path.join(base, "instances.json"), "w") as f:
        json.dump([instance_entry], f, indent=2)

print("[+] instances.json creado exitosamente.")
