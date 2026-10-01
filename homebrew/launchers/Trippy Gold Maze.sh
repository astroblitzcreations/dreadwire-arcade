#!/usr/bin/env bash
set -euo pipefail
/usr/local/bin/dreadwire-musicctl.py gamepause >/dev/null 2>&1 || true
trap '/usr/local/bin/dreadwire-musicctl.py gameresume >/dev/null 2>&1 || true' EXIT
sleep 0.4

# Bookworm requires Xorg to acquire the cabinet VT as root. The X client
# immediately drops back to pi, so the game and its save data never run root.
exec sudo -E xinit /opt/dreadwire/goldmaze/root-xclient.sh -- :0 vt1 \
  -keeptty -nolisten tcp -nocursor >>/tmp/goldmaze-launch.log 2>&1
