#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
set -e

MC_DIR="/root/.ampdata/instances/Minecraft01/Minecraft"
BUILD_DIR="/tmp/pixelmmo_build"

echo "=== 1. DESCARGANDO Y DESEMPAQUETANDO PURPUR 1.21.4 ==="
mkdir -p $MC_DIR/plugins $BUILD_DIR/src $BUILD_DIR/bin $BUILD_DIR/res

if [ ! -f $MC_DIR/purpur-1.21.4.jar ]; then
    echo "[+] Descargando Purpur 1.21.4..."
    curl -L -o $MC_DIR/purpur-1.21.4.jar "https://api.purpurmc.org/v2/purpur/1.21.4/latest/download"
fi

cd $MC_DIR
# Desempaquetar Purpur
echo "[+] Extrayendo librerías de Purpur..."
java -jar purpur-1.21.4.jar --help >/dev/null 2>&1 || true

# Construir classpath con todas las librerías extraídas
CP=$(find $MC_DIR/bundler $MC_DIR/versions $MC_DIR/libraries $MC_DIR/.paper-remapped -name "*.jar" 2>/dev/null | tr '\n' ':')
echo "[+] Classpath generado con $(find $MC_DIR/bundler $MC_DIR/versions $MC_DIR/libraries -name '*.jar' 2>/dev/null | wc -l) librerías."

echo "=== 2. COMPILANDO PLUGIN PIXELMMO ==="
rm -rf $BUILD_DIR/src/* $BUILD_DIR/bin/* $BUILD_DIR/res/*
cp -r /tmp/pixelmmo_source/src/main/java/* $BUILD_DIR/src/
cp -r /tmp/pixelmmo_source/src/main/resources/* $BUILD_DIR/res/

find $BUILD_DIR/src -name "*.java" > $BUILD_DIR/sources.txt

javac -cp "$CP" -d $BUILD_DIR/bin @$BUILD_DIR/sources.txt

echo "=== 3. EMPAQUETANDO PIXELMMO.JAR ==="
cd $BUILD_DIR/bin
jar -cf $MC_DIR/plugins/PixelMMO.jar .
cd $BUILD_DIR/res
jar -uf $MC_DIR/plugins/PixelMMO.jar plugin.yml

chmod 755 $MC_DIR/plugins/PixelMMO.jar
echo "[+] PixelMMO.jar compilado y empaquetado con éxito en plugins/PixelMMO.jar!"

echo "=== 4. INICIANDO MOTOR PURPUR 1.21.4 ==="
cp $MC_DIR/purpur-1.21.4.jar $MC_DIR/minecraft_server.jar
pkill -f "minecraft_server.jar" 2>/dev/null || true
pkill -f "java.*Minecraft" 2>/dev/null || true
sleep 2

cd $MC_DIR
nohup java -Xms1500M -Xmx2500M -XX:+UseG1GC -jar minecraft_server.jar nogui > $MC_DIR/server.log 2>&1 &

echo "=== SERVIDOR DE MINECRAFT MMORPG INICIADO ==="
