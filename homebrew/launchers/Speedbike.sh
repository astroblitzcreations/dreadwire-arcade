#!/usr/bin/env bash
set -euo pipefail

/usr/local/bin/dreadwire-musicctl.py gamepause >/dev/null 2>&1 || true
trap '/usr/local/bin/dreadwire-musicctl.py gameresume >/dev/null 2>&1 || true' EXIT
sleep 0.4

exec sudo -E xinit /opt/dreadwire/speedbike/root-xclient.sh -- :0 vt1 \
  -keeptty -nolisten tcp -nocursor >>/tmp/speedbike-launch.log 2>&1
