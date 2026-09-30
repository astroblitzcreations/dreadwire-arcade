#!/usr/bin/env bash
set -e
sudo /usr/local/bin/cabinet-controller-manager.py --generate-menu
sudo systemctl restart getty@tty1.service
