#!/usr/bin/env python3
import urllib.request
import os

ICONS_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "pixelsteam", "static", "icons")
os.makedirs(ICONS_DIR, exist_ok=True)

# 21 Plataformas con URLs oficiales de Iconify (calidad vectorial 100% oficial)
SOURCES = {
    "gamepass": "https://api.iconify.design/simple-icons:xbox.svg?color=%23107c10",
    "psplus": "https://api.iconify.design/simple-icons:playstation.svg?color=%23003791",
    "nintendo": "https://api.iconify.design/simple-icons:nintendoswitch.svg?color=%23e60012",
    "geforcenow": "https://api.iconify.design/logos:nvidia.svg",
    "eaplaypro": "https://api.iconify.design/simple-icons:ea.svg?color=%23e50027",
    "netflix": "https://api.iconify.design/logos:netflix-icon.svg",
    "disney": "https://api.iconify.design/thesvg-color:disney-plus.svg",
    "youtube": "https://api.iconify.design/logos:youtube-icon.svg",
    "spotify": "https://api.iconify.design/logos:spotify-icon.svg",
    "google": "https://api.iconify.design/logos:google-icon.svg",
    "chatgpt": "https://api.iconify.design/logos:openai-icon.svg",
    "claudepro": "https://api.iconify.design/simple-icons:anthropic.svg?color=%23cc785c",
    "appletv": "https://api.iconify.design/logos:apple.svg",
    "applemusic": "https://api.iconify.design/simple-icons:applemusic.svg?color=%23fc3c44",
    "prime": "https://api.iconify.design/simple-icons:amazonprime.svg?color=%2300a8e1",
    "max": "https://api.iconify.design/simple-icons:hbo.svg?color=%23002be7",
    "crunchyroll": "https://api.iconify.design/simple-icons:crunchyroll.svg?color=%23f47521",
    "office365": "https://api.iconify.design/logos:microsoft-icon.svg",
    "canvapro": "https://api.iconify.design/simple-icons:canva.svg?color=%2300c4cc",
    "tidal": "https://api.iconify.design/simple-icons:tidal.svg?color=%23000000",
    "nordvpn": "https://api.iconify.design/simple-icons:nordvpn.svg?color=%234687ff"
}

for name, url in SOURCES.items():
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req, timeout=10) as resp:
            content = resp.read()
            target = os.path.join(ICONS_DIR, f"{name}.svg")
            with open(target, "wb") as f:
                f.write(content)
            print(f"[+] Descargado: {name}.svg ({len(content)} bytes)")
    except Exception as e:
        print(f"[!] Error descargando {name}: {e}")

print("[+] Proceso completado con éxito.")
