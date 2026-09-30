#!/usr/bin/env bash
set -euo pipefail

if ! command -v python3 >/dev/null || ! python3 -c 'import pygame' 2>/dev/null; then
  clear
  echo "Run 'Install Python Game Tools' first."
  read -r _
  exit 1
fi
exec python3 /opt/dreadwire/tools/controller-test.py

