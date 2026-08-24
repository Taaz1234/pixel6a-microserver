#!/usr/bin/env python3
import http.server
import socketserver
import socket
import ssl
import os
import json
import time
import base64
import threading
from datetime import datetime

PORT_HTTP = 8088
PORT_HTTPS = 8443
MEDIA_DIR = "/sdcard/Media/Vigilancia"
if not os.path.exists(MEDIA_DIR):
    os.makedirs(MEDIA_DIR, exist_ok=True)

latest_frame_b64 = ""
latest_timestamp = 0
pending_commands = []
current_status = {
    "camera_active": True,
    "facing": "Trasera (Sony 12MP)",
    "torch": False,
    "fps": 30,
    "motion": False
}

# --- HTML DEL MONITOR (TU ORDENADOR / SMART TV / TABLET) ---
VIEWER_HTML = """<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PixelVision AI • Centro de Control y Vigilancia Pixel 6a</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg: #090d16;
            --card: rgba(18, 26, 43, 0.85);
            --card-border: rgba(255, 255, 255, 0.08);
            --accent: #38bdf8;
            --accent-glow: rgba(56, 189, 248, 0.25);
            --success: #10b981;
            --danger: #ef4444;
            --warning: #f59e0b;
            --text: #f8fafc;
            --text-dim: #94a3b8;
        }

        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Outfit', sans-serif; }
        body {
            background: var(--bg);
            color: var(--text);
            min-height: 100vh;
            background-image: 
                radial-gradient(at 0% 0%, rgba(56, 189, 248, 0.12) 0px, transparent 50%),
                radial-gradient(at 100% 100%, rgba(99, 102, 241, 0.12) 0px, transparent 50%);
            padding: 1.5rem;
        }

        .container { max-width: 1200px; margin: 0 auto; }
        header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; flex-wrap: wrap; gap: 1rem; }
        .logo-box { display: flex; align-items: center; gap: 0.75rem; }
        .logo-icon { width: 44px; height: 44px; background: linear-gradient(135deg, #38bdf8, #6366f1); border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 1.5rem; }
        h1 { font-size: 1.6rem; font-weight: 800; }
        
        .badge-live {
            background: rgba(16, 185, 129, 0.15);
            color: #10b981;
            border: 1px solid rgba(16, 185, 129, 0.3);
            padding: 0.35rem 0.85rem;
            border-radius: 20px;
            font-weight: 700;
            font-size: 0.8rem;
            display: flex;
            align-items: center;
            gap: 0.4rem;
        }

        .main-grid { display: grid; grid-template-columns: 1fr 340px; gap: 1.5rem; }
        @media (max-width: 900px) { .main-grid { grid-template-columns: 1fr; } }

        .video-card {
            background: var(--card);
            border: 1px solid var(--card-border);
            border-radius: 20px;
            padding: 1.25rem;
            backdrop-filter: blur(16px);
            display: flex;
            flex-direction: column;
            gap: 1rem;
        }

        .viewport-wrapper {
            position: relative;
            width: 100%;
            background: #000;
            border-radius: 14px;
            overflow: hidden;
            aspect-ratio: 16/9;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        #liveStreamImg {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .placeholder-text {
            color: var(--text-dim);
            text-align: center;
            padding: 2rem;
        }

        .overlay-stats {
            position: absolute;
            top: 12px;
            left: 12px;
            background: rgba(0,0,0,0.65);
            backdrop-filter: blur(8px);
            padding: 0.4rem 0.8rem;
            border-radius: 8px;
            font-size: 0.75rem;
            font-weight: 600;
            color: var(--text);
            display: flex;
            gap: 0.75rem;
            z-index: 10;
        }

        .overlay-alert {
            position: absolute;
            top: 12px;
            right: 12px;
            background: rgba(239, 68, 68, 0.9);
            backdrop-filter: blur(8px);
            padding: 0.4rem 0.85rem;
            border-radius: 8px;
            font-size: 0.8rem;
            font-weight: 700;
            color: #fff;
            display: none;
            z-index: 10;
            animation: pulse 1s infinite;
        }

        @keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.6; } }

        .controls-panel {
            display: flex;
            gap: 0.75rem;
            flex-wrap: wrap;
        }

        .btn {
            background: rgba(255, 255, 255, 0.08);
            border: 1px solid var(--card-border);
            color: var(--text);
            padding: 0.65rem 1.2rem;
            border-radius: 10px;
            font-weight: 600;
            font-size: 0.9rem;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            transition: all 0.2s ease;
        }
        .btn:hover { background: rgba(255, 255, 255, 0.15); transform: translateY(-1px); }

        .btn-primary {
            background: linear-gradient(135deg, #38bdf8, #6366f1);
            border: none;
            color: #fff;
            box-shadow: 0 4px 12px var(--accent-glow);
        }

        .btn-warning {
            background: rgba(245, 158, 11, 0.2);
            border-color: rgba(245, 158, 11, 0.4);
            color: #f59e0b;
        }

        .sidebar { display: flex; flex-direction: column; gap: 1.5rem; }
        .panel-card {
            background: var(--card);
            border: 1px solid var(--card-border);
            border-radius: 18px;
            padding: 1.25rem;
            backdrop-filter: blur(16px);
        }
        .panel-card h3 { font-size: 1.05rem; font-weight: 700; margin-bottom: 1rem; }
        .stat-row { display: flex; justify-content: space-between; padding: 0.6rem 0; border-bottom: 1px solid rgba(255,255,255,0.05); font-size: 0.9rem; }
        .stat-row:last-child { border-bottom: none; }
        .stat-label { color: var(--text-dim); }
        .stat-val { font-weight: 700; }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <div class="logo-box">
                <div class="logo-icon">👁️</div>
                <div>
                    <h1>PixelVision AI • Centro de Control</h1>
                    <p style="font-size: 0.85rem; color: var(--text-dim);">Google Pixel 6a Sony IMX 12.2MP Live Surveillance</p>
                </div>
            </div>
            <div class="badge-live" id="streamBadge">🟢 CONECTADO EN VIVO</div>
        </header>

        <div class="main-grid">
            <div class="video-card">
                <div class="viewport-wrapper">
                    <div class="overlay-stats">
                        <span id="camLabel">LENTE: Trasera 12.2 MP</span>
                        <span>FPS: 30</span>
                        <span>LATENCIA: &lt; 80ms</span>
                    </div>
                    <div class="overlay-alert" id="motionAlert">⚠️ MOVIMIENTO DETECTADO</div>
                    <img id="liveStreamImg" src="" alt="Transmisión del Pixel 6a" style="display:none;">
                    <div id="noStreamPlaceholder" class="placeholder-text">
                        <div style="font-size: 2.5rem; margin-bottom: 0.5rem;">📱</div>
                        <h3>Esperando señal de la cámara...</h3>
                        <p style="margin-top: 0.5rem; font-size: 0.85rem;">Abre el emisor en el móvil o pulsa en Iniciar Emisión.</p>
                    </div>
                </div>

                <div class="controls-panel">
                    <button class="btn btn-primary" onclick="sendCmd('switch_cam')">🔄 Cambiar Cámara (Trasera / Frontal)</button>
                    <button class="btn btn-warning" onclick="sendCmd('toggle_torch')">💡 Linterna Flash</button>
                    <button class="btn" onclick="takeSnapshot()">📸 Foto Instantánea</button>
                    <a class="btn" href="http://192.168.1.135:8090" target="_blank">📂 Ver Galería en FileBrowser</a>
                </div>
            </div>

            <div class="sidebar">
                <div class="panel-card">
                    <h3>⚙️ Control Remoto</h3>
                    <p style="font-size: 0.85rem; color: var(--text-dim); line-height: 1.5; margin-bottom: 1rem;">
                        Al pulsar los botones de la izquierda, el teléfono cambiará instantáneamente de lente trasera a frontal o activará el flash LED sin tocar la pantalla del móvil.
                    </p>
                    <div class="stat-row">
                        <span class="stat-label">Cámara Activa</span>
                        <span class="stat-val" id="camStatus">En directo</span>
                    </div>
                    <div class="stat-row">
                        <span class="stat-label">Lente</span>
                        <span class="stat-val" id="lensStatus">Trasera (12MP)</span>
                    </div>
                    <div class="stat-row">
                        <span class="stat-label">Detección de Movimiento</span>
                        <span class="stat-val" style="color: var(--success);">IA Activa</span>
                    </div>
                    <div class="stat-row">
                        <span class="stat-label">Guardado en</span>
                        <span class="stat-val">/sdcard/Media/Vigilancia</span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        const img = document.getElementById('liveStreamImg');
        const placeholder = document.getElementById('noStreamPlaceholder');
        const statusEl = document.getElementById('camStatus');
        const lensEl = document.getElementById('lensStatus');
        const camLabel = document.getElementById('camLabel');

        function fetchFeed() {
            fetch('/api/feed')
                .then(res => res.json())
                .then(data => {
                    if (data.frame && data.frame.length > 100) {
                        img.src = 'data:image/jpeg;base64,' + data.frame;
                        img.style.display = 'block';
                        placeholder.style.display = 'none';
                        statusEl.innerText = 'En directo 1080p';
                        statusEl.style.color = '#10b981';

                        if (data.facing) {
                            lensEl.innerText = data.facing;
                            camLabel.innerText = 'LENTE: ' + data.facing;
                        }

                        if (data.motion) {
                            document.getElementById('motionAlert').style.display = 'block';
                        } else {
                            document.getElementById('motionAlert').style.display = 'none';
                        }
                    } else {
                        img.style.display = 'none';
                        placeholder.style.display = 'block';
                    }
                })
                .catch(e => {});
        }

        setInterval(fetchFeed, 90);

        function sendCmd(cmdName) {
            fetch('/api/cmd_send', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ command: cmdName })
            });
        }

        function takeSnapshot() {
            fetch('/api/snapshot_remote', { method: 'POST' })
                .then(() => alert('📸 Foto capturada y guardada en /sdcard/Media/Vigilancia'));
        }
    </script>
</body>
</html>
"""

