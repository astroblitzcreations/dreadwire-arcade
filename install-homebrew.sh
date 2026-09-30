#!/usr/bin/env bash
set -euo pipefail

if [[ ${EUID} -ne 0 ]]; then
  echo "Run with: sudo bash install-homebrew.sh" >&2
  exit 1
fi

ARCADE_USER="${SUDO_USER:-pi}"
ARCADE_HOME="$(getent passwd "${ARCADE_USER}" | cut -d: -f6)"
KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VOID_RUN_SOURCE="${KIT_DIR}/homebrew/void_run/build/void-run.arm64"
ROM_DIR="${ARCADE_HOME}/RetroPie/roms/homebrew"
APP_DIR="/opt/dreadwire/void-run"
ES_DIR="${ARCADE_HOME}/.emulationstation"
ES_CONFIG="${ES_DIR}/es_systems.cfg"

if [[ -z "${ARCADE_HOME}" || ! -f "${VOID_RUN_SOURCE}" ]]; then
  echo "Arcade user or Void Run ARM64 build was not found." >&2
  exit 1
fi

apt-get update
apt-get install -y --no-install-recommends \
  python3 python3-venv python3-pip python3-pygame python3-evdev \
  python3-gpiozero python3-lgpio joystick

install -d -m 0755 "${APP_DIR}" "${ROM_DIR}" "${ES_DIR}"
install -m 0755 "${VOID_RUN_SOURCE}" "${APP_DIR}/void-run.arm64"
install -m 0755 "${KIT_DIR}/homebrew/launchers/Void Run.sh" \
  "${ROM_DIR}/Void Run.sh"

if [[ ! -f "${ES_CONFIG}" ]]; then
  cp /etc/emulationstation/es_systems.cfg "${ES_CONFIG}"
fi

python3 "${KIT_DIR}/homebrew/add-homebrew-system.py" "${ES_CONFIG}"
chown -R "${ARCADE_USER}:${ARCADE_USER}" "${ROM_DIR}" "${ES_DIR}"

echo "Installed Dreadwire Crew / Homebrew and Void Run."
echo "Restart EmulationStation, then open the HOMEBREW system."

