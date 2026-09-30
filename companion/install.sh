#!/usr/bin/env bash
set -euo pipefail

SOURCE=${1:-/tmp/dreadwire-companion}
TARGET=/opt/dreadwire/companion

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y python3-aiohttp python3-evdev python3-psutil
DEBIAN_FRONTEND=noninteractive apt-get install -y qrencode

mkdir -p "$TARGET"
cp -a "$SOURCE/server.py" "$SOURCE/web" "$TARGET/"
chown -R root:root "$TARGET"
chmod 0755 "$TARGET/server.py"
install -m 0644 "$SOURCE/Dreadwire Mobile Gamepad.cfg" "/opt/retropie/configs/all/retroarch/autoconfig/Dreadwire Mobile Gamepad.cfg"
python3 "$SOURCE/configure-emulationstation-input.py"
install -m 0755 "$SOURCE/retropie/update-companion-qr.sh" /usr/local/bin/update-companion-qr.sh
install -m 0755 "$SOURCE/retropie/dreadwire-mobile-player1.py" /usr/local/bin/dreadwire-mobile-player1.py
python3 "$SOURCE/retropie/setup-retropie-tab.py"
/usr/local/bin/update-companion-qr.sh
install -m 0755 "$SOURCE/setup-fallback-hotspot.sh" /usr/local/bin/setup-fallback-hotspot.sh
/usr/local/bin/setup-fallback-hotspot.sh

if [[ ! -f "$TARGET/config.json" ]]; then
    python3 - "$TARGET/config.json" <<'PY'
import hashlib, json, secrets, sys
from pathlib import Path
password = "DW-" + secrets.token_urlsafe(9)
salt = secrets.token_bytes(16)
digest = hashlib.pbkdf2_hmac("sha256", password.encode(), salt, 240_000)
Path(sys.argv[1]).write_text(json.dumps({
    "username": "admin", "salt": salt.hex(), "password_hash": digest.hex()
}, indent=2) + "\n")
print("COMPANION_USERNAME=admin")
print("COMPANION_PASSWORD=" + password)
PY
fi

install -m 0644 "$SOURCE/dreadwire-companion.service" /etc/systemd/system/dreadwire-companion.service
systemctl daemon-reload
systemctl enable dreadwire-companion.service
systemctl restart dreadwire-companion.service
sleep 3
systemctl --no-pager --full status dreadwire-companion.service | sed -n '1,18p'
