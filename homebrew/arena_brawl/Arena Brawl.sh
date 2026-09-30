#!/usr/bin/env bash
set -euo pipefail

/usr/local/bin/dreadwire-musicctl.py gamepause >/dev/null 2>&1 || true
export GODOT_AUDIO_DRIVER=ALSA
trap '/usr/local/bin/dreadwire-musicctl.py gameresume >/dev/null 2>&1 || true' EXIT
sleep 0.4
xinit /opt/dreadwire/arena-brawl/xclient.sh -- :0 -nolisten tcp -nocursor
