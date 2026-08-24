import os

ads_cfg = "/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs/root/.ampdata/instances/ADS01/AMPConfig.conf"
with open(ads_cfg, "r") as f:
    for line in f:
        if "InstanceID" in line or "TargetID" in line:
            print(line.strip())
