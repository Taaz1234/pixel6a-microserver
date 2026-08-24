import os

fp = "/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs/root/.ampdata/instances/ADS01/LastAMPException.txt"
if os.path.exists(fp):
    with open(fp, "r") as f:
        print("LastAMPException:")
        print(f.read())
else:
    print("No LastAMPException.txt")
