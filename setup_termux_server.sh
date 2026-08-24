#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
# Setup Automatizado de Microservidor Linux ARM64 en Pixel 6a
# ==============================================================================

set -e

echo "================================================================="
echo "   CONFIGURANDO MICROSERVIDOR ARM64 + OPENSSH + UBUNTU 24.04    "
echo "================================================================="

# 1. Adquirir Wakelock de Termux
termux-wake-lock 2>/dev/null || true

# 2. Actualizar repositorios e instalar paquetes base
pkg update -y -o Dpkg::Options::="--force-confold"
pkg install -y openssh proot-distro curl git htop nano net-tools

# 3. Configurar contraseña de SSH (usuario por defecto en Termux)
echo -e "pixel6a\npixel6a" | passwd

# 4. Iniciar OpenSSH Server en el puerto 8022
sshd -p 8022 2>/dev/null || true

# 5. Instalar Ubuntu 24.04 LTS (Noble) ARM64 Rootfs
if ! proot-distro list | grep -q "ubuntu (installed)"; then
    echo "[+] Descargando y desplegando Ubuntu 24.04 LTS ARM64..."
    proot-distro install ubuntu
fi

# 6. Configurar autoinicio de SSH y Wakelock en ~/.bashrc
cat << 'EOF' > ~/.bashrc
termux-wake-lock 2>/dev/null || true
if ! pgrep -x "sshd" > /dev/null; then
    sshd -p 8022
fi
echo "=========================================================="
echo "   GOOGLE PIXEL 6A MICROSERVER ARM64 (Ubuntu 24.04)       "
echo "   SSH Server activo en puerto :8022                      "
echo "   Para entrar a Ubuntu: proot-distro login ubuntu        "
echo "=========================================================="
EOF

echo "================================================================="
echo "   MICROSERVIDOR LISTO Y ACCESIBLE POR SSH EN PUERTO 8022       "
echo "================================================================="
