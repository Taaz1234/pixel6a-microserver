#!/bin/sh
echo "[+] Generando certificado SSL para HTTPS seguro..."
/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs/usr/bin/openssl req -x509 -newkey rsa:2048 -keyout /data/local/tmp/key.pem -out /data/local/tmp/cert.pem -days 3650 -nodes -subj "/CN=PixelVision" 2>/dev/null || true

if [ -f /data/local/tmp/cert.pem ]; then
    echo "[OK] Certificado SSL generado correctamente."
else
    echo "[!] Generando con openssl en chroot..."
    chroot /data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs /bin/bash -c "
    openssl req -x509 -newkey rsa:2048 -keyout /data/local/tmp/key.pem -out /data/local/tmp/cert.pem -days 3650 -nodes -subj '/CN=PixelVision'
    "
fi

ls -la /data/local/tmp/cert.pem /data/local/tmp/key.pem
