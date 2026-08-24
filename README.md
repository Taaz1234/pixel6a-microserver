# Google Pixel 6a (bluejay) - 24/7 Headless ARM64 Linux & Docker Microserver

Guía técnica integral y suite de scripts para transformar un **Google Pixel 6a (Tensor G1 / bluejay / 6GB RAM / 128GB UFS)** en un microservidor Linux ARM64 de producción operando exclusivamente por Wi-Fi 24/7 con Docker CE nativo, OpenSSH y persistencia energética total.

---

## 📁 Estructura del Proyecto

```text
pixel6a-microserver/
├── scripts/
│   ├── 01_fastboot_flash.ps1          # Detección fastboot y flasheo limpio de fábrica (Windows)
│   ├── 02_root_patch.ps1              # Flasheo de Magisk Patched boot.img (Windows)
│   ├── 03_setup_cgroups_and_storage.sh# Cgroups, namespaces y permisos de kernel (Android)
│   ├── 04_install_ubuntu_arm64.sh     # Despliegue de Ubuntu 24.04 LTS ARM64 rootfs (Android)
│   ├── 05_install_docker_and_ssh.sh   # Aprovisionamiento de Docker CE & OpenSSH
│   ├── 06_wifi_persistence_doze.sh    # Wakelock permanente, 802.11 Power Save Off y Doze off
│   └── service_pixel_server.sh        # Script Magisk service.d para autoinicio total al boot
├── docker/
│   ├── docker-compose.yml             # Stack: Portainer, Dozzle, Nginx Dashboard, Uptime Kuma
│   ├── config/
│   │   └── daemon.json                # Configuración optimizada de dockerd para UFS/Android
│   └── html/
│       └── index.html                 # Dashboard web moderno con métricas y enlaces
└── README.md                          # Esta guía de operaciones
```

---

## 🚀 Guía de Despliegue Paso a Paso

### FASE 1: Restauración Limpia y Fastboot (Desde Windows PC)

1. Conecta el Pixel 6a por USB en modo **Fastboot** (apagar el teléfono y mantener `[Bajar Volumen] + [Encendido]`).
2. Abre PowerShell en la carpeta `scripts/` y ejecuta el script de detección y flasheo:
   ```powershell
   .\01_fastboot_flash.ps1
   ```
