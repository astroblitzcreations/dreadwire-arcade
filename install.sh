#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
install -d /opt/dreadwire/companion/web /usr/local/bin /etc/dreadwire
install -m 0755 "$ROOT/companion/server.py" /opt/dreadwire/companion/server.py
cp -a "$ROOT/companion/web/." /opt/dreadwire/companion/web/
install -m 0755 "$ROOT/scripts/dreadwire-splash-prepare.py" /usr/local/bin/dreadwire-splash-prepare.py
install -m 0755 "$ROOT/scripts/dreadwire-update.py" /usr/local/bin/dreadwire-update.py
install -m 0755 "$ROOT/scripts/dreadwire-party-overlay" /usr/local/bin/dreadwire-party-overlay
install -m 0755 "$ROOT/scripts/dreadwire-volume-overlay" /usr/local/bin/dreadwire-volume-overlay
install -m 0755 "$ROOT/scripts/cabinet-shortcuts.py" /usr/local/bin/cabinet-shortcuts.py
install -m 0755 "$ROOT/scripts/cabinet-controller-manager.py" /usr/local/bin/cabinet-controller-manager.py
install -d -o pi -g pi /home/pi/RetroPie/roms/companion
install -o pi -g pi -m 0755 "$ROOT/companion/retropie/06-arcade-mode.sh" /home/pi/RetroPie/roms/companion/06-arcade-mode.sh
install -d /var/lib/dreadwire-companion
test -s /var/lib/dreadwire-companion/mode.json || printf '%s\n' '{"mode":"classic"}' > /var/lib/dreadwire-companion/mode.json
install -d /etc/systemd/system/asplashscreen.service.d
install -m 0644 "$ROOT/systemd/asplashscreen-override.conf" /etc/systemd/system/asplashscreen.service.d/dreadwire.conf
install -m 0644 "$ROOT/systemd/dreadwire-update.service" /etc/systemd/system/dreadwire-update.service
printf '%s\n' '{"repository":"astroblitzcreations/dreadwire-arcade","channel":"stable"}' > /etc/dreadwire/update.json
systemctl daemon-reload
systemctl restart dreadwire-companion.service
