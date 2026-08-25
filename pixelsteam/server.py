#!/usr/bin/env python3
"""
PixelSteam & Subscriptions Deals Server v1.1.0
Self-hosted Global Regional Price Comparator for Games & Streaming Subscriptions.
"""

import http.server
import socketserver
import urllib.request
import urllib.parse
import json
import os
import time
import threading
from concurrent.futures import ThreadPoolExecutor

PORT = 8098
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
STATIC_DIR = os.path.join(BASE_DIR, "static")

CACHE = {}
CACHE_TTL = 3600  # 1 hora

# Tasas de cambio de divisas aproximadas a EUR
EXCHANGE_RATES = {
    "EUR": 1.0,
    "USD": 0.92,
    "UAH": 0.022,    # Ucrania
    "KZT": 0.00185,  # Kazajistán
    "TRY": 0.027,    # Turquía
    "ARS": 0.00092,  # Argentina
    "CNY": 0.127,    # China
    "BRL": 0.165,    # Brasil
    "INR": 0.0108,   # India
    "GBP": 1.17,     # Reino Unido
    "PKR": 0.0033,   # Pakistán
    "NGN": 0.00061,  # Nigeria
    "EGP": 0.019,    # Egipto
    "PHP": 0.016     # Filipinas
}

REGIONS = [
    {"code": "es", "name": "España / Europa", "flag": "🇪🇸", "currency": "EUR"},
    {"code": "ua", "name": "Ucrania", "flag": "🇺🇦", "currency": "UAH"},
    {"code": "kz", "name": "Kazajistán", "flag": "🇰🇿", "currency": "KZT"},
    {"code": "tr", "name": "Turquía (MENA)", "flag": "🇹🇷", "currency": "USD"},
    {"code": "ar", "name": "Argentina (LATAM)", "flag": "🇦🇷", "currency": "USD"},
    {"code": "cn", "name": "China", "flag": "🇨🇳", "currency": "CNY"},
    {"code": "br", "name": "Brasil", "flag": "🇧🇷", "currency": "BRL"},
    {"code": "in", "name": "India", "flag": "🇮🇳", "currency": "INR"},
    {"code": "us", "name": "Estados Unidos", "flag": "🇺🇸", "currency": "USD"}
]

