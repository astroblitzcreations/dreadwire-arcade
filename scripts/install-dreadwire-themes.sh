#!/usr/bin/env bash
set -euo pipefail

SOURCE_ROOT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/theme}"
THEME_ROOT="${DREADWIRE_ES_THEME_ROOT:-/etc/emulationstation/themes}"
FONT_ROOT="/usr/share/fonts/truetype/dejavu"

themes=(
  dreadwire-neon-3d
  dreadwire-terminal
  dreadwire-midnight
  dreadwire-overdrive
)

for theme in "${themes[@]}"; do
  [[ -f "${SOURCE_ROOT}/${theme}/theme.xml" ]] || continue
  install -d -m 0755 "${THEME_ROOT}/${theme}/assets"
  cp -a "${SOURCE_ROOT}/${theme}/." "${THEME_ROOT}/${theme}/"
  install -m 0644 "${FONT_ROOT}/DejaVuSans.ttf" "${THEME_ROOT}/${theme}/assets/DejaVuSans.ttf"
  install -m 0644 "${FONT_ROOT}/DejaVuSans-Bold.ttf" "${THEME_ROOT}/${theme}/assets/DejaVuSans-Bold.ttf"
  find "${THEME_ROOT}/${theme}" -type d -exec chmod 0755 {} +
  find "${THEME_ROOT}/${theme}" -type f -exec chmod 0644 {} +
done

echo "Dreadwire EmulationStation themes installed:"
printf '  %s\n' "${themes[@]}"
echo "Choose one with START > UI SETTINGS > THEME SET."
