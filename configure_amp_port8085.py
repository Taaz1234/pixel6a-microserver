import os
import re

conf_path = "/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs/root/.ampdata/instances/ADS01/AMPConfig.conf"

print("[+] Modificando puerto de AMP a 8085...")
with open(conf_path, "r", encoding="utf-8") as f:
    content = f.read()

content = re.sub(r'Webserver\.Port=\d+', 'Webserver.Port=8085', content)
content = re.sub(r'Webserver\.IPBinding=\S+', 'Webserver.IPBinding=0.0.0.0', content)

with open(conf_path, "w", encoding="utf-8") as f:
    f.write(content)

print("[+] AMPConfig.conf actualizado con éxito con puerto 8085.")
