#!/usr/bin/env bash
set -euo pipefail

/usr/local/bin/dreadwire-musicctl.py gamepause >/dev/null 2>&1 || true
# Remove only orphaned cabinet-jukebox players; never touch game audio or an
# unrelated user media player.
pkill -TERM -f '/home/pi/Music/dreadwire-arcade/' >/dev/null 2>&1 || true
# EmulationStation's animated theme otherwise continues rendering underneath
# this separate X session and steals CPU/GPU time from the game.
pkill -STOP -f '^/opt/retropie/supplementary/emulationstation/emulationstation ' >/dev/null 2>&1 || true
# Menu music uses direct ALSA while Godot is routed through PipeWire. A prior
# system mute must not leave the game stream silent after the jukebox exits.
pactl set-sink-mute @DEFAULT_SINK@ 0 >/dev/null 2>&1 || true
xrandr --output HDMI-1 --mode 1024x768 --rotate left --pos 0x0 --brightness 1.12 2>/dev/null || xrandr -o left
# A gamepad produces no keyboard/mouse activity, so X11 otherwise decides the
# cabinet is idle and powers the monitor off after ten minutes mid-game.
xset s off
xset s noblank
xset -dpms

cleanup() {
  pkill -CONT -f '^/opt/retropie/supplementary/emulationstation/emulationstation ' >/dev/null 2>&1 || true
  /usr/local/bin/dreadwire-musicctl.py gameresume >/dev/null 2>&1 || true
}
trap cleanup EXIT

game_binary=/opt/dreadwire/arena-brawl/arena-brawl.arm64
# New builds are staged beside the live executable.  A running game keeps its
# current process; only the next launch reads this script and selects the staged
# build, so an active cabinet session is never interrupted by an upgrade.
if [[ -x /opt/dreadwire/arena-brawl/arena-brawl.next.arm64 ]]; then
  game_binary=/opt/dreadwire/arena-brawl/arena-brawl.next.arm64
fi

"$game_binary" \
  --fullscreen \
  --rendering-method gl_compatibility \
  --rendering-driver opengl3
