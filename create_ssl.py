import os

chroot_root = "/data/data/com.termux/files/usr/var/lib/proot-distro/containers/ubuntu/rootfs"

cmd = f"chroot {chroot_root} /usr/bin/env PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /usr/bin/openssl req -x509 -newkey rsa:2048 -keyout /etc/ssl/key.pem -out /etc/ssl/cert.pem -days 3650 -nodes -subj '/CN=192.168.1.135'"
res = os.system(cmd)
print("Command result:", res)

cert_src = os.path.join(chroot_root, "etc", "ssl", "cert.pem")
key_src = os.path.join(chroot_root, "etc", "ssl", "key.pem")

print("Cert exists in rootfs:", os.path.exists(cert_src))
print("Key exists in rootfs:", os.path.exists(key_src))

if os.path.exists(cert_src):
    with open(cert_src, "rb") as f:
        cert_data = f.read()
    with open("/data/local/tmp/cert.pem", "wb") as f:
        f.write(cert_data)
    with open(key_src, "rb") as f:
        key_data = f.read()
    with open("/data/local/tmp/key.pem", "wb") as f:
        f.write(key_data)
    os.chmod("/data/local/tmp/cert.pem", 0o644)
    os.chmod("/data/local/tmp/key.pem", 0o644)
    print("[+] cert.pem y key.pem creados exitosamente en /data/local/tmp/")
