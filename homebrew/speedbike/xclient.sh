#!/usr/bin/env bash
set -euo pipefail

# Pause the menu jukebox here as well as in the ROM launcher. This covers web,
# direct and recovery launches that bypass EmulationStation's wrapper.
/usr/local/bin/dreadwire-musicctl.py gamepause >/dev/null 2>&1 || true

xrandr --output HDMI-1 --mode 1024x768 --rotate left --pos 0x0 --brightness 1.12 2>/dev/null || xrandr -o left

# Keep the cabinet translator alive if an input device is briefly recreated.
(while true; do
  /opt/dreadwire/speedbike/cabinet-input-bridge.py >>/tmp/speedbike-input.log 2>&1 || true
  sleep 0.25
done) &
bridge_pid=$!
cleanup() {
  kill "$bridge_pid" 2>/dev/null || true
  /usr/local/bin/dreadwire-musicctl.py gameresume >/dev/null 2>&1 || true
}
trap cleanup EXIT

/opt/dreadwire/speedbike/speedbike.arm64 \
  --fullscreen \
  --rendering-method gl_compatibility \
  --rendering-driver opengl3
