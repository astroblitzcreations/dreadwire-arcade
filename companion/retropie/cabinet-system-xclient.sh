#!/usr/bin/env bash
set -euo pipefail

xrandr --output HDMI-1 --mode 1024x768 --rotate left --pos 0x0 2>/dev/null || xrandr -o left
browser=$(command -v chromium || command -v chromium-browser)

exec "$browser" \
  --kiosk \
  --app=http://127.0.0.1:8765/cabinet-system \
  --no-first-run \
  --disable-session-crashed-bubble \
  --disable-infobars \
  --disable-translate \
  --user-data-dir=/home/pi/.cache/dreadwire-system-browser
