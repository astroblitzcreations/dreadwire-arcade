#!/usr/bin/env bash
set -euo pipefail

DEVICE=/dev/sde
EXPECTED_BYTES=256355860480
IMAGE=/mnt/c/Users/stfub/Documents/Playground/raspberry-pi-arcade-upgrade/downloads/retropie-bookworm-64-4.8.12-rpi4.img.xz

[[ -b "${DEVICE}" ]]
[[ "$(blockdev --getsize64 "${DEVICE}")" == "${EXPECTED_BYTES}" ]]
[[ "$(udevadm info --query=property --name="${DEVICE}" | sed -n 's/^ID_SERIAL_SHORT=//p')" == "121220160204" ]]
if findmnt -rn -S "${DEVICE}" -S "${DEVICE}1" -S "${DEVICE}2" >/dev/null; then
  echo "Refusing to flash: a target partition is mounted." >&2
  exit 1
fi

xzcat "${IMAGE}" | dd of="${DEVICE}" bs=4M iflag=fullblock \
  oflag=direct status=progress conv=fsync
sync
