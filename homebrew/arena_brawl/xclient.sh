#!/usr/bin/env bash
set -euo pipefail

/usr/local/bin/dreadwire-musicctl.py gamepause >/dev/null 2>&1 || true
xrandr --output HDMI-1 --mode 1024x768 --rotate left --pos 0x0 --brightness 1.12 2>/dev/null || xrandr -o left

(while true; do
  /opt/dreadwire/arena-brawl/cabinet-input-bridge.py >>/tmp/arena-brawl-input.log 2>&1 || true
  sleep 0.25
done) &
bridge_pid=$!
cleanup() {
  kill "$bridge_pid" 2>/dev/null || true
  /usr/local/bin/dreadwire-musicctl.py gameresume >/dev/null 2>&1 || true
}
trap cleanup EXIT

/opt/dreadwire/arena-brawl/arena-brawl.arm64 \
  --fullscreen \
  --rendering-method gl_compatibility \
  --rendering-driver opengl3
