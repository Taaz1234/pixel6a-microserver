#!/system/bin/sh
chmod 666 /dev/binderfs/*
ln -sf /dev/binderfs/binder /dev/binder
ln -sf /dev/binderfs/hwbinder /dev/hwbinder
ln -sf /dev/binderfs/vndbinder /dev/vndbinder

echo "[+] Binder ready!"
am start -n com.android.chrome/com.google.android.apps.chrome.Main -d "http://localhost:8088/cam"
