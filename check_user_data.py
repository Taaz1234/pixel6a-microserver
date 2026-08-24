import json

fp = "/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs/root/.ampdata/instances/ADS01/UserData.json"
try:
    with open(fp, "r") as f:
        data = json.load(f)
    print("UserData.json content:")
    for uid, u in data.items():
        print(f"User: {u.get('Name')}, Has PasswordHash: {bool(u.get('PasswordHash'))}, MustChange: {u.get('MustChangePassword')}, Disabled: {u.get('Disabled')}")
except Exception as e:
    print(e)
