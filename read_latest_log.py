import os

log_dir = "/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs/root/.ampdata/instances/ADS01/AMP_Logs"
logs = sorted(os.listdir(log_dir))
latest = os.path.join(log_dir, logs[-1])
print("Latest log:", latest)
with open(latest, "r") as f:
    for line in f.readlines()[-60:]:
        print(line.strip())
