import subprocess
import os

print("--- Checking Termux Camera Tools ---")
for cmd in ["termux-camera-info", "termux-camera-photo", "ffmpeg", "python3"]:
    p = subprocess.run(["which", cmd], capture_output=True, text=True)
    print(f"{cmd}: {p.stdout.strip() or 'NOT FOUND'}")

print("\n--- Checking Python Packages in Termux ---")
p = subprocess.run(["python3", "-m", "pip", "list"], capture_output=True, text=True)
print(p.stdout)
