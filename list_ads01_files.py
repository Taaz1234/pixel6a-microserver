import os

ads_dir = "/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs/root/.ampdata/instances/ADS01"
print("Contents of ADS01:")
for root, dirs, files in os.walk(ads_dir):
    print("Dir:", root)
    print("Files:", files[:10])
    break
