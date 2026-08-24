import urllib.request
import json

print("=== PROBANDO CREDENCIALES admin / Paco3421 ===")

# 1. FILEBROWSER
try:
    req = urllib.request.Request(
        "http://127.0.0.1:8090/api/login",
        data=json.dumps({"username": "admin", "password": "Paco3421"}).encode(),
        headers={"Content-Type": "application/json"}
    )
    with urllib.request.urlopen(req, timeout=5) as res:
        print("[OK] FileBrowser (8090): Login EXITOSO!")
except Exception as e:
    print("[ERROR] FileBrowser (8090):", e)

# 2. ADGUARD HOME
try:
    req = urllib.request.Request(
        "http://127.0.0.1:3000/control/login",
        data=json.dumps({"name": "admin", "password": "Paco3421"}).encode(),
        headers={"Content-Type": "application/json"}
    )
    with urllib.request.urlopen(req, timeout=5) as res:
        print("[OK] AdGuard Home (3000): Login EXITOSO! HTTP Status:", res.status)
except Exception as e:
    print("[ERROR] AdGuard Home (3000):", e)

# 3. AMP
try:
    req = urllib.request.Request(
        "http://127.0.0.1:8085/API/Core/Login",
        data=json.dumps({"username": "admin", "password": "Paco3421", "token": "", "rememberMe": False}).encode(),
        headers={"Content-Type": "application/json", "Accept": "application/json"}
    )
    with urllib.request.urlopen(req, timeout=5) as res:
        data = json.loads(res.read().decode())
        print(f"[OK] CubeCoders AMP (8085): Respuesta API -> success = {data.get('success')}, result = {data.get('result')}")
except Exception as e:
    print("[ERROR] CubeCoders AMP (8085):", e)

print("=== FIN DE PRUEBAS ===")
