import json
import bcrypt

fp = "/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs/root/.ampdata/instances/ADS01/UserData.json"

new_hash = bcrypt.hashpw(b"Paco3421", bcrypt.gensalt(11)).decode()
print("Generated bcrypt hash for Paco3421:", new_hash)

with open(fp, "r") as f:
    data = json.load(f)

for uid, u in data.items():
    if u.get("Name") == "admin":
        u["PasswordHash"] = new_hash
        u["HashType"] = 1
        u["MustChangePassword"] = False
        u["Disabled"] = False
        print("Updated user admin with new PasswordHash!")

with open(fp, "w") as f:
    json.dump(data, f, indent=2)

print("[SUCCESS] UserData.json guardado correctamente con la contraseña Paco3421.")