3. Si el bootloader está bloqueado, el script ejecutará `fastboot flashing unlock` (confirma en pantalla con las teclas de volumen).
4. Descarga la imagen oficial de fábrica de Google para `bluejay`:
   - [Google Factory Images for bluejay](https://developers.google.com/android/images#bluejay)
5. Extrae el ZIP y ejecuta `flash-all.bat` (o pásale la ruta al script: `.\01_fastboot_flash.ps1 -FactoryZipPath "C:\ruta\bluejay-factory.zip"`).

---

### FASE 2: Acceso Root (Magisk)

1. Extrae el archivo `boot.img` del interior de la imagen de fábrica (`image-bluejay-*.zip`).
2. Copia `boot.img` al almacenamiento del teléfono.
3. Instala [Magisk APK](https://github.com/topjohnwu/Magisk/releases) en el teléfono, ábrelo y pulsa:
   `Instalar` -> `Seleccionar y parchar un archivo` -> selecciona `boot.img`.
4. Transfiere el archivo generado (`magisk_patched-*.img`) a tu PC.
5. Reinicia el Pixel 6a en modo Fastboot y ejecuta:
   ```powershell
   .\02_root_patch.ps1 -PatchedBootImgPath "C:\ruta\magisk_patched.img"
   ```
6. El teléfono se reiniciará con permisos Root completos en el kernel 5.10 GKI.

---

### FASE 3: Despliegue de Ubuntu ARM64, Docker y OpenSSH

1. Conéctate a la misma red Wi-Fi en el Pixel 6a y activa la **Depuración por USB** en `Ajustes -> Opciones de Desarrollador`.
2. Envía los scripts al dispositivo mediante ADB:
   ```bash
   adb push scripts/03_setup_cgroups_and_storage.sh /data/local/tmp/
   adb push scripts/04_install_ubuntu_arm64.sh /data/local/tmp/
   adb push scripts/05_install_docker_and_ssh.sh /data/local/tmp/
   adb push scripts/06_wifi_persistence_doze.sh /data/local/tmp/
   adb push scripts/service_pixel_server.sh /data/local/tmp/
   ```
3. Accede a la shell con permisos de Superusuario:
   ```bash
   adb shell
   su
   cd /data/local/tmp
   chmod +x *.sh
   ```
4. Ejecuta los módulos en orden:
   ```bash
   # 1. Configurar subsistemas del kernel y cgroups
   ./03_setup_cgroups_and_storage.sh

   # 2. Descargar y desplegar Ubuntu Server 24.04 LTS ARM64
   ./04_install_ubuntu_arm64.sh

   # 3. Instalar Docker CE nativo, OpenSSH y dependencias
   ./05_install_docker_and_ssh.sh
   ```

---

### FASE 4: Persistencia 24/7 y Autoinicio Headless (Sin Cable)

1. Aplica las directivas de persistencia energética y Wi-Fi:
   ```bash
   # Opcional: Especifica IP estática y Gateway, o déjalo vacío para DHCP
   ./06_wifi_persistence_doze.sh 192.168.1.50/24 192.168.1.1
   ```
2. Instala el servicio de arranque automático en Magisk (`late_start service`):
   ```bash
   mkdir -p /data/adb/service.d
   cp /data/local/tmp/service_pixel_server.sh /data/adb/service.d/00-pixel-server.sh
   chmod 755 /data/adb/service.d/00-pixel-server.sh
   ```
3. **¡Listo!** Ya puedes desconectar el cable USB de datos y conectar el Pixel 6a a un cargador de corriente continua.
4. Reinicia el teléfono (`reboot`). En menos de 20 segundos tras el boot, el microservidor estará activo de forma autónoma.

---

## 🌐 Conexión y Uso Remoto

### Acceso SSH:
```bash
ssh root@<IP_DEL_PIXEL> -p 22
# Contraseña inicial por defecto: pixel6a
# (Se recomienda cambiarla con 'passwd' o añadir tu clave a ~/.ssh/authorized_keys)
```

### Entrar al Entorno Ubuntu manualmente (vía ADB o local):
```bash
su
chroot /data/local/ubuntu /bin/bash
```

### Desplegar el Stack Docker Microservicios:
Una vez dentro de la sesión SSH:
```bash
cd /root
git clone <tu-repo> o copia el archivo docker-compose.yml
docker-compose -f /data/docker-compose.yml up -d
```

### Servicios expuestos en la red local:
- **Dashboard Web**: `http://<IP_DEL_PIXEL>:80`
- **Portainer CE**: `http://<IP_DEL_PIXEL>:9000`
- **Dozzle Logs**: `http://<IP_DEL_PIXEL>:8888`
- **Uptime Kuma**: `http://<IP_DEL_PIXEL>:3001`
- **OpenSSH**: `port 22`

---

## ⚡ Buenas Prácticas para Operación 24/7

1. **Cuidado de la Batería (Battery Bypass / Limite de Carga)**:
   - Para evitar degradación por tener el cargador conectado permanentemente, instala el módulo Magisk **ACC (Advanced Charging Controller)** o limita la carga al 70-80% ejecutando:
     ```bash
     echo 80 > /sys/class/power_supply/battery/charge_control_limit_max 2>/dev/null || true
     ```
2. **Refrigeración Pasiva / Activa**:
   - El chip Google Tensor G1 es potente pero genera calor en cargas sostenidas. Coloca el teléfono en un soporte vertical abierto o con un pequeño disipador/ventilador USB de 5V si ejecutas compilaciones pesadas.
3. **Logs de Diagnóstico**:
   - Registro de arranque: `/data/local/pixel-server.log`
   - Registro de Docker: `/data/local/dockerd.log`