# Base de datos global de suscripciones digitales
SUBSCRIPTIONS = [
    {
        "id": "netflix",
        "name": "Netflix Premium (4K + 4 Pantallas)",
        "category": "Streaming Vídeo",
        "icon": "fa-brands fa-netflix",
        "color": "#E50914",
        "image": "https://assets.nflxext.com/ffe/siteui/vlv3/9c5457b8-9ab0-4a04-9fc1-e608d5670f1a/711a76a8-7f91-455b-9d41-477cfb8813a4/ES-es-20210719-popsignuptwoweeks-perspective_alpha_website_small.jpg",
        "spain_price": 17.99,
        "prices": [
            {"region": "Pakistán", "flag": "🇵🇰", "currency": "PKR", "amount": 1100, "rate_key": "PKR"},
            {"region": "Nigeria", "flag": "🇳🇬", "currency": "NGN", "amount": 5000, "rate_key": "NGN"},
            {"region": "Egipto", "flag": "🇪🇬", "currency": "EGP", "amount": 250, "rate_key": "EGP"},
            {"region": "Turquía", "flag": "🇹🇷", "currency": "TRY", "amount": 299.99, "rate_key": "TRY"},
            {"region": "Argentina", "flag": "🇦🇷", "currency": "ARS", "amount": 8999, "rate_key": "ARS"},
            {"region": "India", "flag": "🇮🇳", "currency": "INR", "amount": 649, "rate_key": "INR"},
            {"region": "Brasil", "flag": "🇧🇷", "currency": "BRL", "amount": 55.90, "rate_key": "BRL"},
            {"region": "España", "flag": "🇪🇸", "currency": "EUR", "amount": 17.99, "rate_key": "EUR"}
        ],
        "notes": "Acceso a resolución 4K HDR y descargas en 6 dispositivos."
    },
    {
        "id": "gamepass",
        "name": "Xbox Game Pass Ultimate (PC + Xbox + Cloud)",
        "category": "Videojuegos",
        "icon": "fa-brands fa-xbox",
        "color": "#107C10",
        "image": "https://compass-ssl.xbox.com/assets/f0/cd/f0cd237c-3720-4a7b-83c3-d9faecb6cc44.jpg?n=Game-Pass-Ultimate_Sharing-Image_1920x1080.jpg",
        "spain_price": 17.99,
        "prices": [
            {"region": "India", "flag": "🇮🇳", "currency": "INR", "amount": 549, "rate_key": "INR"},
            {"region": "Turquía", "flag": "🇹🇷", "currency": "TRY", "amount": 209, "rate_key": "TRY"},
            {"region": "Brasil", "flag": "🇧🇷", "currency": "BRL", "amount": 49.99, "rate_key": "BRL"},
            {"region": "Argentina", "flag": "🇦🇷", "currency": "ARS", "amount": 9999, "rate_key": "ARS"},
            {"region": "EE.UU.", "flag": "🇺🇸", "currency": "USD", "amount": 16.99, "rate_key": "USD"},
            {"region": "España", "flag": "🇪🇸", "currency": "EUR", "amount": 17.99, "rate_key": "EUR"}
        ],
        "notes": "Incluye cientos de juegos día 1, EA Play, multijugador online y juego en la nube."
    },
    {
        "id": "youtube",
        "name": "YouTube Premium (Sin Anuncios + Music)",
        "category": "Streaming / Música",
        "icon": "fa-brands fa-youtube",
        "color": "#FF0000",
        "image": "https://www.gstatic.com/youtube/img/promos/growth/ytp_full_social_banner_1920x1080.png",
        "spain_price": 13.99,
        "prices": [
            {"region": "Ucrania", "flag": "🇺🇦", "currency": "UAH", "amount": 99, "rate_key": "UAH"},
            {"region": "Turquía", "flag": "🇹🇷", "currency": "TRY", "amount": 79.99, "rate_key": "TRY"},
            {"region": "India", "flag": "🇮🇳", "currency": "INR", "amount": 149, "rate_key": "INR"},
            {"region": "Filipinas", "flag": "🇵🇭", "currency": "PHP", "amount": 159, "rate_key": "PHP"},
            {"region": "Argentina", "flag": "🇦🇷", "currency": "ARS", "amount": 3499, "rate_key": "ARS"},
            {"region": "Brasil", "flag": "🇧🇷", "currency": "BRL", "amount": 24.90, "rate_key": "BRL"},
            {"region": "España", "flag": "🇪🇸", "currency": "EUR", "amount": 13.99, "rate_key": "EUR"}
        ],
        "notes": "Cero anuncios en todos los vídeos de YouTube, reproducción en segundo plano y YouTube Music Premium."
    },
    {
        "id": "spotify",
        "name": "Spotify Premium Individual",
        "category": "Música",
        "icon": "fa-brands fa-spotify",
        "color": "#1DB954",
        "image": "https://storage.googleapis.com/pr-newsroom-wp/1/2018/11/Spotify_Logo_CMYK_Green.png",
        "spain_price": 10.99,
        "prices": [
            {"region": "Pakistán", "flag": "🇵🇰", "currency": "PKR", "amount": 349, "rate_key": "PKR"},
            {"region": "India", "flag": "🇮🇳", "currency": "INR", "amount": 119, "rate_key": "INR"},
            {"region": "Turquía", "flag": "🇹🇷", "currency": "TRY", "amount": 59.99, "rate_key": "TRY"},
            {"region": "Filipinas", "flag": "🇵🇭", "currency": "PHP", "amount": 149, "rate_key": "PHP"},
            {"region": "Brasil", "flag": "🇧🇷", "currency": "BRL", "amount": 21.90, "rate_key": "BRL"},
            {"region": "Argentina", "flag": "🇦🇷", "currency": "ARS", "amount": 2499, "rate_key": "ARS"},
            {"region": "España", "flag": "🇪🇸", "currency": "EUR", "amount": 10.99, "rate_key": "EUR"}
        ],
        "notes": "Música sin anuncios a máxima calidad (320kbps) y modo offline ilimitado."
    },
    {
        "id": "disney",
        "name": "Disney+ Premium (4K UHD)",
        "category": "Streaming Vídeo",
        "icon": "fa-solid fa-wand-magic-sparkles",
        "color": "#113CCF",
        "image": "https://static-assets.bamgrid.com/product/disneyplus/images/share-default.14fadd993578b3f1718d16bf63763ff8.png",
        "spain_price": 11.99,
        "prices": [
            {"region": "Turquía", "flag": "🇹🇷", "currency": "TRY", "amount": 164.99, "rate_key": "TRY"},
            {"region": "India", "flag": "🇮🇳", "currency": "INR", "amount": 299, "rate_key": "INR"},
            {"region": "Brasil", "flag": "🇧🇷", "currency": "BRL", "amount": 43.90, "rate_key": "BRL"},
            {"region": "Argentina", "flag": "🇦🇷", "currency": "ARS", "amount": 7399, "rate_key": "ARS"},
            {"region": "España", "flag": "🇪🇸", "currency": "EUR", "amount": 11.99, "rate_key": "EUR"}
        ],
        "notes": "Contenido de Disney, Pixar, Marvel, Star Wars, National Geographic y Star en 4K."
    },
    {
        "id": "crunchyroll",
        "name": "Crunchyroll Mega Fan",
        "category": "Anime",
        "icon": "fa-solid fa-play",
        "color": "#F47521",
        "image": "https://images.ctfassets.net/4cd45et68cgf/7xG4sZq347mZ7mN5YyW7fH/cf26802e071c778fa81e626e84db81d6/crunchyroll-brand-banner.jpg",
        "spain_price": 6.49,
        "prices": [
            {"region": "Argentina", "flag": "🇦🇷", "currency": "ARS", "amount": 1499, "rate_key": "ARS"},
            {"region": "Turquía", "flag": "🇹🇷", "currency": "TRY", "amount": 49.99, "rate_key": "TRY"},
            {"region": "Brasil", "flag": "🇧🇷", "currency": "BRL", "amount": 19.99, "rate_key": "BRL"},
            {"region": "España", "flag": "🇪🇸", "currency": "EUR", "amount": 6.49, "rate_key": "EUR"}
        ],
        "notes": "Todos los animes en simulcast con Japón, sin anuncios, descargas y 4 dispositivos simultáneos."
    },
    {
        "id": "chatgpt",
        "name": "ChatGPT Plus (GPT-4o & Canvas)",
        "category": "Inteligencia Artificial",
        "icon": "fa-solid fa-robot",
        "color": "#10A37F",
        "image": "https://images.openai.com/blob/8b965f32-6a75-4302-b2d9-1c9f8095b341/chatgpt-share-og.png",
        "spain_price": 22.99,
        "prices": [
            {"region": "Turquía", "flag": "🇹🇷", "currency": "TRY", "amount": 499.99, "rate_key": "TRY"},
            {"region": "EE.UU.", "flag": "🇺🇸", "currency": "USD", "amount": 20.00, "rate_key": "USD"},
            {"region": "Brasil", "flag": "🇧🇷", "currency": "BRL", "amount": 99.90, "rate_key": "BRL"},
            {"region": "España", "flag": "🇪🇸", "currency": "EUR", "amount": 22.99, "rate_key": "EUR"}
        ],
        "notes": "Acceso ilimitado a GPT-4o, generación de imágenes con DALL-E 3 y modo de voz avanzado."
    }
]

