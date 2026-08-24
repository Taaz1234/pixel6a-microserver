#!/bin/bash
set -e

rm -f /etc/apt/sources.list.d/*cubecoders* /etc/apt/sources.list.d/*c7rs*

install -d -m 0755 /usr/share/keyrings
wget -O /usr/share/keyrings/cdn-repo.c7rs.com.gpg https://cdn-repo.c7rs.com/archive.key

cat <<EOF > /etc/apt/sources.list.d/cdn-repo.c7rs.com.sources
Types: deb
URIs: https://cdn-repo.c7rs.com/aarch64/
Suites: debian/
Architectures: arm64
Signed-By: /usr/share/keyrings/cdn-repo.c7rs.com.gpg
EOF

apt-get update -y
apt-get install -y ampinstmgr

echo "=========================================================="
echo "AMPINSTMGR VERSION:"
ampinstmgr --version
echo "=========================================================="
