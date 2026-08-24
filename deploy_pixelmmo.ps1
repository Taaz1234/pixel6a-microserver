Write-Host "=== SUBIENDO FUENTES DE PIXELMMO AL PIXEL 6A ===" -ForegroundColor Cyan

# 1. Pushing files
.\platform-tools\adb.exe push pixelmmo_source /data/local/tmp/pixelmmo_source
.\platform-tools\adb.exe push build_and_deploy_mmo.sh /data/local/tmp/build_and_deploy_mmo.sh

# 2. Moving into Ubuntu chroot /tmp/
$sh1 = 'rm -rf /data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs/tmp/pixelmmo_source; cp -r /data/local/tmp/pixelmmo_source /data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs/tmp/; cp /data/local/tmp/build_and_deploy_mmo.sh /data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs/tmp/build_and_deploy_mmo.sh; chmod 755 /data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs/tmp/build_and_deploy_mmo.sh; rm -rf /data/local/tmp/pixelmmo_source /data/local/tmp/build_and_deploy_mmo.sh'
.\platform-tools\adb.exe shell "su -c '$sh1'"

# 3. Executing build inside Ubuntu chroot
Write-Host "=== EJECUTANDO COMPILACIÓN Y DESPLIEGUE EN PIXEL 6A ===" -ForegroundColor Green
$sh2 = 'chroot /data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs /bin/bash /tmp/build_and_deploy_mmo.sh'
.\platform-tools\adb.exe shell "su -c '$sh2'"

Start-Sleep -Seconds 8
Write-Host "=== LOG DEL SERVIDOR MINECRAFT ===" -ForegroundColor Cyan
$sh3 = 'tail -n 35 /data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs/root/.ampdata/instances/Minecraft01/Minecraft/server.log'
.\platform-tools\adb.exe shell "su -c '$sh3'"
