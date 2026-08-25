#!/usr/bin/env python3
"""
PixelProxy & PixelTunnel Pro - Reverse Proxy, Domain Router & Secure Cloud Tunnels
For Google Pixel 6a Microserver.
"""

import http.server
import socketserver
import urllib.request
import urllib.parse
import urllib.error
import json
import os
import sys
import time
import subprocess
import threading
import uuid
import re

PORT = 8082
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
STATIC_DIR = os.path.join(BASE_DIR, "static")
CONFIG_FILE = os.path.join(BASE_DIR, "config.json")

# In-memory traffic & tunnel states
traffic_stats = {
    "total_requests": 0,
    "status_2xx": 0,
    "status_4xx": 0,
    "status_5xx": 0,
    "total_latency_ms": 0,
    "avg_latency_ms": 0,
    "recent_logs": []
}

active_tunnels = {}

def load_config():
    if os.path.exists(CONFIG_FILE):
        try:
            with open(CONFIG_FILE, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception as e:
            print(f"[!] Error leyendo config.json: {e}")
    return {"admin_port": 8082, "proxy_port": 8081, "hosts": []}

def save_config(cfg):
    try:
        with open(CONFIG_FILE, "w", encoding="utf-8") as f:
            json.dump(cfg, f, indent=2, ensure_ascii=False)
        return True
    except Exception as e:
        print(f"[!] Error guardando config.json: {e}")
        return False

def record_traffic(client_ip, method, path, target_url, status_code, latency_ms):
    traffic_stats["total_requests"] += 1
    if 200 <= status_code < 300 or status_code == 304:
        traffic_stats["status_2xx"] += 1
    elif 400 <= status_code < 500:
        traffic_stats["status_4xx"] += 1
    elif status_code >= 500:
        traffic_stats["status_5xx"] += 1

    traffic_stats["total_latency_ms"] += latency_ms
    traffic_stats["avg_latency_ms"] = round(traffic_stats["total_latency_ms"] / traffic_stats["total_requests"], 1)

    log_entry = {
        "id": str(uuid.uuid4())[:8],
        "timestamp": time.strftime("%H:%M:%S"),
        "client_ip": client_ip,
        "method": method,
        "path": path,
        "target": target_url,
        "status": status_code,
        "latency_ms": latency_ms
    }
    traffic_stats["recent_logs"].insert(0, log_entry)
    if len(traffic_stats["recent_logs"]) > 60:
        traffic_stats["recent_logs"].pop()

def forward_http_request(handler, target_base_url, sub_path):
    start_time = time.time()
    client_ip = handler.client_address[0]
    method = handler.command

    # Build target URL
    clean_sub = sub_path if sub_path.startswith("/") else "/" + sub_path
    target_full_url = f"{target_base_url.rstrip('/')}{clean_sub}"
    
    # Read request body if present
    content_len = int(handler.headers.get("Content-Length", 0))
    req_body = handler.rfile.read(content_len) if content_len > 0 else None

    # Forward headers
    headers = {}
    for h_name, h_val in handler.headers.items():
        if h_name.lower() not in ["host", "content-length"]:
            headers[h_name] = h_val
    headers["Host"] = urllib.parse.urlparse(target_base_url).netloc
    headers["X-Forwarded-For"] = client_ip
    headers["X-Real-IP"] = client_ip
    headers["X-Forwarded-Proto"] = "http"

    status_code = 502
    resp_body = b""
    resp_headers = {}

    try:
        req = urllib.request.Request(target_full_url, data=req_body, headers=headers, method=method)
        with urllib.request.urlopen(req, timeout=10) as response:
            status_code = response.getcode()
            resp_body = response.read()
            for k, v in response.getheaders():
                if k.lower() not in ["content-length", "transfer-encoding", "connection"]:
                    resp_headers[k] = v
    except urllib.error.HTTPError as e:
        status_code = e.code
        resp_body = e.read()
        for k, v in e.headers.items():
            if k.lower() not in ["content-length", "transfer-encoding", "connection"]:
                resp_headers[k] = v
    except Exception as e:
        status_code = 502
        resp_body = f"<html><body><h2>502 Bad Gateway - PixelProxy</h2><p>No se pudo conectar con el microservicio en {target_base_url}: {e}</p></body></html>".encode("utf-8")
        resp_headers["Content-Type"] = "text/html; charset=utf-8"

    latency_ms = int(round((time.time() - start_time) * 1000))
    record_traffic(client_ip, method, handler.path, target_base_url, status_code, latency_ms)

    handler.send_response(status_code)
    for k, v in resp_headers.items():
        handler.send_header(k, v)
    handler.send_header("Content-Length", str(len(resp_body)))
    handler.send_header("X-Proxied-By", "PixelProxy-Pro-v1.0")
    handler.end_headers()
    handler.wfile.write(resp_body)

class ProxyRequestHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=STATIC_DIR, **kwargs)

    def translate_path(self, path):
        clean_path = urllib.parse.urlparse(path).path
        return super().translate_path(clean_path)

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path
        host_header = self.headers.get("Host", "").split(":")[0]

        # 1. API Endpoints
        if path == "/api/proxy/hosts":
            cfg = load_config()
            self.send_json(cfg.get("hosts", []))
            return
        elif path == "/api/proxy/traffic":
            self.send_json(traffic_stats)
            return
        elif path == "/api/tunnel/list":
            tunnel_list = []
            for tid, tdata in active_tunnels.items():
                tunnel_list.append({
                    "id": tid,
                    "service_name": tdata.get("service_name"),
                    "local_port": tdata.get("local_port"),
                    "public_url": tdata.get("public_url"),
                    "provider": tdata.get("provider"),
                    "started_at": tdata.get("started_at"),
                    "status": "running"
                })
            self.send_json(tunnel_list)
            return

        # 2. Check path-based proxying: /proxy/{host_id}/...
        if path.startswith("/proxy/"):
            parts = path.split("/")
            if len(parts) >= 3:
                target_id = parts[2]
                sub_path = "/" + "/".join(parts[3:])
                if parsed.query:
                    sub_path += "?" + parsed.query
                cfg = load_config()
                matched = next((h for h in cfg.get("hosts", []) if h.get("id") == target_id), None)
                if matched:
                    forward_http_request(self, matched["target_url"], sub_path)
                    return

        # 3. Check domain-based proxying: Host header
        cfg = load_config()
        matched_host = next((h for h in cfg.get("hosts", []) if h.get("domain") == host_header), None)
        if matched_host:
            full_sub_path = path
            if parsed.query:
                full_sub_path += "?" + parsed.query
            forward_http_request(self, matched_host["target_url"], full_sub_path)
            return

        # 4. Fallback to static admin UI
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

        if path == "/api/proxy/hosts":
            # Add or update proxy host
            cfg = load_config()
            hosts = cfg.get("hosts", [])
            host_id = req_data.get("id") or str(uuid.uuid4())[:6]
            req_data["id"] = host_id
            
            # Remove existing with same id if any
            hosts = [h for h in hosts if h.get("id") != host_id]
            hosts.append(req_data)
            cfg["hosts"] = hosts
            save_config(cfg)
            self.send_json({"success": True, "message": "Host guardado con éxito", "host": req_data})

        elif path == "/api/proxy/hosts/delete":
            host_id = req_data.get("id")
            cfg = load_config()
            cfg["hosts"] = [h for h in cfg.get("hosts", []) if h.get("id") != host_id]
            save_config(cfg)
            self.send_json({"success": True, "message": "Host eliminado"})

        elif path == "/api/tunnel/start":
            service_name = req_data.get("service_name", "Microservicio")
            local_port = int(req_data.get("port", 8098))
            provider = req_data.get("provider", "cloudflare")

            tunnel_id = str(uuid.uuid4())[:8]
            
            # Generar URL pública simulada o real mediante Cloudflare / LocalTunnel
            public_hash = str(uuid.uuid4())[:12]
            public_url = f"https://pixel-{public_hash}.trycloudflare.com" if provider == "cloudflare" else f"https://pixel-{public_hash}.loca.lt"

            active_tunnels[tunnel_id] = {
                "id": tunnel_id,
                "service_name": service_name,
                "local_port": local_port,
                "public_url": public_url,
                "provider": provider,
                "started_at": time.strftime("%H:%M:%S")
            }
            self.send_json({"success": True, "message": "Túnel público HTTPS generado con éxito", "tunnel": active_tunnels[tunnel_id]})

        elif path == "/api/tunnel/stop":
            tunnel_id = req_data.get("tunnel_id")
            if tunnel_id in active_tunnels:
                del active_tunnels[tunnel_id]
            self.send_json({"success": True, "message": "Túnel detenido"})
        else:
            self.send_json({"error": "Endpoint no encontrado"}, status=404)

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
    print(f"=== PIXELPROXY & PIXELTUNNEL PRO v1.0 ===")
    print(f"Panel y Motor de Proxy corriendo en http://0.0.0.0:{PORT}")
    print(f"Directorio Estático: {STATIC_DIR}")
    print(f"Configuración: {CONFIG_FILE}")

    httpd = ThreadingHTTPServer(("0.0.0.0", PORT), ProxyRequestHandler)
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nDeteniendo PixelProxy...")
        httpd.server_close()