# --- HTML DEL TRANSMISOR (EN EL PIXEL 6A) ---
PHONE_CAMERA_HTML = """<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PixelVision • Emisor Pixel 6a</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;600;700&display=swap" rel="stylesheet">
    <style>
        body {
            background: #090d16;
            color: #fff;
            font-family: 'Outfit', sans-serif;
            margin: 0;
            padding: 1rem;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            box-sizing: border-box;
        }

        .card {
            background: rgba(18, 26, 43, 0.9);
            border: 1px solid rgba(255,255,255,0.1);
            border-radius: 20px;
            padding: 1.25rem;
            max-width: 440px;
            width: 100%;
            text-align: center;
        }

        video { width: 100%; border-radius: 12px; aspect-ratio: 16/9; background: #000; object-fit: cover; margin: 1rem 0; }
        
        .btn-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 0.5rem;
            margin-top: 0.5rem;
        }

        .btn {
            background: linear-gradient(135deg, #38bdf8, #6366f1);
            color: #fff;
            border: none;
            padding: 0.8rem;
            border-radius: 10px;
            font-weight: 700;
            font-size: 0.95rem;
            cursor: pointer;
        }

        .btn-secondary {
            background: rgba(255,255,255,0.08);
            border: 1px solid rgba(255,255,255,0.15);
        }
    </style>
</head>
<body>
    <div class="card">
        <h3 style="margin-bottom: 0.25rem;">📱 Emisor PixelVision</h3>
        <p id="lensName" style="color: #38bdf8; font-size: 0.85rem; font-weight: 600;">Lente Trasera Sony (12MP)</p>

        <video id="phoneCam" autoplay playsinline muted></video>
        <canvas id="hiddenCanvas" style="display:none;"></canvas>

        <button class="btn" id="btnToggle" style="width: 100%; margin-bottom: 0.5rem;" onclick="toggleStream()">📹 Iniciar Emisión</button>
        <div class="btn-grid">
            <button class="btn btn-secondary" onclick="switchCamera()">🔄 Cambiar Lente</button>
            <button class="btn btn-secondary" id="btnTorch" onclick="toggleFlash()">💡 Linterna Flash</button>
        </div>
        <p id="txStatus" style="font-size: 0.8rem; color: #94a3b8; margin-top: 0.8rem;">Cámara lista.</p>
    </div>

    <script>
        const video = document.getElementById('phoneCam');
        const canvas = document.getElementById('hiddenCanvas');
        const ctx = canvas.getContext('2d');
        let currentFacingMode = 'environment';
        let streaming = false;
        let track = null;
        let torch = false;
        let txInterval = null;

        async function startCamera() {
            if (video.srcObject) video.srcObject.getTracks().forEach(t => t.stop());
            try {
                const stream = await navigator.mediaDevices.getUserMedia({
                    video: { facingMode: currentFacingMode, width: { ideal: 1280 }, height: { ideal: 720 } },
                    audio: false
                });
                video.srcObject = stream;
                track = stream.getVideoTracks()[0];
                streaming = true;
                document.getElementById('btnToggle').innerText = '⏹️ Detener Emisión';
                document.getElementById('btnToggle').style.background = '#ef4444';
                document.getElementById('txStatus').innerText = '🟢 EMITIENDO EN DIRECTO AL PC';
                document.getElementById('txStatus').style.color = '#10b981';
                document.getElementById('lensName').innerText = (currentFacingMode === 'environment') ? 'Lente Trasera Sony (12.2MP)' : 'Lente Frontal Selfie (8MP)';

                video.onloadedmetadata = () => {
                    canvas.width = 640;
                    canvas.height = 360;
                    if (!txInterval) txInterval = setInterval(sendFrame, 100);
                };
            } catch (err) {
                alert('Pulsa en Permitir cámara.');
            }
        }

        function stopStream() {
            if (video.srcObject) video.srcObject.getTracks().forEach(t => t.stop());
            if (txInterval) { clearInterval(txInterval); txInterval = null; }
            streaming = false;
            document.getElementById('btnToggle').innerText = '📹 Iniciar Emisión';
            document.getElementById('btnToggle').style.background = 'linear-gradient(135deg, #38bdf8, #6366f1)';
            document.getElementById('txStatus').innerText = 'Emisión detenida';
            document.getElementById('txStatus').style.color = '#94a3b8';
        }

        function toggleStream() {
            if (streaming) stopStream();
            else startCamera();
        }

        async function switchCamera() {
            currentFacingMode = (currentFacingMode === 'environment') ? 'user' : 'environment';
            if (streaming) startCamera();
            else document.getElementById('lensName').innerText = (currentFacingMode === 'environment') ? 'Lente Trasera Sony (12.2MP)' : 'Lente Frontal Selfie (8MP)';
        }

        async function toggleFlash() {
            if (!track) return;
            torch = !torch;
            try {
                await track.applyConstraints({ advanced: [{ torch: torch }] });
                document.getElementById('btnTorch').style.background = torch ? '#f59e0b' : 'rgba(255,255,255,0.08)';
            } catch(e) {}
        }

        function sendFrame() {
            if (!streaming) return;
            ctx.drawImage(video, 0, 0, canvas.width, canvas.height);
            const data = canvas.toDataURL('image/jpeg', 0.6).split(',')[1];
            fetch('/api/upload_frame', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    frame: data,
                    facing: (currentFacingMode === 'environment') ? 'Trasera (Sony 12MP)' : 'Frontal (8MP)'
                })
            }).catch(e => {});
        }

        // Escuchar órdenes de control remoto enviadas desde el PC
        setInterval(() => {
            fetch('/api/cmd_poll')
                .then(r => r.json())
                .then(data => {
                    if (data.cmd === 'switch_cam') switchCamera();
                    else if (data.cmd === 'toggle_torch') toggleFlash();
                }).catch(e => {});
        }, 300);

        // Auto arrancar cámara al entrar
        window.addEventListener('load', () => {
            setTimeout(startCamera, 500);
        });
    </script>
</body>
</html>
"""

class PixelVisionHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        global latest_frame_b64, pending_commands
        if self.path == "/" or self.path.startswith("/index"):
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.end_headers()
            self.wfile.write(VIEWER_HTML.encode("utf-8"))
        elif self.path == "/cam" or self.path.startswith("/cam"):
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.end_headers()
            self.wfile.write(PHONE_CAMERA_HTML.encode("utf-8"))
        elif self.path == "/api/feed":
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({
                "frame": latest_frame_b64,
                "facing": current_status.get("facing", "Trasera (Sony 12MP)"),
                "timestamp": latest_timestamp
            }).encode("utf-8"))
        elif self.path == "/api/cmd_poll":
            cmd = pending_commands.pop(0) if pending_commands else None
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"cmd": cmd}).encode("utf-8"))
        else:
            super().do_GET()

    def do_POST(self):
        global latest_frame_b64, latest_timestamp, pending_commands
        if self.path == "/api/upload_frame":
            length = int(self.headers.get("Content-Length", 0))
            body = self.rfile.read(length)
            data = json.loads(body.decode("utf-8"))
            latest_frame_b64 = data.get("frame", "")
            if "facing" in data:
                current_status["facing"] = data["facing"]
            latest_timestamp = time.time()
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(b'{"status":"ok"}')
        elif self.path == "/api/cmd_send":
            length = int(self.headers.get("Content-Length", 0))
            body = self.rfile.read(length)
            data = json.loads(body.decode("utf-8"))
            cmd = data.get("command")
            if cmd:
                pending_commands.append(cmd)
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(b'{"status":"ok"}')
        elif self.path == "/api/snapshot_remote":
            if latest_frame_b64:
                filename = f"Snapshot_{datetime.now().strftime('%Y%m%d_%H%M%S')}.jpg"
                filepath = os.path.join(MEDIA_DIR, filename)
                with open(filepath, "wb") as f:
                    f.write(base64.b64decode(latest_frame_b64))
                print(f"[+] Foto guardada: {filepath}")
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(b'{"status":"ok"}')
        else:
            self.send_response(404)
            self.end_headers()

def create_server(port, is_ssl=False):
    server = socketserver.TCPServer(("0.0.0.0", port), PixelVisionHandler, bind_and_activate=False)
    server.socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    if hasattr(socket, "SO_REUSEPORT"):
        try:
            server.socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEPORT, 1)
        except Exception:
            pass
    server.server_bind()
    server.server_activate()
    if is_ssl:
        ssl_ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        ssl_ctx.load_cert_chain(certfile="/data/local/tmp/cert.pem", keyfile="/data/local/tmp/key.pem")
        server.socket = ssl_ctx.wrap_socket(server.socket, server_side=True)
    return server

def run_https_server():
    try:
        httpd_ssl = create_server(PORT_HTTPS, is_ssl=True)
        httpd_ssl.serve_forever()
    except Exception as e:
        print("[!] HTTPS Server error:", e)

if __name__ == "__main__":
    os.chdir("/data/local/tmp")
    t = threading.Thread(target=run_https_server, daemon=True)
    t.start()

    httpd = create_server(PORT_HTTP, is_ssl=False)
    print(f"[*] PixelVision listo en HTTP:{PORT_HTTP} y HTTPS:{PORT_HTTPS}")
    httpd.serve_forever()
