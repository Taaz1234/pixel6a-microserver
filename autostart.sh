# Autostart para Pixel 6a Microserver
termux-wake-lock 2>/dev/null || true

# 1. Arrancar SSH Server
if ! pgrep -x "sshd" > /dev/null; then
    sshd -p 8022 2>/dev/null || true
fi

# 2. Arrancar AdGuard Home
if ! pgrep -x "AdGuardHome" > /dev/null; then
    export SSL_CERT_FILE=/data/local/tmp/cacert.pem
    nohup /data/local/tmp/AdGuardHome -w /data/local/tmp/adguard_work -c /data/local/tmp/adguard_work/AdGuardHome.yaml > /data/local/tmp/adguard.log 2>&1 &
fi

# 3. Arrancar FileBrowser
if ! pgrep -x "filebrowser" > /dev/null; then
    nohup /data/local/tmp/filebrowser -d /data/local/tmp/filebrowser_data/filebrowser.db -a 0.0.0.0 -p 8090 -r /sdcard/Media > /data/local/tmp/filebrowser.log 2>&1 &
fi

# 4. Arrancar CubeCoders AMP en puerto 8085
if ! pgrep -f "AMP_Linux_aarch64" > /dev/null; then
    sh /data/local/tmp/start_amp_clean.sh >/dev/null 2>&1 &
fi
