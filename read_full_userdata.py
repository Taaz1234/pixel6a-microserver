import json

fp = "/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs/root/.ampdata/instances/ADS01/UserData.json"
try:
    with open(fp, "r") as f:
        print(f.read())
except Exception as e:
    print("Error reading UserData.json:", e)
