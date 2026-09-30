#!/usr/bin/env bash
set -euo pipefail

# Display rotation belongs to the Pi KMS configuration, not this game. This
# keeps EmulationStation, RetroArch, Python games, and Godot in one orientation.
exec /opt/dreadwire/void-run/void-run.arm64 --fullscreen

