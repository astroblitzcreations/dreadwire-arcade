#!/usr/bin/env bash
set -euo pipefail

/usr/local/bin/dreadwire-musicctl.py gamepause >/dev/null 2>&1 || true
# Remove only orphaned cabinet-jukebox players; never touch game audio or an
# unrelated user media player.
pkill -TERM -f '/home/pi/Music/dreadwire-arcade/' >/dev/null 2>&1 || true
# Menu music uses direct ALSA while Godot is routed through PipeWire. A prior
# system mute must not leave the game stream silent after the jukebox exits.
pactl set-sink-mute @DEFAULT_SINK@ 0 >/dev/null 2>&1 || true
xrandr --output HDMI-1 --mode 1024x768 --rotate left --pos 0x0 --brightness 1.12 2>/dev/null || xrandr -o left

cleanup() {
  /usr/local/bin/dreadwire-musicctl.py gameresume >/dev/null 2>&1 || true
}
trap cleanup EXIT

/opt/dreadwire/arena-brawl/arena-brawl.arm64 \
  --fullscreen \
  --rendering-method gl_compatibility \
  --rendering-driver opengl3
