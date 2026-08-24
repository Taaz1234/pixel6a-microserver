import json
import bcrypt

fp = "/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs/root/.ampdata/instances/ADS01/UserData.json"
with open(fp, "r") as f:
    data = json.load(f)

for uid, u in data.items():
    h = u.get("PasswordHash")
    match = bcrypt.checkpw(b"Paco3421", h.encode())
    print(f"User: '{u.get('Name')}', Password 'Paco3421' valid: {match}")
