#!/usr/bin/env bash
set -euo pipefail
library=/opt/dreadwire/collections/library.tsv
if [[ ! -s "$library" ]]; then
  /usr/local/bin/generate-arcade-collections.py
fi
IFS=$'\t' read -r system rom < <(shuf -n 1 "$library")
exec /opt/retropie/supplementary/runcommand/runcommand.sh 0 _SYS_ "$system" "$rom"
