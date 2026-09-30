#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
install -d /opt/dreadwire/companion/web /usr/local/bin /etc/dreadwire
install -m 0755 "$ROOT/companion/server.py" /opt/dreadwire/companion/server.py
cp -a "$ROOT/companion/web/." /opt/dreadwire/companion/web/
install -m 0755 "$ROOT/scripts/dreadwire-splash-prepare.py" /usr/local/bin/dreadwire-splash-prepare.py
install -m 0755 "$ROOT/scripts/dreadwire-update.py" /usr/local/bin/dreadwire-update.py
install -d /etc/systemd/system/asplashscreen.service.d
install -m 0644 "$ROOT/systemd/asplashscreen-override.conf" /etc/systemd/system/asplashscreen.service.d/dreadwire.conf
install -m 0644 "$ROOT/systemd/dreadwire-update.service" /etc/systemd/system/dreadwire-update.service
printf '%s\n' '{"repository":"astroblitzcreations/dreadwire-arcade","channel":"stable"}' > /etc/dreadwire/update.json
systemctl daemon-reload
systemctl restart dreadwire-companion.service
