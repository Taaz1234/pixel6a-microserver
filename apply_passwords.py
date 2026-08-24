import os
import subprocess
import re
import time

print("=== INICIANDO CAMBIO DE CONTRASEÑAS ===")

# -------------------------------------------------------------
# 1. FILEBROWSER
# -------------------------------------------------------------
print("\n[1/2] Actualizando contraseña de FileBrowser...")
os.system("pkill -9 filebrowser 2>/dev/null")
time.sleep(1)

db_path = "/data/local/tmp/filebrowser_data/filebrowser.db"
fb_bin = "/data/local/tmp/filebrowser"

# Permitir contraseñas de longitud corta
cmd_config = [fb_bin, "config", "set", "--minimumPasswordLength", "4", "-d", db_path]
r_cfg = subprocess.run(cmd_config, capture_output=True, text=True)
print("Config output:", r_cfg.stdout, r_cfg.stderr)

# Actualizar usuario admin
cmd_usr = [fb_bin, "users", "update", "admin", "-p", "Paco3421", "-d", db_path]
r_usr = subprocess.run(cmd_usr, capture_output=True, text=True)
print("User update output:", r_usr.stdout, r_usr.stderr)

# Reiniciar FileBrowser
os.system("nohup /data/local/tmp/filebrowser -d /data/local/tmp/filebrowser_data/filebrowser.db -a 0.0.0.0 -p 8090 -r /sdcard/Media > /data/local/tmp/filebrowser.log 2>&1 &")
print("FileBrowser reiniciado con éxito en puerto 8090.")

# -------------------------------------------------------------
# 2. ADGUARD HOME
# -------------------------------------------------------------
print("\n[2/2] Actualizando contraseña de AdGuard Home...")
adguard_yaml = "/data/local/tmp/adguard_work/AdGuardHome.yaml"

# Intentar generar hash bcrypt mediante python o htpasswd
hash_str = None
try:
    import bcrypt
    salt = bcrypt.gensalt(rounds=10)
    hash_str = bcrypt.hashpw(b"Paco3421", salt).decode('utf-8')
    print("Hash generado con bcrypt python:", hash_str)
except Exception as e:
    print("bcrypt import:", e)

if not hash_str:
    try:
        r_ht = subprocess.run(["htpasswd", "-nbBC", "10", "admin", "Paco3421"], capture_output=True, text=True)
        if ":" in r_ht.stdout:
            hash_str = r_ht.stdout.strip().split(":")[1]
            print("Hash generado con htpasswd:", hash_str)
    except Exception as e:
        print("htpasswd error:", e)

if not hash_str:
    try:
        r_py = subprocess.run(["/data/data/com.termux/files/usr/bin/python3", "-c", "import bcrypt; print(bcrypt.hashpw(b'Paco3421', bcrypt.gensalt(10)).decode('utf-8'))"], capture_output=True, text=True)
        if r_py.stdout.strip().startswith("$2"):
            hash_str = r_py.stdout.strip()
            print("Hash generado con termux python3:", hash_str)
    except Exception as e:
        print("termux python error:", e)

if hash_str:
    # Leer AdGuardHome.yaml y reemplazar el hash
    with open(adguard_yaml, "r", encoding="utf-8") as f:
        content = f.read()

    # Reemplazar password en la sección users
    new_content = re.sub(r'(users:\s*\n\s*-\s*name:\s*admin\s*\n\s*password:\s*)\S+', r'\g<1>' + hash_str, content)
    
    with open(adguard_yaml, "w", encoding="utf-8") as f:
        f.write(new_content)
    
    print("AdGuardHome.yaml actualizado con el nuevo hash.")
    
    # Reiniciar AdGuard Home
    os.system("pkill -9 AdGuardHome 2>/dev/null")
    time.sleep(1)
    os.system("export SSL_CERT_FILE=/data/local/tmp/cacert.pem; nohup /data/local/tmp/AdGuardHome -w /data/local/tmp/adguard_work -c /data/local/tmp/adguard_work/AdGuardHome.yaml > /data/local/tmp/adguard.log 2>&1 &")
    print("AdGuard Home reiniciado con éxito en puerto 3000.")
else:
    print("ERROR: No se pudo generar el hash bcrypt.")

print("\n=== PROCESO FINALIZADO ===")
