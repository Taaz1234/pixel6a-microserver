#!/system/bin/sh
# ==============================================================================
# Fase 4: Optimización, Persistencia Wi-Fi 24/7, Wakelock y Red
# Dispositivo: Google Pixel 6a (Tensor G1 / bluejay)
# ==============================================================================

set -e

STATIC_IP="${1:-}" # Ejemplo: 192.168.1.50/24
GATEWAY="${2:-}"   # Ejemplo: 192.168.1.1
DNS_SERVER="1.1.1.1"

echo "================================================================="
echo "   CONFIGURANDO DIRECTIVAS DE PERSISTENCIA 24/7 & WI-FI         "
echo "================================================================="

# 1. Adquisición de Wakelock Permanente a nivel de Kernel
echo "[+] Bloqueando suspensión del kernel (Permanent Wakelock)..."
echo "pixel6a_headless_server" > /sys/power/wake_lock 2>/dev/null || true
if [ -f /sys/power/autosleep ]; then
    echo "off" > /sys/power/autosleep 2>/dev/null || true
fi

# 2. Desactivación de Doze Mode y Políticas de Ahorro de Android
echo "[+] Deshabilitando Android Doze Mode y Battery Saver..."
dumpsys deviceidle disable 2>/dev/null || true
settings put global low_power 0 2>/dev/null || true
settings put global low_power_trigger_level 0 2>/dev/null || true
settings put global wifi_sleep_policy 2 2>/dev/null || true  # 2 = NEVER SLEEP
settings put global wifi_stay_on 1 2>/dev/null || true
settings put global wifi_connected_mac_randomization_enabled 0 2>/dev/null || true

# 3. Desactivación del modo de ahorro 802.11 en wlan0 (Low Latency / No Sleep)
echo "[+] Desactivando 802.11 Power Save Mode en wlan0..."
if [ -x "$(which iw)" ]; then
    iw dev wlan0 set power_save off 2>/dev/null || true
fi

if [ -x "$(which wpa_cli)" ]; then
    wpa_cli -i wlan0 driver SET_POWER_MODE 0 2>/dev/null || true
fi

# 4. Configuración de IP Estática o Detección de IP Actual
echo "[+] Verificando configuración de red en interfaz wlan0..."
CURRENT_IP=$(ip -4 addr show wlan0 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n 1)

if [ -n "$STATIC_IP" ] && [ -n "$GATEWAY" ]; then
    echo "[+] Aplicando IP fija: $STATIC_IP con Gateway $GATEWAY..."
    ip addr flush dev wlan0 2>/dev/null || true
    ip addr add "$STATIC_IP" dev wlan0
    ip link set wlan0 up
    ip route add default via "$GATEWAY" dev wlan0 2>/dev/null || true
    setprop net.dns1 "$DNS_SERVER"
    echo "[OK] IP Estática configurada: $STATIC_IP"
else
    if [ -n "$CURRENT_IP" ]; then
        echo "[OK] IP actual detectada en wlan0: $CURRENT_IP"
    else
        echo "[WARN] No se detectó IP activa en wlan0. Asegúrate de estar conectado a una red Wi-Fi."
    fi
fi

# 5. Optimización Térmica para Carga 24/7 (Google Tensor G1)
echo "[+] Configurando gobernadores de CPU balanceados para microservidor..."
for GOV in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    if [ -f "$GOV" ]; then
        echo "schedutil" > "$GOV" 2>/dev/null || true
    fi
done

echo "================================================================="
echo "   PERSISTENCIA WI-FI Y ENERGÍA CONFIGURADA EXITOSAMENTE        "
echo "================================================================="
