#!/usr/bin/env bash
set -euo pipefail

SOURCE=/mnt/c/Users/stfub/Documents/Playground/raspberry-pi-arcade-recovery-2026-09-24/browsable/home/fritopie/frontend/roms
KIT=/mnt/c/Users/stfub/Documents/Playground/raspberry-pi-arcade-upgrade
ROOT=/mnt/retropie-root
DEVICE=/dev/sde
ES_REAL="${ROOT}/opt/retropie/configs/all/emulationstation"

[[ "$(blockdev --getsize64 "${DEVICE}")" == "256355860480" ]]
[[ "$(udevadm info --query=property --name="${DEVICE}" | sed -n 's/^ID_SERIAL_SHORT=//p')" == "121220160204" ]]
mkdir -p "${ROOT}"
mount "${DEVICE}2" "${ROOT}"
trap 'sync; umount "${ROOT}"' EXIT
[[ "$(findmnt -n -o SOURCE --target "${ROOT}")" == "${DEVICE}2" ]]
[[ -d "${ROOT}/home/pi/RetroPie/roms" ]]

cp -a "${SOURCE}/NES/." "${ROOT}/home/pi/RetroPie/roms/nes/"
cp -a "${SOURCE}/genh/." "${ROOT}/home/pi/RetroPie/roms/megadrive/"
cp -a "${SOURCE}/gg/." "${ROOT}/home/pi/RetroPie/roms/gamegear/"
cp -a "${SOURCE}/bios/." "${ROOT}/home/pi/RetroPie/BIOS/"

install -d -m 0755 \
  "${ROOT}/opt/dreadwire/void-run" \
  "${ROOT}/opt/dreadwire/tools" \
  "${ROOT}/home/pi/RetroPie/roms/homebrew" \
  "${ES_REAL}"
install -m 0755 "${KIT}/homebrew/void_run/build/void-run.arm64" \
  "${ROOT}/opt/dreadwire/void-run/void-run.arm64"
install -m 0755 "${KIT}/homebrew/void_run/cabinet-input-bridge.py" \
  "${ROOT}/opt/dreadwire/void-run/cabinet-input-bridge.py"
install -m 0755 "${KIT}/homebrew/void_run/root-xclient.sh" \
  "${ROOT}/opt/dreadwire/void-run/root-xclient.sh"
install -m 0755 "${KIT}/homebrew/void_run/xclient.sh" \
  "${ROOT}/opt/dreadwire/void-run/xclient.sh"
install -m 0755 "${KIT}/homebrew/launchers/Void Run.sh" \
  "${ROOT}/home/pi/RetroPie/roms/homebrew/Void Run.sh"
install -m 0755 "${KIT}/homebrew/tools/install-python-tools.sh" \
  "${ROOT}/opt/dreadwire/tools/install-python-tools.sh"
install -m 0755 "${KIT}/homebrew/tools/controller-test.py" \
  "${ROOT}/opt/dreadwire/tools/controller-test.py"
install -m 0755 "${KIT}/homebrew/launchers/Install Python Game Tools.sh" \
  "${ROOT}/home/pi/RetroPie/roms/homebrew/Install Python Game Tools.sh"
install -m 0755 "${KIT}/homebrew/launchers/Joystick and Button Test.sh" \
  "${ROOT}/home/pi/RetroPie/roms/homebrew/Joystick and Button Test.sh"

if [[ ! -f "${ES_REAL}/es_systems.cfg" ]]; then
  cp "${ROOT}/etc/emulationstation/es_systems.cfg" \
    "${ES_REAL}/es_systems.cfg"
fi
python3 "${KIT}/homebrew/add-homebrew-system.py" \
  "${ES_REAL}/es_systems.cfg"

# The image's account is UID/GID 1000 even though its home remains /home/pi.
chown -R 1000:1000 \
  "${ROOT}/home/pi/RetroPie" "${ES_REAL}"
sync

printf 'NES=%s MEGADRIVE=%s GAMEGEAR=%s BIOS=%s HOMEBREW=%s\n' \
  "$(find "${ROOT}/home/pi/RetroPie/roms/nes" -type f | wc -l)" \
  "$(find "${ROOT}/home/pi/RetroPie/roms/megadrive" -type f | wc -l)" \
  "$(find "${ROOT}/home/pi/RetroPie/roms/gamegear" -type f | wc -l)" \
  "$(find "${ROOT}/home/pi/RetroPie/BIOS" -type f | wc -l)" \
  "$(find "${ROOT}/home/pi/RetroPie/roms/homebrew" -type f | wc -l)"
df -h "${ROOT}"
