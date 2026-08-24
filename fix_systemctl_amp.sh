#!/bin/bash
set -e

# Crear stub de systemctl para entornos chroot/proot
cat << 'EOF' > /usr/bin/systemctl
#!/bin/sh
exit 0
EOF
chmod +x /usr/bin/systemctl

# Configurar paquetes pendientes
dpkg --configure -a

echo "=========================================================="
echo "AMPINSTMGR STATUS & VERSION:"
ampinstmgr --version
echo "=========================================================="
