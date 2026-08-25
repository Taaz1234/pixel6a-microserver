#!/usr/bin/env python3
"""
PixelGlobal Deals & Subscriptions Server v1.2.0
Self-hosted Global Regional Price Comparator with Real-Time Daily Currency Auto-Updater.
"""

import http.server
import socketserver
import urllib.request
import urllib.parse
import json
import os
import time
import datetime
import threading
from concurrent.futures import ThreadPoolExecutor

PORT = 8098
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
STATIC_DIR = os.path.join(BASE_DIR, "static")
SUBS_FILE = os.path.join(BASE_DIR, "subscriptions.json")

CACHE = {}
CACHE_TTL = 3600  # 1 hora
LAST_UPDATED = datetime.datetime.now().strftime("%d/%m/%Y %H:%M")

# Tasas de cambio de divisas en vivo a EUR
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
    "PHP": 0.016,    # Filipinas
    "ZAR": 0.051     # Sudáfrica (Rand)
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
    """Actualiza tasas de cambio en vivo cada día."""
    global EXCHANGE_RATES, LAST_UPDATED
    try:
        data = fetch_json("https://open.er-api.com/v6/latest/EUR")
        if data and "rates" in data:
            rates = data["rates"]
            for curr in list(EXCHANGE_RATES.keys()):
                if curr in rates and rates[curr] > 0:
                    EXCHANGE_RATES[curr] = round(1.0 / rates[curr], 6)
            LAST_UPDATED = datetime.datetime.now().strftime("%d/%m/%Y %H:%M")
            print(f"[+] Tasas de divisas en vivo actualizadas con éxito ({LAST_UPDATED}).")
    except Exception as e:
        print(f"[!] Fallback a tasas base: {e}")

# Hilo en segundo plano para actualización diaria continua cada 6 horas
def background_daily_updater():
    while True:
        time.sleep(21600)  # Cada 6 horas
        print("[+] Ejecutando actualización periódica de tasas...")
        update_exchange_rates()

updater_thread = threading.Thread(target=background_daily_updater, daemon=True)
updater_thread.start()

# Primera actualización
update_exchange_rates()

def load_subscriptions_data():
    if os.path.exists(SUBS_FILE):
        try:
            with open(SUBS_FILE, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception as e:
            print(f"[!] Error leyendo {SUBS_FILE}: {e}")
    return []

def get_processed_subscriptions():
    raw_subs = load_subscriptions_data()
    results = []

    for sub in raw_subs:
        regional_list = []
        spain_price = sub.get("spain_price", 19.99)

        for p in sub.get("prices", []):
            rate = EXCHANGE_RATES.get(p.get("rate_key", "EUR"), 1.0)
            eur_price = round(p.get("amount", 0) * rate, 2)
            saved_eur = round(max(0, spain_price - eur_price), 2)
            saved_pct = int(round((saved_eur / spain_price) * 100)) if spain_price > 0 else 0

            regional_list.append({
                "region": p.get("region"),
                "flag": p.get("flag"),
                "currency": p.get("currency"),
                "local_amount": p.get("amount"),
                "eur_price": eur_price,
                "saved_eur": saved_eur,
                "saved_pct": saved_pct
            })

        # Ordenar de más barato a más caro
        regional_list.sort(key=lambda x: x["eur_price"])
        cheapest = regional_list[0] if regional_list else None
        yearly_saving = round(cheapest["saved_eur"] * 12, 2) if cheapest else 0

        results.append({
            "id": sub.get("id"),
            "name": sub.get("name"),
            "category": sub.get("category"),
            "icon": sub.get("icon"),
            "color": sub.get("color"),
            "image": sub.get("image"),
            "spain_price": spain_price,
            "notes": sub.get("notes"),
            "cheapest_region": cheapest,
            "yearly_saving": yearly_saving,
            "regional_prices": regional_list
        })

    return {
        "last_updated": LAST_UPDATED,
        "subscriptions": results
    }

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

            appid = item.get("id")
            tiny = item.get("tiny_image", "")
            header = f"https://shared.cloudflare.steamstatic.com/store_item_assets/steam/apps/{appid}/header.jpg"
            capsule = f"https://shared.cloudflare.steamstatic.com/store_item_assets/steam/apps/{appid}/capsule_616x353.jpg"

            items.append({
                "id": appid,
                "name": item.get("name"),
                "type": item.get("type", "game"),
                "image": tiny if tiny else header,
                "header_image": header,
                "capsule_image": capsule,
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
            appid = item.get("id")
            img = item.get("header_image") or item.get("large_capsule_image") or f"https://shared.cloudflare.steamstatic.com/store_item_assets/steam/apps/{appid}/header.jpg"
            deals.append({
                "id": appid,
                "name": item.get("name"),
                "image": img,
                "header_image": img,
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
            subs_data = get_processed_subscriptions()
            self.send_json(subs_data)

        elif path == "/api/subscriptions/refresh":
            update_exchange_rates()
            subs_data = get_processed_subscriptions()
            self.send_json(subs_data)

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
    print(f"🎮 PixelGlobal Deals & Subscriptions Server v1.2.0")
    print(f"📡 Escuchando en: http://0.0.0.0:{PORT}")
    print(f"🔄 Auto-Actualizador Diario en Tiempo Real Activo")
    print(f"💾 Servidor Microserver Pixel 6a")
    print(f"==================================================")
    
    socketserver.TCPServer.allow_reuse_address = True
    with socketserver.ThreadingTCPServer(("0.0.0.0", PORT), MainRequestHandler) as httpd:
        httpd.serve_forever()
