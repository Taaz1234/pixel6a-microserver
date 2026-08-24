#!/system/bin/sh
# ==============================================================================
# Fase 3 - Paso 1: Acondicionamiento de Cgroups, Namespaces y Permisos del Kernel
# Dispositivo: Google Pixel 6a (Tensor G1 / bluejay - Linux Kernel 5.10 GKI)
# ==============================================================================

set -e

echo "[+] Configurando subsistemas del kernel y Cgroups para Docker Engine..."

# 1. Habilitar Reenvío de Paquetes IP (IP Forwarding para Docker bridge)
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1 2>/dev/null || true

# 2. Desactivar SELinux en modo Permisivo (Crucial para chroot y dockerd)
if [ "$(getenforce)" != "Permissive" ]; then
    echo "[+] Estableciendo SELinux en modo Permissive..."
    setenforce 0 || true
fi

# 3. Preparar jerarquía de Cgroups v1 y v2
# En Android, dockerd requiere que los controladores de cgroups estén montados en rutas estándar
CGROUP_ROOT="/sys/fs/cgroup"
mkdir -p "$CGROUP_ROOT"

if ! mountpoint -q "$CGROUP_ROOT"; then
    mount -t tmpfs -o uid=0,gid=0,mode=0755 cgroup "$CGROUP_ROOT"
fi

# Montar controladores individuales si no están activos
for CONTROLLER in cpu cpuacct memory devices freezer pids cpuset blkio net_cls; do
    DIR="$CGROUP_ROOT/$CONTROLLER"
    mkdir -p "$DIR"
    if ! mountpoint -q "$DIR"; then
        mount -t cgroup -o "$CONTROLLER" cgroup "$DIR" 2>/dev/null || true
    fi
done

# Compatibilidad con Cgroup v2 unificado si el kernel lo soporta
mkdir -p "$CGROUP_ROOT/unified"
if ! mountpoint -q "$CGROUP_ROOT/unified"; then
    mount -t cgroup2 cgroup2 "$CGROUP_ROOT/unified" 2>/dev/null || true
fi

# 4. Asegurar permisos en dispositivos esenciales (/dev)
chmod 666 /dev/null /dev/zero /dev/full /dev/random /dev/urandom /dev/tty /dev/ptmx 2>/dev/null || true
mkdir -p /dev/net
if [ ! -e /dev/net/tun ]; then
    mknod /dev/net/tun c 10 200 2>/dev/null || true
fi
chmod 666 /dev/net/tun 2>/dev/null || true

# 5. Crear directorio de montaje para Ubuntu Rootfs
ROOTFS_DIR="/data/local/ubuntu"
mkdir -p "$ROOTFS_DIR"
chmod 755 "$ROOTFS_DIR"

echo "[OK] Cgroups, SELinux y dispositivos de red configurados con éxito."