def fetch_json(url):
    req = urllib.request.Request(url, headers={
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
        "Accept-Language": "es-ES,es;q=0.9,en;q=0.8"
    })
    try:
        with urllib.request.urlopen(req, timeout=8) as resp:
            return json.loads(resp.read().decode("utf-8", errors="ignore"))
    except Exception as e:
        return None

def update_exchange_rates():
    global EXCHANGE_RATES
    try:
        data = fetch_json("https://open.er-api.com/v6/latest/EUR")
        if data and "rates" in data:
            rates = data["rates"]
            for curr in EXCHANGE_RATES.keys():
                if curr in rates and rates[curr] > 0:
                    EXCHANGE_RATES[curr] = round(1.0 / rates[curr], 6)
            print("[+] Tasas de divisas en vivo actualizadas con éxito.")
    except Exception as e:
        print(f"[!] Tasas fijas en memoria: {e}")

update_exchange_rates()

def get_processed_subscriptions():
    results = []
    for sub in SUBSCRIPTIONS:
        regional_list = []
        spain_price = sub["spain_price"]

        for p in sub["prices"]:
            rate = EXCHANGE_RATES.get(p["rate_key"], 1.0)
            eur_price = round(p["amount"] * rate, 2)
            saved_eur = round(max(0, spain_price - eur_price), 2)
            saved_pct = int(round((saved_eur / spain_price) * 100)) if spain_price > 0 else 0

            regional_list.append({
                "region": p["region"],
                "flag": p["flag"],
                "currency": p["currency"],
                "local_amount": p["amount"],
                "eur_price": eur_price,
                "saved_eur": saved_eur,
                "saved_pct": saved_pct
            })

        # Ordenar de más barato a más caro
        regional_list.sort(key=lambda x: x["eur_price"])
        cheapest = regional_list[0] if regional_list else None
        yearly_saving = round(cheapest["saved_eur"] * 12, 2) if cheapest else 0

        results.append({
            "id": sub["id"],
            "name": sub["name"],
            "category": sub["category"],
            "icon": sub["icon"],
            "color": sub["color"],
            "image": sub["image"],
            "spain_price": spain_price,
            "notes": sub["notes"],
            "cheapest_region": cheapest,
            "yearly_saving": yearly_saving,
            "regional_prices": regional_list
        })
    return results

