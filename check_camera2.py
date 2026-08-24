import shutil
import subprocess

print("--- Termux Binaries ---")
for cmd in ["termux-camera-info", "termux-camera-photo", "ffmpeg", "python3", "pkg"]:
    print(f"{cmd}: {shutil.which(cmd) or 'NOT FOUND'}")

p = subprocess.run(["python3", "-m", "pip", "list"], capture_output=True, text=True)
print("\n--- Python Packages ---")
print(p.stdout)
