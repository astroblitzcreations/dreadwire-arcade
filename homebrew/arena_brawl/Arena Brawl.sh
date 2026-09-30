#!/usr/bin/env bash
set -euo pipefail

/usr/local/bin/dreadwire-musicctl.py gamepause >/dev/null 2>&1 || true
export GODOT_AUDIO_DRIVER=ALSA
trap '/usr/local/bin/dreadwire-musicctl.py gameresume >/dev/null 2>&1 || true' EXIT
sleep 0.4
# Bookworm's Xorg binary no longer has the setuid wrapper. Start only the X
# server bootstrap as root, then immediately drop the game back to user pi in
# root-xclient.sh. This grants VT/DRM access without running Godot as root.
# EmulationStation already released tty1 for runcommand.  Pin Xorg to that
# same VT; allowing xinit to auto-pick tty2 can leave EmulationStation as DRM
# master and makes Xorg abort with "drmSetMaster failed: Device or resource
# busy" before Godot gets a window.
exec sudo -E xinit /opt/dreadwire/arena-brawl/root-xclient.sh -- :0 vt1 -keeptty -nolisten tcp -nocursor \
  >>/tmp/arena-brawl-launch.log 2>&1
