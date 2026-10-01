#!/usr/bin/env bash
set -euo pipefail

xhost +SI:localuser:pi >/dev/null
exec runuser -u pi -- env \
  DISPLAY="${DISPLAY:-:0}" \
  HOME=/home/pi \
  USER=pi \
  LOGNAME=pi \
  XDG_RUNTIME_DIR=/run/user/1000 \
  GODOT_AUDIO_DRIVER=ALSA \
  /opt/dreadwire/speedbike/xclient.sh
