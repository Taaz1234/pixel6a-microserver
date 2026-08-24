import bcrypt

pw_hash = b"$2a$11$4h50ufHSw9btW.UNQtRGeuqCOO5gzFw.QpdlzOuwLq7RLwOzhbc9u"

candidates = ["Paco3421", "UGFjbzM0MjE=", "admin", "paco3421"]

for c in candidates:
    match = bcrypt.checkpw(c.encode(), pw_hash)
    print(f"Password '{c}': Match = {match}")
