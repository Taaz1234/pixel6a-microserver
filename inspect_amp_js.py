import os
import re

scripts_dir = "/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs/root/.ampdata/instances/ADS01/Scripts"

print("Inspecting Scripts directory in ADS01:")
for f in os.listdir(scripts_dir):
    if f.endswith(".js"):
        fp = os.path.join(scripts_dir, f)
        with open(fp, "r", encoding="utf-8", errors="ignore") as c:
            content = c.read()
            matches = re.findall(r'API\/[A-Za-z0-9_\/]+', content)
            print(f"{f}: Found {len(matches)} API routes. Examples:", matches[:10])
