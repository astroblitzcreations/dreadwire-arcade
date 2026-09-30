#!/usr/bin/env bash
set -euo pipefail
/usr/local/bin/dreadwire-musicctl.py gamepause >/dev/null 2>&1 || true
xrandr --output HDMI-1 --mode 1024x768 --rotate left --pos 0x0 --brightness 1.12 2>/dev/null || xrandr -o left
cleanup() { /usr/local/bin/dreadwire-musicctl.py gameresume >/dev/null 2>&1 || true; }
trap cleanup EXIT
/opt/dreadwire/goldmaze/goldmaze.arm64 --fullscreen --rendering-method gl_compatibility --rendering-driver opengl3
