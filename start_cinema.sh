#!/system/bin/sh
export LD_LIBRARY_PATH=/data/user/0/com.termux/files/usr/lib:$LD_LIBRARY_PATH
export PATH=/data/user/0/com.termux/files/usr/bin:$PATH
export HOME=/data/user/0/com.termux/files/home

cd /data/pixelserver/cinema_web
/data/user/0/com.termux/files/usr/bin/python3 cinema_server.py
