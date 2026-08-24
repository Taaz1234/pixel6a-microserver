import os

dir_path = "/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs/root/.ampdata/instances/ADS01"

print("Listing files in ADS01:")
for f in os.listdir(dir_path):
    fp = os.path.join(dir_path, f)
    if os.path.isfile(fp):
        print(f"File: {f}, size: {os.path.getsize(fp)}")
        if f.endswith(".conf") or f.endswith(".kvp") or f.endswith(".json"):
            try:
                with open(fp, "r", encoding="utf-8", errors="ignore") as c:
                    print(f"--- Content of {f} ---")
                    print(c.read()[:500])
                    print("------------------------")
            except Exception as e:
                print(e)
