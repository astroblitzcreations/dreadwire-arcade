#!/usr/bin/env bash
set -euo pipefail

/usr/local/bin/dreadwire-musicctl.py gamepause >/dev/null 2>&1 || true
pkill -TERM -f '/home/pi/Music/dreadwire-arcade/' >/dev/null 2>&1 || true
pactl set-sink-mute @DEFAULT_SINK@ 0 >/dev/null 2>&1 || true
xrandr --output HDMI-1 --mode 1024x768 --rotate left --pos 0x0 2>/dev/null || xrandr -o left
xset s off
xset s noblank
xset -dpms

(while true; do
  /opt/dreadwire/void-run/cabinet-input-bridge.py >>/tmp/void-run-input.log 2>&1 || true
  sleep 0.25
done) &
bridge_pid=$!
cleanup() {
  kill "$bridge_pid" 2>/dev/null || true
  /usr/local/bin/dreadwire-musicctl.py gameresume >/dev/null 2>&1 || true
}
trap cleanup EXIT

/opt/dreadwire/void-run/void-run.arm64 \
  --fullscreen \
  --rendering-method gl_compatibility \
  --rendering-driver opengl3
