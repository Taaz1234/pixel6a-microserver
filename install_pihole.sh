#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
# Script de Instalación Automatizada de Pi-hole en Ubuntu ARM64 (Pixel 6a)
# ==============================================================================

LOG="/sdcard/pihole_install.log"
exec > "$LOG" 2>&1

echo "================================================================="
echo "   INICIANDO INSTALACIÓN AUTOMATIZADA DE PI-HOLE ARM64           "
echo "================================================================="

# 1. Asegurar que Ubuntu 24.04 está instalado en proot-distro
if ! proot-distro list | grep -q "ubuntu (installed)"; then
    echo "[+] Instalando Ubuntu 24.04 LTS..."
    proot-distro install ubuntu
fi

# 2. Script de aprovisionamiento interno de Pi-hole dentro de Ubuntu
cat << 'UBUNTU_PIHOLE' > /data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/ubuntu/tmp/setup_pihole.sh
#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

echo "[+] Actualizando repositorios de Ubuntu..."
apt-get update -y
apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    git \
    sudo \
    cron \
    lighttpd \
    php-cgi \
    php-sqlite3 \
    sqlite3 \
    dnsutils \
    iproute2 \
    net-tools \
    nano

# Crear directorio de configuración desatendida de Pi-hole
mkdir -p /etc/pihole
cat << 'EOF' > /etc/pihole/setupVars.conf
PIHOLE_INTERFACE=wlan0
IPV4_ADDRESS=192.168.1.137/24
PIHOLE_DNS_1=1.1.1.1
PIHOLE_DNS_2=8.8.8.8
QUERY_LOGGING=true
INSTALL_WEB_SERVER=true
INSTALL_WEB_INTERFACE=true
LIGHTTPD_ENABLED=true
BLOCKING_ENABLED=true
EOF

echo "[+] Descargando e instalando Pi-hole de forma desatendida..."
curl -sSL https://install.pi-hole.net | bash --unattended || true

echo "[+] Configurando contraseña del panel web a 'pixel6a'..."
pihole -a -p pixel6a || true

echo "[+] Iniciando servicios de Pi-hole..."
pihole-FTL 2>/dev/null || true
service lighttpd restart 2>/dev/null || true

echo "[OK] Pi-hole instalado y activo en http://192.168.1.137/admin"
UBUNTU_PIHOLE

chmod +x /data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/ubuntu/tmp/setup_pihole.sh 2>/dev/null || true

echo "[+] Ejecutando instalación dentro de Ubuntu..."
proot-distro login ubuntu -- bash -c "
if [ ! -f /tmp/setup_pihole.sh ]; then
    mkdir -p /tmp /etc/pihole
    cat << 'EOF_CONF' > /etc/pihole/setupVars.conf
PIHOLE_INTERFACE=wlan0
IPV4_ADDRESS=192.168.1.137/24
PIHOLE_DNS_1=1.1.1.1
PIHOLE_DNS_2=8.8.8.8
QUERY_LOGGING=true
INSTALL_WEB_SERVER=true
INSTALL_WEB_INTERFACE=true
LIGHTTPD_ENABLED=true
BLOCKING_ENABLED=true
EOF_CONF
    apt-get update -y && apt-get install -y curl ca-certificates git sudo lighttpd php-cgi php-sqlite3 sqlite3
    curl -sSL https://install.pi-hole.net | bash --unattended
    pihole -a -p pixel6a
    service lighttpd restart
    pihole-FTL
else
    /tmp/setup_pihole.sh
fi
"

echo "================================================================="
echo "   PI-HOLE INSTALADO CON ÉXITO                                   "
echo "   Acceso Web: http://192.168.1.137/admin                        "
echo "   Contraseña: pixel6a                                           "
echo "================================================================="
