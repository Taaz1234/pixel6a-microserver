#!/data/data/com.termux/files/usr/bin/bash

LOG="/sdcard/setup_result.log"
exec > "$LOG" 2>&1

echo "[+] Configurando repositorios de Termux..."
sed -i 's@^\(deb.*games\)$@# \1@' $PREFIX/etc/apt/sources.list.d/game.list 2>/dev/null || true
sed -i 's@^\(deb.*science\)$@# \1@' $PREFIX/etc/apt/sources.list.d/science.list 2>/dev/null || true
echo "deb https://mirror.leaseweb.com/termux/termux-main stable main" > $PREFIX/etc/apt/sources.list

echo "[+] Actualizando repositorios e instalando OpenSSH..."
apt-get update -y
apt-get install -y openssh proot-distro curl htop git

echo "[+] Configurando contrasena y claves SSH..."
echo -e "pixel6a\npixel6a" | passwd
ssh-keygen -A 2>/dev/null || true

echo "[+] Arrancando servidor OpenSSH en puerto 8022..."
sshd -p 8022

echo "[+] Adquiriendo Wakelock de Termux..."
termux-wake-lock 2>/dev/null || true

echo "[+] Configurando autoinicio en ~/.bashrc..."
cat << 'EOF' > ~/.bashrc
termux-wake-lock 2>/dev/null || true
if ! pgrep -x "sshd" > /dev/null; then
    sshd -p 8022
fi
echo "=========================================================="
echo "   PIXEL 6A MICROSERVER ARM64 (UBUNTU 24.04 LTS)          "
echo "   SSH Server activo en puerto :8022                      "
echo "   Para acceder a Ubuntu: proot-distro login ubuntu       "
echo "=========================================================="
EOF

echo "[+] Instalando Ubuntu 24.04 ARM64 Rootfs..."
proot-distro install ubuntu || true

echo "[OK] Microservidor configurado con exito!"
