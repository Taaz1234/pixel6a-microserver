import urllib.request
import json

print("Testing FileBrowser login...")
try:
    req = urllib.request.Request(
        "http://127.0.0.1:8090/api/login",
        data=json.dumps({"username": "admin", "password": "Paco3421"}).encode('utf-8'),
        headers={"Content-Type": "application/json"}
    )
    with urllib.request.urlopen(req, timeout=5) as res:
        token = res.read().decode('utf-8')
        print("FILEBROWSER_LOGIN_SUCCESS! Token length:", len(token))
except Exception as e:
    print("FILEBROWSER_LOGIN_ERROR:", e)

print("\nTesting AdGuard Home login...")
try:
    req = urllib.request.Request(
        "http://127.0.0.1:3000/control/login",
        data=json.dumps({"name": "admin", "password": "Paco3421"}).encode('utf-8'),
        headers={"Content-Type": "application/json"}
    )
    with urllib.request.urlopen(req, timeout=5) as res:
        body = res.read().decode('utf-8')
        print("ADGUARD_LOGIN_SUCCESS! Headers:", res.headers.get("Set-Cookie"))
except Exception as e:
    print("ADGUARD_LOGIN_ERROR:", e)
