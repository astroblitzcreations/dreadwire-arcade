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
install -m 0644 "$ROOT/config-files/DragonRise Inc. Generic USB Joystick.cfg" "/opt/retropie/configs/all/retroarch/autoconfig/DragonRise Inc. Generic USB Joystick.cfg"
install -m 0644 "$ROOT/config-files/DragonRise Inc.   Generic   USB  Joystick  .cfg" "/opt/retropie/configs/all/retroarch/autoconfig/DragonRise Inc.   Generic   USB  Joystick  .cfg"
install -m 0755 "$ROOT/scripts/dreadwire-power-watchdog.py" /usr/local/bin/dreadwire-power-watchdog.py
install -m 0755 "$ROOT/scripts/generate-multiplayer-packs.py" /usr/local/bin/generate-multiplayer-packs.py
/usr/local/bin/generate-multiplayer-packs.py
install -m 0755 "$ROOT/scripts/generate-arcade-collections.py" /usr/local/bin/generate-arcade-collections.py
/usr/local/bin/generate-arcade-collections.py
install -d /opt/dreadwire/goldmaze /opt/dreadwire/speedbike /home/pi/RetroPie/roms/homebrew
install -m 0755 "$ROOT/homebrew/goldmaze/root-xclient.sh" /opt/dreadwire/goldmaze/root-xclient.sh
install -m 0755 "$ROOT/homebrew/speedbike/root-xclient.sh" /opt/dreadwire/speedbike/root-xclient.sh
install -m 0755 "$ROOT/homebrew/launchers/Trippy Gold Maze.sh" "/home/pi/RetroPie/roms/homebrew/Trippy Gold Maze.sh"
install -m 0755 "$ROOT/homebrew/launchers/Speedbike.sh" "/home/pi/RetroPie/roms/homebrew/Speedbike.sh"
install -d -o pi -g pi /home/pi/RetroPie/roms/companion
install -o pi -g pi -m 0755 "$ROOT/companion/retropie/06-arcade-mode.sh" /home/pi/RetroPie/roms/companion/06-arcade-mode.sh
install -o pi -g pi -m 0755 "$ROOT/companion/retropie/07-system-dashboard.sh" /home/pi/RetroPie/roms/companion/07-system-dashboard.sh
install -o pi -g pi -m 0755 "$ROOT/companion/retropie/08-mystery-game.sh" /home/pi/RetroPie/roms/companion/08-mystery-game.sh
chown -R pi:pi /opt/retropie/configs/all/emulationstation/collections /opt/dreadwire/collections
AUTOSTART=/opt/retropie/configs/all/autostart.sh
if ! grep -q 'generate-arcade-collections.py --shuffle-only' "$AUTOSTART"; then
  sed -i '1i/usr/local/bin/generate-arcade-collections.py --shuffle-only' "$AUTOSTART"
fi
install -m 0755 "$ROOT/companion/retropie/cabinet-system-root-xclient.sh" /opt/dreadwire/companion/cabinet-system-root-xclient.sh
install -m 0755 "$ROOT/companion/retropie/cabinet-system-xclient.sh" /opt/dreadwire/companion/cabinet-system-xclient.sh
install -d /var/lib/dreadwire-companion
test -s /var/lib/dreadwire-companion/mode.json || printf '%s\n' '{"mode":"classic"}' > /var/lib/dreadwire-companion/mode.json
install -d /etc/systemd/system/asplashscreen.service.d
install -m 0644 "$ROOT/systemd/asplashscreen-override.conf" /etc/systemd/system/asplashscreen.service.d/dreadwire.conf
install -m 0644 "$ROOT/systemd/dreadwire-update.service" /etc/systemd/system/dreadwire-update.service
install -m 0644 "$ROOT/systemd/dreadwire-power-watchdog.service" /etc/systemd/system/dreadwire-power-watchdog.service
printf '%s\n' '{"repository":"astroblitzcreations/dreadwire-arcade","channel":"stable"}' > /etc/dreadwire/update.json
systemctl daemon-reload
systemctl enable --now dreadwire-power-watchdog.service
systemctl restart dreadwire-companion.service
