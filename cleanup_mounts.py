import os
import subprocess

print("[+] Cleaning up duplicate mounts...")
with open("/proc/mounts", "r") as f:
    lines = f.readlines()

for line in lines:
    if "binder" in line:
        parts = line.split()
        if len(parts) >= 2:
            mountpoint = parts[1]
            print("Unmounting:", mountpoint)
            os.system(f"/system/bin/umount -l '{mountpoint}' 2>/dev/null")

print("[+] Done unmounting.")
