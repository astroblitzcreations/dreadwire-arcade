#!/usr/bin/env bash
set -u

clear
sudo /opt/dreadwire/tools/install-python-tools.sh
status=$?
echo
if [[ ${status} -eq 0 ]]; then
  echo "Installation complete. Press any cabinet button or Enter to return."
else
  echo "Installation failed (usually no network yet). Press Enter to return."
fi
read -r _
exit "${status}"

