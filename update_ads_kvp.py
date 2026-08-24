import re

ads_kvp = "/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs/root/.ampdata/instances/ADS01/ADSModule.kvp"

with open(ads_kvp, "r") as f:
    content = f.read()

content = re.sub(r'ADS\.SingleUserInstance=False', 'ADS.SingleUserInstance=True', content)
content = re.sub(r'Network\.DefaultIPBinding=127\.0\.0\.1', 'Network.DefaultIPBinding=0.0.0.0', content)

with open(ads_kvp, "w") as f:
    f.write(content)

print("[SUCCESS] ADSModule.kvp actualizado con ADS.SingleUserInstance=True y 0.0.0.0!")