def search_steam_games(query):
    cache_key = f"search_{query.lower()}"
    now = time.time()
    if cache_key in CACHE and now - CACHE[cache_key]["time"] < CACHE_TTL:
        return CACHE[cache_key]["data"]

    url = f"https://store.steampowered.com/api/storesearch/?term={urllib.parse.quote(query)}&l=spanish&cc=es"
    data = fetch_json(url)
    items = []
    if data and "items" in data:
        for item in data["items"]:
            price_info = item.get("price") or {}
            initial = price_info.get("initial", 0) / 100.0
            final = price_info.get("final", 0) / 100.0
            discount = 0
            if initial > 0:
                discount = int(round((1.0 - (final / initial)) * 100))

            items.append({
                "id": item.get("id"),
                "name": item.get("name"),
                "type": item.get("type", "game"),
                "image": item.get("tiny_image", f"https://cdn.akamai.steamstatic.com/steam/apps/{item.get('id')}/header.jpg"),
                "header_image": f"https://cdn.akamai.steamstatic.com/steam/apps/{item.get('id')}/header.jpg",
                "price_es": final,
                "original_price_es": initial,
                "discount": discount,
                "currency": "EUR"
            })

    CACHE[cache_key] = {"data": items, "time": now}
    return items

def get_region_price(appid, region):
    url = f"https://store.steampowered.com/api/appdetails?appids={appid}&cc={region['code']}&l=spanish"
    data = fetch_json(url)
    if not data or str(appid) not in data or not data[str(appid)].get("success"):
        return None

    app_data = data[str(appid)].get("data", {})
    price_ov = app_data.get("price_overview")
    is_free = app_data.get("is_free", False)

    if is_free:
        return {
            "region": region["name"],
            "code": region["code"],
            "flag": region["flag"],
            "currency": "EUR",
            "price_local": 0.0,
            "price_eur": 0.0,
            "original_eur": 0.0,
            "discount": 100,
            "is_free": True
        }

    if not price_ov:
        return None

    currency = price_ov.get("currency", region["currency"])
    price_local = price_ov.get("final", 0) / 100.0
    original_local = price_ov.get("initial", 0) / 100.0
    discount = price_ov.get("discount_percent", 0)

    rate = EXCHANGE_RATES.get(currency, 1.0)
    price_eur = round(price_local * rate, 2)
    original_eur = round(original_local * rate, 2)

    return {
        "region": region["name"],
        "code": region["code"],
        "flag": region["flag"],
        "currency": currency,
        "price_local": price_local,
        "price_eur": price_eur,
        "original_eur": original_eur,
        "discount": discount,
        "is_free": False
    }

