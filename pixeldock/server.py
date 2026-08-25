#!/usr/bin/env python3
"""
PixelDock Pro - Orchestrator and Microservices Management Panel
Portainer & Coolify styled platform for Google Pixel 6a Microserver.
"""

import http.server
import socketserver
import urllib.request
import urllib.parse
import json
import os
import sys
import time
import subprocess
import re

PORT = 8088
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
STATIC_DIR = os.path.join(BASE_DIR, "static")
SERVICES_FILE = os.path.join(BASE_DIR, "services.json")

def load_services_config():
    if os.path.exists(SERVICES_FILE):
        try:
            with open(SERVICES_FILE, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception as e:
            print(f"[!] Error leyendo {SERVICES_FILE}: {e}")
    return []

def run_cmd(cmd):
    try:
        res = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, timeout=5)
        return res.stdout
    except Exception as e:
        return str(e)

def run_async_cmd(cmd):
    try:
        subprocess.Popen(cmd, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        return True
    except Exception as e:
        print(f"[!] Error ejecutando async: {e}")
        return False

def get_system_telemetry():
    # 1. RAM
    mem_total_mb = 0
    mem_free_mb = 0
    try:
        with open("/proc/meminfo", "r") as f:
            for line in f:
                if line.startswith("MemTotal:"):
                    mem_total_mb = int(line.split()[1]) // 1024
                elif line.startswith("MemAvailable:"):
                    mem_free_mb = int(line.split()[1]) // 1024
    except Exception:
        mem_total_mb = 5800
        mem_free_mb = 3200

    mem_used_mb = max(0, mem_total_mb - mem_free_mb)
    mem_pct = int(round((mem_used_mb / mem_total_mb) * 100)) if mem_total_mb > 0 else 0

    # 2. Temperatura Batería
    battery_temp_c = 31.5
    try:
        temp_paths = [
            "/sys/class/power_supply/battery/temp",
            "/sys/class/thermal/thermal_zone0/temp"
        ]
        for tp in temp_paths:
            if os.path.exists(tp):
                with open(tp, "r") as f:
                    val = float(f.read().strip())
                    if val > 1000:
                        val = val / 10.0 if val < 10000 else val / 1000.0
                    if 15.0 <= val <= 85.0:
                        battery_temp_c = round(val, 1)
                        break
    except Exception:
        pass

    # 3. CPU Load
    cpu_pct = 12
    try:
        load_str = run_cmd("uptime")
        if "load average" in load_str:
            load_val = float(load_str.split("load average:")[1].split(",")[0].strip())
            cpu_pct = min(100, int(round((load_val / 8.0) * 100)))
    except Exception:
        pass

    return {
        "cpu_pct": cpu_pct,
        "ram_total_mb": mem_total_mb,
        "ram_used_mb": mem_used_mb,
        "ram_pct": mem_pct,
        "battery_temp": battery_temp_c,
        "arch": "aarch64 (Google Tensor Octa-Core)",
        "os": "Android Linux Microserver"
    }

def get_all_services_status():
    config = load_services_config()
    results = []
    running_count = 0

    # Obtener salida de netstat y ps una sola vez
    net_out = run_cmd("netstat -tulpn || true")
    ps_out = run_cmd("ps -ef || true")

    # Mapear puertos a PIDs
    port_to_pid = {}
    for line in net_out.splitlines():
        if "LISTEN" in line:
            parts = line.split()
            if len(parts) >= 4:
                local_addr = parts[3]
                if ":" in local_addr:
                    try:
                        p_num = int(local_addr.split(":")[-1])
                        # Buscar PID
                        pid = None
                        for col in parts:
                            if "/" in col and col.split("/")[0].isdigit():
                                pid = col.split("/")[0]
                                break
                        port_to_pid[p_num] = pid
                    except Exception:
                        pass

    for s in config:
        port = s.get("port")
        pattern = s.get("match_pattern", s.get("id"))
        is_running = False
        pid = None

        if port and port in port_to_pid:
            is_running = True
            pid = port_to_pid[port]
        else:
            # Comprobar en ps_out
            for ps_line in ps_out.splitlines():
                if "pixeldock" not in ps_line and re.search(pattern, ps_line, re.IGNORECASE):
                    is_running = True
                    ps_parts = ps_line.split()
                    if len(ps_parts) > 1 and ps_parts[1].isdigit():
                        pid = ps_parts[1]
                    break

        mem_mb = 0
        if is_running and pid and os.path.exists(f"/proc/{pid}/status"):
            try:
                with open(f"/proc/{pid}/status", "r") as f:
                    for s_line in f:
                        if s_line.startswith("VmRSS:"):
                            mem_mb = round(int(s_line.split()[1]) / 1024, 1)
                            break
            except Exception:
                pass

        if is_running:
            running_count += 1

        results.append({
            "id": s.get("id"),
            "name": s.get("name"),
            "category": s.get("category"),
            "port": s.get("port"),
            "web_url": s.get("web_url"),
            "icon": s.get("icon"),
            "color": s.get("color"),
            "description": s.get("description"),
            "running": is_running,
            "pid": pid,
            "mem_mb": mem_mb,
            "log_file": s.get("log_file")
        })

    return {
        "total_services": len(config),
        "running_count": running_count,
        "stopped_count": len(config) - running_count,
        "services": results,
        "system": get_system_telemetry()
    }

class DockRequestHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=STATIC_DIR, **kwargs)

    def translate_path(self, path):
        clean_path = urllib.parse.urlparse(path).path
        return super().translate_path(clean_path)

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path
        query = urllib.parse.parse_qs(parsed.query)

        if path == "/api/services":
            data = get_all_services_status()
            self.send_json(data)
        elif path == "/api/system/stats":
            data = get_system_telemetry()
            self.send_json(data)
        elif path == "/api/service/logs":
            service_id = query.get("id", [""])[0]
            lines_count = int(query.get("lines", [80])[0])
            config = load_services_config()
            target_sub = next((s for s in config if s.get("id") == service_id), None)
            
            logs_text = "No log file specified."
            if target_sub and target_sub.get("log_file"):
                lf = target_sub["log_file"]
                if os.path.exists(lf):
                    try:
                        logs_text = run_cmd(f"tail -n {lines_count} '{lf}'")
                    except Exception as e:
                        logs_text = f"Error reading log: {e}"
                else:
                    logs_text = f"Log file ({lf}) does not exist yet (Service may be waiting to start)."
            self.send_json({"service_id": service_id, "logs": logs_text})
        else:
            super().do_GET()

    def do_POST(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path

        content_len = int(self.headers.get("Content-Length", 0))
        post_body = self.rfile.read(content_len).decode("utf-8") if content_len > 0 else "{}"
        try:
            req_data = json.loads(post_body)
        except Exception:
            req_data = {}

        if path == "/api/service/action":
            service_id = req_data.get("id")
            action = req_data.get("action")  # start, stop, restart
            config = load_services_config()
            target = next((s for s in config if s.get("id") == service_id), None)

            if not target:
                self.send_json({"success": False, "error": "Servicio no encontrado"}, status=404)
                return

            msg = ""
            if action == "stop":
                cmd = target.get("stop_cmd")
                if cmd:
                    run_cmd(cmd)
                msg = f"Servicio {target['name']} detenido."
            elif action == "start":
                cmd = target.get("start_cmd")
                if cmd:
                    run_async_cmd(cmd)
                msg = f"Servicio {target['name']} iniciado."
            elif action == "restart":
                stop_cmd = target.get("stop_cmd")
                start_cmd = target.get("start_cmd")
                if stop_cmd:
                    run_cmd(stop_cmd)
                time.sleep(1)
                if start_cmd:
                    run_async_cmd(start_cmd)
                msg = f"Servicio {target['name']} reiniciado con éxito."

            time.sleep(1.5)
            updated_status = get_all_services_status()
            self.send_json({"success": True, "message": msg, "data": updated_status})

        elif path == "/api/terminal/exec":
            command = req_data.get("command", "").strip()
            if not command:
                self.send_json({"output": "Comando vacío."})
                return
            
            output = run_cmd(f"su -c '{command}'")
            self.send_json({"output": output, "command": command})
        else:
            self.send_json({"error": "Ruta no encontrada"}, status=404)

    def send_json(self, data, status=200):
        body = json.dumps(data, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Cache-Control", "no-cache, no-store, must-revalidate")
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, format, *args):
        pass

class ThreadingHTTPServer(socketserver.ThreadingMixIn, http.server.HTTPServer):
    daemon_threads = True
    allow_reuse_address = True

if __name__ == "__main__":
    print(f"=== PIXELDOCK PRO v1.0 ===")
    print(f"Panel de Control de Microservicios corriendo en http://0.0.0.0:{PORT}")
    print(f"Directorio Estático: {STATIC_DIR}")
    print(f"Configuración: {SERVICES_FILE}")

    httpd = ThreadingHTTPServer(("0.0.0.0", PORT), DockRequestHandler)
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nDeteniendo PixelDock...")
        httpd.server_close()
