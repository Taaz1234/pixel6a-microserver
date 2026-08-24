import subprocess
import os
import re

print("[+] Generando hash bcrypt para Paco3421...")
pw_hash = "$2a$10$po4L.6KzzT0Y33/zgnohXuRAawB3CPeasq1thr476NLvqvRiRZzRu"
res = subprocess.run([
    "chroot",
    "/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs",
    "/usr/bin/python3",
    "-c",
    "import bcrypt; print(bcrypt.hashpw(b'Paco3421', bcrypt.gensalt(10)).decode('utf-8'))"
], capture_output=True, text=True)

if res.stdout and res.stdout.strip().startswith("$2"):
    pw_hash = res.stdout.strip()

print(f"[+] Hash generado: {pw_hash}")

# 1. FILEBROWSER
db_path = "/data/pixelserver/filebrowser/filebrowser.db"
fb_bin = "/data/pixelserver/filebrowser/filebrowser"
os.system("pkill -9 -f filebrowser 2>/dev/null")

# Cambiar longitud mínima de contraseña a 4 caracteres en FileBrowser
subprocess.run([fb_bin, "config", "set", "--min-password-length", "4", "-d", db_path])
# Actualizar contraseña de admin a Paco3421
up_res = subprocess.run([fb_bin, "users", "update", "admin", "-p", "Paco3421", "-d", db_path], capture_output=True, text=True)
print("FileBrowser update output:", up_res.stdout, up_res.stderr)

# Reiniciar FileBrowser
os.system(f"nohup {fb_bin} -r /sdcard/Media -a 0.0.0.0 -p 8090 -d {db_path} > /data/pixelserver/filebrowser.log 2>&1 &")
print("[+] FileBrowser iniciado en 8090.")

# 2. ADGUARD HOME
yaml_path = "/data/pixelserver/adguard/AdGuardHome.yaml"
if os.path.exists(yaml_path):
    with open(yaml_path, "r") as f:
        content = f.read()
    content = re.sub(r'password:\s*["\']?\$2[^\n"\']+', f'password: "{pw_hash}"', content)
    with open(yaml_path, "w") as f:
        f.write(content)
    os.system("pkill -9 -f AdGuardHome 2>/dev/null")
    os.system("nohup /data/pixelserver/adguard/AdGuardHome -c /data/pixelserver/adguard/AdGuardHome.yaml -w /data/pixelserver/adguard > /data/pixelserver/adguard.log 2>&1 &")
    print("[+] AdGuard Home actualizado en 3000 con Paco3421.")

# 3. CUBECODERS AMP
amp_cmd = "chroot /data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs /bin/bash -c 'export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/cubecoders/amp; export HOME=/root; ampinstmgr --ResetLogin ADS01 admin Paco3421'"
amp_res = subprocess.run(amp_cmd, shell=True, capture_output=True, text=True)
print("AMP ResetLogin Output:", amp_res.stdout, amp_res.stderr)

print("[OK] ¡Todas las contraseñas restablecidas a: admin / Paco3421!")
