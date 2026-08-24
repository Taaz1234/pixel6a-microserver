#!/bin/sh
if [ -d "/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/ubuntu" ]; then
    echo "Ubuntu proot exists"
    chroot /data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/ubuntu /bin/bash -c "apt-get update -y && apt-get install -y python3-bcrypt apache2-utils && python3 -c \"import bcrypt; print('BCRYPT_RESULT:', bcrypt.hashpw(b'Paco3421', bcrypt.gensalt(10)).decode('utf-8'))\""
else
    echo "No ubuntu proot"
fi
