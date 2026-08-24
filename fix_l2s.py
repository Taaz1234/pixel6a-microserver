import os
import shutil

ROOTFS = "/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"
l2s_dir = os.path.join(ROOTFS, ".l2s")

print("Checking .l2s...")
if os.path.exists(l2s_dir):
    print(".l2s files:", os.listdir(l2s_dir))

fixed_count = 0
for root, dirs, files in os.walk(ROOTFS):
    # skip virtual mounts
    if any(k in root for k in ["/proc", "/sys", "/dev"]):
        continue
    for f in files:
        full_p = os.path.join(root, f)
        try:
            if os.path.islink(full_p):
                target = os.readlink(full_p)
                if target.startswith(ROOTFS):
                    if os.path.exists(target):
                        os.unlink(full_p)
                        shutil.copy2(target, full_p)
                        os.chmod(full_p, 0o755)
                        fixed_count += 1
                        print(f"Fixed: {full_p} -> real file")
        except Exception as e:
            pass

print(f"Total fixed: {fixed_count} .l2s symlinks converted to real binaries!")
