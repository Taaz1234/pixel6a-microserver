import shutil
import os

mc_dir = "/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs/root/.ampdata/instances/Minecraft01"
if os.path.exists(mc_dir):
    shutil.rmtree(mc_dir)
    print("[+] Directorio fallido Minecraft01 eliminado para permitir una creación limpia.")
else:
    print("Minecraft01 ya está limpio.")
