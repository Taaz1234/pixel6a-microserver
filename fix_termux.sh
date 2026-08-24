#!/data/data/com.termux/files/usr/bin/bash
# Limpiar y configurar .bashrc
cat << 'EOF' > ~/.bashrc
# Autoinicio de servicios
if ! pgrep -f sshd > /dev/null; then
    sshd
fi
EOF

# Configurar contraseña de SSH a: pixel6a
(echo "pixel6a"; sleep 1; echo "pixel6a") | passwd

# Asegurar que sshd esta corriendo
sshd

echo "CONFIGURACION_COMPLETA_EXITOSA"
