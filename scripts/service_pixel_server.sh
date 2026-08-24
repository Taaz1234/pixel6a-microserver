#!/system/bin/sh
# ==============================================================================
# Magisk Late-Start Boot Service: 00-pixel-server.sh
# Ubicación de destino en el dispositivo: /data/adb/service.d/00-pixel-server.sh
# Permisos requeridos: chmod 755 /data/adb/service.d/00-pixel-server.sh
# ==============================================================================

LOG_FILE="/data/local/pixel-server.log"
exec > "$LOG_FILE" 2>&1

echo "======================================================================"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Iniciando servicios de Pixel 6a Microserver..."
echo "======================================================================"

# 1. Esperar a que el sistema Android complete el arranque y la red
while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 2
done

# Espera de seguridad para estabilización de Wi-Fi
sleep 5

# 2. Wakelock permanente y desactivación de reposo
echo "pixel6a_srv_lock" > /sys/power/wake_lock 2>/dev/null || true
if [ -f /sys/power/autosleep ]; then
    echo "off" > /sys/power/autosleep 2>/dev/null || true
fi
dumpsys deviceidle disable 2>/dev/null || true
settings put global low_power 0 2>/dev/null || true
settings put global wifi_sleep_policy 2 2>/dev/null || true

# Desactivar 802.11 power saving
if [ -x "$(which iw)" ]; then
    iw dev wlan0 set power_save off 2>/dev/null || true
fi
if [ -x "$(which wpa_cli)" ]; then
    wpa_cli -i wlan0 driver SET_POWER_MODE 0 2>/dev/null || true
fi

# 3. Preparación de Kernel, SELinux y Cgroups
setenforce 0 2>/dev/null || true
sysctl -w net.ipv4.ip_forward=1 2>/dev/null || true

CGROUP_ROOT="/sys/fs/cgroup"
mkdir -p "$CGROUP_ROOT"
mountpoint -q "$CGROUP_ROOT" || mount -t tmpfs -o uid=0,gid=0,mode=0755 cgroup "$CGROUP_ROOT"

for CONTROLLER in cpu cpuacct memory devices freezer pids cpuset blkio net_cls; do
    DIR="$CGROUP_ROOT/$CONTROLLER"
    mkdir -p "$DIR"
    mountpoint -q "$DIR" || mount -t cgroup -o "$CONTROLLER" cgroup "$DIR" 2>/dev/null || true
done

mkdir -p "$CGROUP_ROOT/unified"
mountpoint -q "$CGROUP_ROOT/unified" || mount -t cgroup2 cgroup2 "$CGROUP_ROOT/unified" 2>/dev/null || true

# 4. Montaje de Ubuntu Rootfs
ROOTFS="/data/local/ubuntu"
if [ ! -f "$ROOTFS/bin/bash" ]; then
    echo "[ERR] Ubuntu Rootfs no encontrado en $ROOTFS. Cancelando arranque de servicios."
    exit 1
fi

mountpoint -q "$ROOTFS/dev" || mount --bind /dev "$ROOTFS/dev"
mountpoint -q "$ROOTFS/dev/pts" || mount --bind /dev/pts "$ROOTFS/dev/pts"
mountpoint -q "$ROOTFS/proc" || mount --bind /proc "$ROOTFS/proc"
mountpoint -q "$ROOTFS/sys" || mount --bind /sys "$ROOTFS/sys"
mountpoint -q "$ROOTFS/sys/fs/cgroup" || mount --bind /sys/fs/cgroup "$ROOTFS/sys/fs/cgroup"

# 5. Arrancar OpenSSH Server en segundo plano dentro de Ubuntu
echo "[+] Iniciando OpenSSH Server..."
chroot "$ROOTFS" /usr/sbin/sshd &

# 6. Arrancar Docker Daemon en segundo plano dentro de Ubuntu
echo "[+] Iniciando Docker Daemon (dockerd)..."
chroot "$ROOTFS" /usr/bin/dockerd > /data/local/dockerd.log 2>&1 &

CURRENT_IP=$(ip -4 addr show wlan0 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n 1)
echo "[$(date '+%Y-%m-%d %H:%M:%S')] [OK] Microserver online en IP: $CURRENT_IP | SSH: :22 | Docker: Activo"
