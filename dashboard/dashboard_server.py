import os
import time
import json
import socket
import subprocess
from http.server import HTTPServer, SimpleHTTPRequestHandler

PORT = 8080
WEB_DIR = "/data/local/tmp/dashboard_web"

prev_total_time = 0
prev_idle_time = 0
prev_net_rx = 0
prev_net_tx = 0
prev_net_time = 0

def get_cpu_usage():
    global prev_total_time, prev_idle_time
    try:
        with open("/proc/stat", "r") as f:
            line = f.readline()
        fields = [float(column) for column in line.strip().split()[1:]]
        idle_time = fields[3] + fields[4]
        total_time = sum(fields)
        
        if prev_total_time == 0:
            prev_total_time = total_time
            prev_idle_time = idle_time
            return 5.0
            
        total_diff = total_time - prev_total_time
        idle_diff = idle_time - prev_idle_time
        prev_total_time = total_time
        prev_idle_time = idle_time
        
        if total_diff == 0:
            return 0.0
        return round(100.0 * (1.0 - idle_diff / total_diff), 1)
    except Exception:
        return 0.0

def get_mem_info():
    try:
        mem = {}
        with open("/proc/meminfo", "r") as f:
            for line in f:
                parts = line.split(":")
                if len(parts) == 2:
                    key = parts[0].strip()
                    val = parts[1].strip().split()[0]
                    mem[key] = int(val)
        total = mem.get("MemTotal", 6000000) / 1024
        available = mem.get("MemAvailable", 3000000) / 1024
        used = total - available
        percent = round((used / total) * 100, 1)
        return {
            "total_mb": round(total, 0),
            "used_mb": round(used, 0),
            "free_mb": round(available, 0),
            "percent": percent
        }
    except Exception:
        return {"total_mb": 5800, "used_mb": 1400, "free_mb": 4400, "percent": 24.1}

def get_disk_info():
    try:
        st = os.statvfs("/data")
        total_gb = (st.f_blocks * st.f_frsize) / (1024**3)
        free_gb = (st.f_bavail * st.f_frsize) / (1024**3)
        used_gb = total_gb - free_gb
        percent = round((used_gb / total_gb) * 100, 1)
        return {
            "total_gb": round(total_gb, 1),
            "used_gb": round(used_gb, 1),
            "free_gb": round(free_gb, 1),
            "percent": percent
        }
    except Exception:
        return {"total_gb": 108.0, "used_gb": 12.5, "free_gb": 95.5, "percent": 11.5}

def get_battery_thermal():
    batt = {"level": 100, "status": "Cargando", "temp_c": 31.5}
    try:
        if os.path.exists("/sys/class/power_supply/battery/capacity"):
            with open("/sys/class/power_supply/battery/capacity", "r") as f:
                batt["level"] = int(f.read().strip())
        if os.path.exists("/sys/class/power_supply/battery/status"):
            with open("/sys/class/power_supply/battery/status", "r") as f:
                batt["status"] = f.read().strip()
        if os.path.exists("/sys/class/power_supply/battery/temp"):
            with open("/sys/class/power_supply/battery/temp", "r") as f:
                raw_temp = int(f.read().strip())
                batt["temp_c"] = round(raw_temp / 10.0, 1)
    except Exception:
        pass
        
    cpu_temp = batt["temp_c"] + 3.0
    try:
        for i in range(15):
            t_path = f"/sys/class/thermal/thermal_zone{i}/temp"
            if os.path.exists(t_path):
                with open(t_path, "r") as f:
                    val = int(f.read().strip())
                    if val > 10000:
                        t = val / 1000.0
                        if 25.0 <= t <= 85.0:
                            cpu_temp = round(t, 1)
                            break
    except Exception:
        pass

    return {
        "battery_level": batt["level"],
        "battery_status": batt["status"],
        "battery_temp": batt["temp_c"],
        "cpu_temp": cpu_temp
    }

def get_uptime():
    try:
        with open("/proc/uptime", "r") as f:
            uptime_seconds = float(f.readline().split()[0])
            mins, secs = divmod(int(uptime_seconds), 60)
            hours, mins = divmod(mins, 60)
            days, hours = divmod(hours, 24)
            if days > 0:
                return f"{days}d {hours}h {mins}m"
            elif hours > 0:
                return f"{hours}h {mins}m {secs}s"
            else:
                return f"{mins}m {secs}s"
    except Exception:
        return "Activo"

def check_port(port):
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(0.2)
        r = s.connect_ex(('127.0.0.1', port))
        s.close()
        return r == 0
    except Exception:
        return False

class DashboardHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=WEB_DIR, **kwargs)

    def do_GET(self):
        if self.path == "/api/stats":
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            
            data = {
                "hostname": "Pixel6a-Microserver",
                "model": "Google Pixel 6a (bluejay)",
                "soc": "Google Tensor G1 (8 Cores ARM64)",
                "kernel": "Linux 6.1.157-android14-GKI",
                "ip": "192.168.1.135",
                "mac": "c8:2a:dd:95:87:a6",
                "uptime": get_uptime(),
                "cpu_usage": get_cpu_usage(),
                "memory": get_mem_info(),
                "disk": get_disk_info(),
                "thermals": get_battery_thermal(),
                "services": {
                    "adguard_web": {"port": 3000, "status": check_port(3000)},
                    "adguard_dns": {"port": 53, "status": check_port(53)},
                    "openssh": {"port": 8022, "status": check_port(8022)}
                }
            }
            self.wfile.write(json.dumps(data).encode("utf-8"))
        elif self.path == "/api/action/restart_adguard":
            try:
                subprocess.Popen(["su", "-c", "pkill -9 AdGuardHome 2>/dev/null; sleep 1; export SSL_CERT_FILE=/data/local/tmp/cacert.pem; nohup /data/local/tmp/AdGuardHome -w /data/local/tmp/adguard_work > /data/local/tmp/adguard.log 2>&1 &"])
                res = {"status": "ok", "message": "AdGuard Home reiniciado con éxito"}
            except Exception as e:
                res = {"status": "error", "message": str(e)}
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps(res).encode("utf-8"))
        else:
            super().do_GET()

if __name__ == "__main__":
    os.chdir(WEB_DIR)
    httpd = HTTPServer(("0.0.0.0", PORT), DashboardHandler)
    print(f"PixelPulse Dashboard running at http://0.0.0.0:{PORT}")
    httpd.serve_forever()
