#!/system/bin/sh
export PATH=/data/data/com.termux/files/usr/bin:$PATH
export LD_LIBRARY_PATH=/data/data/com.termux/files/usr/lib:$LD_LIBRARY_PATH

echo "[+] Instalando termux-api y herramientas en Termux..."
pkg install -y termux-api 2>&1

echo "[+] Probando termux-camera-info..."
termux-camera-info 2>&1
