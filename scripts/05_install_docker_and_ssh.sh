#!/system/bin/sh
# ==============================================================================
# Fase 3 - Paso 3: Instalación de Docker CE, OpenSSH y Configuración de Servicios
# ==============================================================================

set -e

ROOTFS="/data/local/ubuntu"

if [ ! -f "$ROOTFS/bin/bash" ]; then
    echo "[ERR] Ubuntu Rootfs no encontrado en $ROOTFS. Ejecuta primero 04_install_ubuntu_arm64.sh"
    exit 1
fi

echo "[+] Montando sistemas de archivos virtuales en el entorno chroot..."
mountpoint -q "$ROOTFS/dev" || mount --bind /dev "$ROOTFS/dev"
mountpoint -q "$ROOTFS/dev/pts" || mount --bind /dev/pts "$ROOTFS/dev/pts"
mountpoint -q "$ROOTFS/proc" || mount --bind /proc "$ROOTFS/proc"
mountpoint -q "$ROOTFS/sys" || mount --bind /sys "$ROOTFS/sys"
mountpoint -q "$ROOTFS/sys/fs/cgroup" || mount --bind /sys/fs/cgroup "$ROOTFS/sys/fs/cgroup"

echo "[+] Creando script interno de aprovisionamiento en Ubuntu..."
cat << 'CHROOT_SCRIPT' > "$ROOTFS/tmp/provision_internal.sh"
#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

echo "=========================================================="
echo "   ACTUALIZANDO PAQUETES E INSTALANDO DOCKER + OPENSSH    "
echo "=========================================================="

apt-get update
apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    iptables \
    iproute2 \
    net-tools \
    openssh-server \
    docker.io \
    docker-compose \
    htop \
    nano \
    sudo \
    tzdata

# Configurar zona horaria UTC / Local
ln -fs /usr/share/zoneinfo/UTC /etc/localtime
dpkg-reconfigure --frontend noninteractive tzdata 2>/dev/null || true

# Configuración de OpenSSH Server
echo "[+] Configurando OpenSSH Server..."
mkdir -p /var/run/sshd
ssh-keygen -A 2>/dev/null || true

# Permitir acceso Root y configurar puerto
sed -i 's/#Port 22/Port 22/' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Establecer contraseña por defecto para root (usuario: root / pass: pixel6a)
echo "root:pixel6a" | chpasswd
echo "[!] Contraseña de root establecida temporalmente a 'pixel6a'. Cámbiala con 'passwd' tras el primer login."

# Configuración del Docker Daemon (/etc/docker/daemon.json)
echo "[+] Optimizando configuración de Docker para Android / ARM64..."
mkdir -p /etc/docker
cat << 'EOF_DOCKER' > /etc/docker/daemon.json
{
  "storage-driver": "overlay2",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "dns": ["1.1.1.1", "8.8.8.8"],
  "iptables": true,
  "live-restore": true
}
EOF_DOCKER

echo "[OK] Aprovisionamiento interno completado con éxito."
CHROOT_SCRIPT

chmod +x "$ROOTFS/tmp/provision_internal.sh"

echo "[+] Ejecutando aprovisionamiento dentro del chroot..."
chroot "$ROOTFS" /bin/bash /tmp/provision_internal.sh
rm -f "$ROOTFS/tmp/provision_internal.sh"

echo "[OK] Docker y OpenSSH instalados y listos para operar."
