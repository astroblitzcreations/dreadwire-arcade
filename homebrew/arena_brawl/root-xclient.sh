#!/usr/bin/env bash
set -euo pipefail

# xinit/Xorg must own the cabinet VT, but Godot needs pi's Mesa, audio and
# profile environment. Authorize the local pi user, then discard root here.
xhost +SI:localuser:pi >/dev/null
exec runuser -u pi -- env \
  DISPLAY="${DISPLAY:-:0}" \
  HOME=/home/pi \
  USER=pi \
  LOGNAME=pi \
  XDG_RUNTIME_DIR=/run/user/1000 \
  GODOT_AUDIO_DRIVER=ALSA \
  /opt/dreadwire/arena-brawl/xclient.sh
