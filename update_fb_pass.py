import subprocess
import os

# 1. Stop filebrowser temporarily to unlock DB
os.system("pkill -9 filebrowser 2>/dev/null")

# 2. List and update filebrowser users
res = subprocess.run(["/data/local/tmp/filebrowser", "users", "ls", "-d", "/data/local/tmp/filebrowser_data/filebrowser.db"], capture_output=True, text=True)
print("Filebrowser users:", res.stdout, res.stderr)

# Update admin user password
res_up = subprocess.run(["/data/local/tmp/filebrowser", "users", "update", "admin", "-p", "Paco3421", "-d", "/data/local/tmp/filebrowser_data/filebrowser.db"], capture_output=True, text=True)
print("Filebrowser update admin:", res_up.stdout, res_up.stderr)

# 3. Restart filebrowser in background
os.system("nohup /data/local/tmp/filebrowser -d /data/local/tmp/filebrowser_data/filebrowser.db -a 0.0.0.0 -p 8090 -r /sdcard/Media > /data/local/tmp/filebrowser.log 2>&1 &")
print("Filebrowser restarted.")
