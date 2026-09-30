#!/usr/bin/env bash
set -euo pipefail

DEVICE=/dev/sde
ROOT=/mnt/retropie-root
KIT=/mnt/c/Users/stfub/Documents/Playground/raspberry-pi-arcade-upgrade
ES_DIR="${ROOT}/opt/retropie/configs/all/emulationstation"

[[ "$(blockdev --getsize64 "${DEVICE}")" == "256355860480" ]]
[[ "$(udevadm info --query=property --name="${DEVICE}" | sed -n 's/^ID_SERIAL_SHORT=//p')" == "121220160204" ]]
mount "${DEVICE}2" "${ROOT}"
trap 'sync; umount "${ROOT}"' EXIT

install -d -m 0755 "${ES_DIR}/themes/art-book-next"
cp -a "${KIT}/downloads/art-book-next-retropie/." \
  "${ES_DIR}/themes/art-book-next/"
rm -rf "${ES_DIR}/themes/art-book-next/.git"
install -m 0644 "${KIT}/card-files/es_settings.cfg" \
  "${ES_DIR}/es_settings.cfg"
chown -R 1000:1000 "${ES_DIR}"

du -sh "${ES_DIR}/themes/art-book-next"
grep -E '<aspectRatio>|<gameListStyle>' \
  "${ES_DIR}/themes/art-book-next/theme.xml"
