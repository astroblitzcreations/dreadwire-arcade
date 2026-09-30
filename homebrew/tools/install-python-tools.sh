#!/usr/bin/env bash
set -euo pipefail

if [[ ${EUID} -ne 0 ]]; then
  exec sudo "$0" "$@"
fi

echo "Installing the cabinet's Python game runtime..."
apt-get update
apt-get install -y --no-install-recommends \
  python3 python3-venv python3-pip python3-pygame python3-evdev \
  python3-gpiozero python3-lgpio joystick

touch /var/lib/dreadwire-python-tools-installed
echo
echo "Python, pygame, evdev, GPIO, and joystick tools are ready."

