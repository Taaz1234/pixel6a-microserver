import os

mc_log_dir = "/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs/root/.ampdata/instances/Minecraft01/AMP_Logs"

if os.path.exists(mc_log_dir):
    logs = sorted(os.listdir(mc_log_dir))
    print("Logs in Minecraft01:", logs)
    if logs:
        with open(os.path.join(mc_log_dir, logs[-1]), "r") as f:
            print("--- Content of latest Minecraft01 log ---")
            print(f.read())
else:
    print("Minecraft01/AMP_Logs does not exist.")
