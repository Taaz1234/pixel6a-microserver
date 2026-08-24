import os
import sys
import json
import time
import urllib.parse
import subprocess
import threading
from http.server import HTTPServer, SimpleHTTPRequestHandler

PORT = 8095
WEB_DIR = "/data/pixelserver/cinema_web"
MOVIES_DIR = "/sdcard/Media/Peliculas"
SERIES_DIR = "/sdcard/Media/Series"
ARIA2_BIN = "/data/pixelserver/aria2c"

active_downloads = {}

def sanitize_filename(name):
    # Preserve letters, numbers, spaces, periods, dashes, underscores
    clean = "".join([c for c in name if c.isalnum() or c in (' ', '.', '_', '-', '(', ')', '[', ']')]).rstrip()
    return clean if clean else "Descarga"

def download_worker(task_id, magnet_or_url, title, media_type):
    try:
        active_downloads[task_id]["status"] = "downloading"
        safe_title = sanitize_filename(title)
        
        # Decide destination folder based on media type
        if media_type == "series":
            base_dir = SERIES_DIR
        else:
            base_dir = MOVIES_DIR
            
        out_dir = os.path.join(base_dir, safe_title)
        os.makedirs(out_dir, exist_ok=True)
        active_downloads[task_id]["folder"] = out_dir
        
        # Fast multi-threaded download with DHT and public peer exchange
        cmd = [
            ARIA2_BIN,
            "--dir=" + out_dir,
            "--seed-time=0",
            "--max-connection-per-server=16",
            "--split=16",
            "--enable-dht=true",
            "--enable-peer-exchange=true",
            "--bt-enable-lpd=true",
            "--summary-interval=1",
            "--bt-stop-timeout=600",
            "--check-certificate=false",
            magnet_or_url
        ]
        
        process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True)
        active_downloads[task_id]["pid"] = process.pid
        
        for line in process.stdout:
            # Parse aria2 progress line: e.g. (35%) CN:4 SD:5.2MiB ETA:4m
            if "%" in line:
                try:
                    parts = line.split("(")
                    if len(parts) > 1:
                        pct_part = parts[1].split("%)")[0]
                        active_downloads[task_id]["progress"] = int(pct_part)
                except Exception:
                    pass
            if "MiB" in line or "KiB" in line or "MB/s" in line or "KB/s" in line:
                active_downloads[task_id]["speed"] = line.strip()
                
        process.wait()
        active_downloads[task_id]["progress"] = 100
        active_downloads[task_id]["status"] = "completed"
        active_downloads[task_id]["speed"] = f"Guardado con éxito en {media_type.capitalize()}"
    except Exception as e:
        active_downloads[task_id]["status"] = "error"
        active_downloads[task_id]["error"] = str(e)

class CinemaHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=WEB_DIR, **kwargs)

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        
        if parsed.path == "/api/downloads":
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(json.dumps({"downloads": active_downloads}).encode("utf-8"))
            
        elif parsed.path == "/api/download":
            params = urllib.parse.parse_qs(parsed.query)
            magnet = params.get("magnet", [""])[0]
            title = params.get("title", ["Descarga"])[0]
            media_type = params.get("type", ["movie"])[0].lower() # 'movie' or 'series'
            
            task_id = str(int(time.time() * 1000))
            active_downloads[task_id] = {
                "id": task_id,
                "title": title,
                "type": media_type,
                "progress": 0,
                "speed": "Conectando con semillas...",
                "status": "queued",
                "started_at": time.strftime("%H:%M:%S")
            }
            
            t = threading.Thread(target=download_worker, args=(task_id, magnet, title, media_type))
            t.daemon = True
            t.start()
            
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(json.dumps({"status": "started", "task_id": task_id}).encode("utf-8"))
            
        elif parsed.path == "/api/cancel":
            params = urllib.parse.parse_qs(parsed.query)
            task_id = params.get("task_id", [""])[0]
            if task_id in active_downloads:
                pid = active_downloads[task_id].get("pid")
                if pid:
                    try:
                        os.kill(pid, 9)
                    except Exception:
                        pass
                active_downloads[task_id]["status"] = "cancelled"
                active_downloads[task_id]["speed"] = "Descarga cancelada"
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(json.dumps({"status": "cancelled"}).encode("utf-8"))
            
        else:
            super().do_GET()

if __name__ == "__main__":
    if not os.path.exists(WEB_DIR):
        WEB_DIR = os.path.dirname(os.path.abspath(__file__))
    os.makedirs(MOVIES_DIR, exist_ok=True)
    os.makedirs(SERIES_DIR, exist_ok=True)
    httpd = HTTPServer(("0.0.0.0", PORT), CinemaHandler)
    print(f"PixelCinema Pro v2.0 running at http://0.0.0.0:{PORT}")
    httpd.serve_forever()
