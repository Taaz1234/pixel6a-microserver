import os

def find_dirs():
    base = "/data/data/com.termux/files"
    matches = []
    for root, dirs, files in os.walk(base):
        if "ampinstmgr" in files or "installed-rootfs" in dirs:
            print("FOUND:", root)
find_dirs()
