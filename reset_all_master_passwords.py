import subprocess
import os
import re

print("[1/3] Actualizando contraseña de FileBrowser a admin / Paco3421...")
os.system("pkill -9 -f filebrowser 2>/dev/null")
db_path = "/data/pixelserver/filebrowser/filebrowser.db"
fb_bin = "/data/pixelserver/filebrowser/filebrowser"

# Check if admin exists
res = subprocess.run([fb_bin, "users", "ls", "-d", db_path], capture_output=True, text=True)
print("FileBrowser users output:", res.stdout, res.stderr)

if "admin" in res.stdout:
    subprocess.run([fb_bin, "users", "update", "admin", "-p", "Paco3421", "-d", db_path])
else:
    subprocess.run([fb_bin, "users", "add", "admin", "Paco3421", "--perm.admin", "-d", db_path])

os.system(f"nohup {fb_bin} -r /sdcard/Media -a 0.0.0.0 -p 8090 -d {db_path} > /data/pixelserver/filebrowser.log 2>&1 &")
print("[+] FileBrowser actualizado.")

print("[2/3] Actualizando contraseña de CubeCoders AMP a admin / Paco3421...")
chroot_cmd = "chroot /data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs /bin/bash -c 'export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/cubecoders/amp; export HOME=/root; ampinstmgr --SetPassword ADS01 admin Paco3421'"
os.system(chroot_cmd)
print("[+] AMP actualizado.")

print("[3/3] Actualizando contraseña de AdGuard Home...")
# Generar hash bcrypt para Paco3421 usando python en chroot
hash_cmd = "chroot /data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs /usr/bin/python3 -c 'import bcrypt; print(bcrypt.hashpw(b\"Paco3421\", bcrypt.gensalt(10)).decode())'"
p = subprocess.Popen(hash_cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
out, _ = p.communicate()
bcrypt_hash = out.strip()
print("AdGuard bcrypt hash:", bcrypt_hash)

if bcrypt_hash.startswith("$2"):
    yaml_path = "/data/pixelserver/adguard/AdGuardHome.yaml"
    if os.path.exists(yaml_path):
        with open(yaml_path, "r") as f:
            content = f.read()
        # Replace password hash
        content = re.sub(r'password:\s*["\']?\$2[^\n"\']+', f'password: "{bcrypt_hash}"', content)
        with open(yaml_path, "w") as f:
            f.write(content)
        os.system("pkill -9 -f AdGuardHome 2>/dev/null")
        os.system("nohup /data/pixelserver/adguard/AdGuardHome -c /data/pixelserver/adguard/AdGuardHome.yaml -w /data/pixelserver/adguard > /data/pixelserver/adguard.log 2>&1 &")
        print("[+] AdGuard Home actualizado con Paco3421.")

print("[OK] Todas las contraseñas han sido restablecidas a: admin / Paco3421")
