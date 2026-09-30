#!/usr/bin/env bash
set -euo pipefail
export GODOT_AUDIO_DRIVER=ALSA
/usr/local/bin/dreadwire-musicctl.py gamepause >/dev/null 2>&1 || true
trap '/usr/local/bin/dreadwire-musicctl.py gameresume >/dev/null 2>&1 || true' EXIT
sleep 0.35
xinit /opt/dreadwire/goldmaze/xclient.sh -- :0 -nolisten tcp -nocursor

