#!/system/bin/sh
# ==============================================================================
# Fase 3 - Paso 2: Despliegue de Ubuntu Server 24.04 LTS Base ARM64 Rootfs
# ==============================================================================

set -e

ROOTFS="/data/local/ubuntu"
TARBALL_URL="https://cdimage.ubuntu.com/ubuntu-base/releases/24.04/release/ubuntu-base-24.04.1-base-arm64.tar.gz"
TARBALL_PATH="/data/local/ubuntu-base-arm64.tar.gz"

echo "================================================================="
echo "   DESPLIEGUE DE UBUNTU SERVER 24.04 LTS ARM64 (PIXEL 6a)        "
echo "================================================================="

mkdir -p "$ROOTFS"

if [ -f "$ROOTFS/bin/bash" ]; then
    echo "[!] Ubuntu Rootfs ya existe en $ROOTFS. Omitiendo descarga e instalación inicial."
else
    echo "[+] Descargando Ubuntu Base 24.04 LTS ARM64..."
    if [ -x "$(which curl)" ]; then
        curl -k -L -o "$TARBALL_PATH" "$TARBALL_URL"
    elif [ -x "$(which wget)" ]; then
        wget --no-check-certificate -O "$TARBALL_PATH" "$TARBALL_URL"
    else
        echo "[ERR] Ni curl ni wget encontrados en el host Android. Por favor, descarga el tarball previamente."
        exit 1
    fi

    echo "[+] Extrayendo Ubuntu Rootfs en $ROOTFS..."
    tar -xzpf "$TARBALL_PATH" -C "$ROOTFS"
    rm -f "$TARBALL_PATH"
    echo "[OK] Extracción completada."
fi

# Configuración de DNS
echo "[+] Configurando resolución DNS (/etc/resolv.conf)..."
cat << 'EOF' > "$ROOTFS/etc/resolv.conf"
nameserver 1.1.1.1
nameserver 8.8.8.8
nameserver 1.0.0.1
EOF

# Configuración de Hostname y Hosts
echo "pixel6a-server" > "$ROOTFS/etc/hostname"
cat << 'EOF' > "$ROOTFS/etc/hosts"
127.0.0.1   localhost pixel6a-server
::1         localhost ip6-localhost ip6-loopback
EOF

# Configuración de Repositorios Oficiales de Ubuntu Ports ARM64
cat << 'EOF' > "$ROOTFS/etc/apt/sources.list"
deb http://ports.ubuntu.com/ubuntu-ports/ noble main restricted universe multiverse
deb http://ports.ubuntu.com/ubuntu-ports/ noble-updates main restricted universe multiverse
deb http://ports.ubuntu.com/ubuntu-ports/ noble-security main restricted universe multiverse
deb http://ports.ubuntu.com/ubuntu-ports/ noble-backports main restricted universe multiverse
EOF

# Preparación de variables de entorno estándar
cat << 'EOF' > "$ROOTFS/etc/profile.d/server_env.sh"
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export TERM=xterm-256color
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
EOF

echo "[OK] Entorno base Ubuntu 24.04 ARM64 preparado."