def get_game_details(appid):
    cache_key = f"game_{appid}"
    now = time.time()
    if cache_key in CACHE and now - CACHE[cache_key]["time"] < CACHE_TTL:
        return CACHE[cache_key]["data"]

    base_url = f"https://store.steampowered.com/api/appdetails?appids={appid}&cc=es&l=spanish"
    base_data = fetch_json(base_url)

    if not base_data or str(appid) not in base_data or not base_data[str(appid)].get("success"):
        return {"error": "Juego no encontrado o no disponible"}

    game = base_data[str(appid)]["data"]
    regional_prices = []
    with ThreadPoolExecutor(max_workers=9) as executor:
        futures = [executor.submit(get_region_price, appid, reg) for reg in REGIONS]
        for f in futures:
            res = f.result()
            if res:
                regional_prices.append(res)

    regional_prices.sort(key=lambda x: x["price_eur"])
    price_es = 0.0
    for r in regional_prices:
        if r["code"] == "es":
            price_es = r["price_eur"]
            break

    for r in regional_prices:
        if price_es > 0 and r["price_eur"] < price_es:
            saved_eur = round(price_es - r["price_eur"], 2)
            saved_pct = int(round((saved_eur / price_es) * 100))
            r["saved_eur"] = saved_eur
            r["saved_pct"] = saved_pct
        else:
            r["saved_eur"] = 0.0
            r["saved_pct"] = 0

    cheapest = regional_prices[0] if regional_prices else None

    result = {
        "id": appid,
        "name": game.get("name"),
        "type": game.get("type"),
        "header_image": game.get("header_image"),
        "short_description": game.get("short_description"),
        "developers": game.get("developers", []),
        "publishers": game.get("publishers", []),
        "genres": [g["description"] for g in game.get("genres", [])],
        "metacritic": game.get("metacritic", {}).get("score"),
        "release_date": game.get("release_date", {}).get("date"),
        "screenshots": [s.get("path_thumbnail") for s in game.get("screenshots", [])[:4]],
        "price_es": price_es,
        "cheapest_region": cheapest,
        "regional_prices": regional_prices,
        "steam_url": f"https://store.steampowered.com/app/{appid}/"
    }

    CACHE[cache_key] = {"data": result, "time": now}
    return result

def get_featured_deals():
    cache_key = "featured_deals"
    now = time.time()
    if cache_key in CACHE and now - CACHE[cache_key]["time"] < 1800:
        return CACHE[cache_key]["data"]

    url = "https://store.steampowered.com/api/featuredcategories/?cc=es&l=spanish"
    data = fetch_json(url)
    deals = []
    if data and "specials" in data and "items" in data["specials"]:
        for item in data["specials"]["items"]:
            orig = item.get("original_price", 0) / 100.0
            final = item.get("final_price", 0) / 100.0
            disc = item.get("discount_percent", 0)
            deals.append({
                "id": item.get("id"),
                "name": item.get("name"),
                "image": item.get("header_image"),
                "original_price": orig,
                "final_price": final,
                "discount": disc,
                "currency": "EUR"
            })

    deals.sort(key=lambda x: x["discount"], reverse=True)
    CACHE[cache_key] = {"data": deals, "time": now}
    return deals

class MainRequestHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=STATIC_DIR, **kwargs)

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path
        params = urllib.parse.parse_qs(parsed.query)

        if path == "/api/search":
            query = params.get("q", [""])[0].strip()
            if not query:
                self.send_json([])
                return
            results = search_steam_games(query)
            self.send_json(results)

        elif path.startswith("/api/game/"):
            appid = path.split("/")[-1]
            if appid.isdigit():
                details = get_game_details(int(appid))
                self.send_json(details)
            else:
                self.send_json({"error": "ID no válido"}, 400)

        elif path == "/api/deals":
            deals = get_featured_deals()
            self.send_json(deals)

        elif path == "/api/subscriptions":
            subs = get_processed_subscriptions()
            self.send_json(subs)

        elif path == "/api/rates":
            self.send_json(EXCHANGE_RATES)

        else:
            super().do_GET()

    def send_json(self, data, status=200):
        body = json.dumps(data, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(body)

if __name__ == "__main__":
    os.makedirs(STATIC_DIR, exist_ok=True)
    print(f"==================================================")
    print(f"🎮 PixelGlobal Deals & Subscriptions Server v1.1.0")
    print(f"📡 Escuchando en: http://0.0.0.0:{PORT}")
    print(f"💾 Servidor Microserver Pixel 6a")
    print(f"==================================================")
    
    socketserver.TCPServer.allow_reuse_address = True
    with socketserver.ThreadingTCPServer(("0.0.0.0", PORT), MainRequestHandler) as httpd:
        httpd.serve_forever()
