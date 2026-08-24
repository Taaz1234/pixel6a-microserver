import urllib.request
import json

url = "http://127.0.0.1:8085/API/Core/Login"
payload = {
    "username": "admin",
    "password": "wrongpassword123",
    "token": "",
    "rememberMe": False
}

data = json.dumps(payload).encode("utf-8")
headers = {
    "Content-Type": "application/json",
    "Accept": "application/json"
}
req = urllib.request.Request(url, data=data, headers=headers)

try:
    with urllib.request.urlopen(req, timeout=5) as response:
        res = json.loads(response.read().decode())
        print("Wrong password response:", res)
except Exception as e:
    print("Error:", e)
