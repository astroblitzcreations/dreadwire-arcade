#!/usr/bin/env python3
"""Send a command to the Dreadwire cabinet jukebox."""

import socket
import sys

SOCKET_PATH = "/run/dreadwire-music/control.sock"
command = sys.argv[1] if len(sys.argv) > 1 else "status"
with socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM) as control:
    control.connect(SOCKET_PATH)
    control.send(command.encode("utf-8"))
