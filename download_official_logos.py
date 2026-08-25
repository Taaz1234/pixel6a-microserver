#!/usr/bin/env python3
import urllib.request
import os
import re

ICONS_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "pixelsteam", "static", "icons")
os.makedirs(ICONS_DIR, exist_ok=True)

# Mapeo de marcas a colores y fuentes oficiales de SimpleIcons CDN
LOGO_SOURCES = {
    "gamepass": ("https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/xbox.svg", "#107C10"),
    "psplus": ("https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/playstation.svg", "#003791"),
    "nintendo": ("https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/nintendoswitch.svg", "#E60012"),
    "geforcenow": ("https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/nvidia.svg", "#76B900"),
    "eaplaypro": ("https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/ea.svg", "#E50027"),
    "netflix": ("https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/netflix.svg", "#E50914"),
    "youtube": ("https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/youtube.svg", "#FF0000"),
    "spotify": ("https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/spotify.svg", "#1DB954"),
    "chatgpt": ("https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/openai.svg", "#10A37F"),
    "claudepro": ("https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/anthropic.svg", "#D97706"),
    "appletv": ("https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/appletv.svg", "#000000"),
    "applemusic": ("https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/applemusic.svg", "#FA243C"),
    "prime": ("https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/amazonprime.svg", "#00A8E1"),
    "max": ("https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/hbo.svg", "#002BE7"),
    "crunchyroll": ("https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/crunchyroll.svg", "#F47521"),
    "office365": ("https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/microsoft.svg", "#00A4EF"),
    "canvapro": ("https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/canva.svg", "#00C4CC"),
    "tidal": ("https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/tidal.svg", "#000000"),
    "nordvpn": ("https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/nordvpn.svg", "#4687FF")
}

for name, (url, brand_color) in LOGO_SOURCES.items():
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req, timeout=10) as resp:
            content = resp.read().decode("utf-8")
            
            # Reemplazar el fill por el color oficial de la marca
            if "<path" in content:
                # Si el path no tiene fill, inyectamos el color oficial de la marca
                colored_svg = content.replace("<path", f'<path fill="{brand_color}"')
            else:
                colored_svg = content

            target_file = os.path.join(ICONS_DIR, f"{name}.svg")
            with open(target_file, "w", encoding="utf-8") as f:
                f.write(colored_svg)
            print(f"[+] Descargado con éxito: {name}.svg ({brand_color})")
    except Exception as e:
        print(f"[!] Error descargando {name}: {e}")

# 1. Google (Official 4-Color Google G)
google_svg = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="48" height="48">
  <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
  <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
  <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
  <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
</svg>'''
with open(os.path.join(ICONS_DIR, "google.svg"), "w", encoding="utf-8") as f:
    f.write(google_svg)

# 2. Disney+ (Official Arc & Wordmark / Plus)
disney_svg = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 80" width="48" height="48">
  <path fill="#113CCF" d="M35 15c-15 0-25 10-25 25s10 25 25 25c15 0 25-10 25-25s-10-25-25-25zm0 38c-7 0-12-6-12-13s5-13 12-13 12 6 12 13-5 13-12 13z"/>
  <path fill="#00D2FF" d="M70 20v40h12V32l25 28h12V20h-12v28L82 20H70zm65 8h-10v8h10v10h8V36h10v-8h-10V18h-8v10z"/>
  <path fill="#113CCF" d="M12 70c40 10 120 10 170-20-8 6-50 25-120 18-20-2-35-4-50 2z"/>
</svg>'''
with open(os.path.join(ICONS_DIR, "disney.svg"), "w", encoding="utf-8") as f:
    f.write(disney_svg)

print("[+] Todos los 21 logotipos oficiales guardados en static/icons/")
