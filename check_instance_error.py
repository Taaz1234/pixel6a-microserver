import os

ads_dir = "/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs/root/.ampdata"

print("Listing all files in .ampdata:")
for root, dirs, files in os.walk(ads_dir):
    for f in files:
        if f.endswith(".log") or "Exception" in f or f.endswith(".txt"):
            fp = os.path.join(root, f)
            print(f"--- Log file: {fp} (size {os.path.getsize(fp)}) ---")
            with open(fp, "r", encoding="utf-8", errors="ignore") as c:
                lines = c.readlines()
                for line in lines[-25:]:
                    print(line.strip())
