#!/usr/bin/env python3
import hashlib, json, secrets, sys
from pathlib import Path

path = Path("/opt/dreadwire/companion/config.json")
password = sys.argv[1]
salt = secrets.token_bytes(16)
digest = hashlib.pbkdf2_hmac("sha256", password.encode(), salt, 240_000)
path.write_text(json.dumps({"username": "admin", "salt": salt.hex(),
                            "password_hash": digest.hex()}, indent=2) + "\n")
path.chmod(0o600)
