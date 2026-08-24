import sys

try:
    import bcrypt
    salt = bcrypt.gensalt(rounds=10)
    hashed = bcrypt.hashpw(b"Paco3421", salt).decode('utf-8')
    print("BCRYPT_SUCCESS:", hashed)
except Exception as e:
    print("BCRYPT_ERROR:", e)

try:
    import crypt
    print("CRYPT_AVAILABLE")
except Exception as e:
    print("CRYPT_ERROR:", e)
