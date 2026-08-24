import os

fp = "/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs/root/.ampdata/instances/ADS01/AMPConfig.conf"
with open(fp, "r") as f:
    for line in f:
        if any(k in line for k in ["Webserver", "Port", "IPBinding", "Licence", "Login"]):
            print(line.strip())
