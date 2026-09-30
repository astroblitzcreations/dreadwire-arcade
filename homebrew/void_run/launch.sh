#!/usr/bin/env bash
set -euo pipefail

/usr/local/bin/dreadwire-musicctl.py gamepause >/dev/null 2>&1 || true
trap '/usr/local/bin/dreadwire-musicctl.py gameresume >/dev/null 2>&1 || true' EXIT
sleep 0.4

# Bookworm Xorg needs root for VT/DRM acquisition. The root client immediately
# drops back to pi before starting the game.
exec sudo -E xinit /opt/dreadwire/void-run/root-xclient.sh -- :0 vt1 \
  -keeptty -nolisten tcp -nocursor >>/tmp/void-run-launch.log 2>&1
