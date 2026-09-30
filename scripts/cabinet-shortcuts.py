#!/usr/bin/env python3
"""Two-button safety shortcuts for the Raspberry Pi arcade cabinet."""

import os
import select
import socket
import struct
import subprocess
import threading
import time

DEVICE = "/dev/input/by-id/usb-DragonRise_Inc._Generic_USB_Joystick-event-joystick"
EV_KEY = 1
START = 295  # joystick button 7
LEFT_SIDE = 297  # joystick button 9 / BTN_BASE4
ARM_SECONDS = 3.0
REBOOT_SECONDS = 8.0
ARM_TIMEOUT = 10.0
SIMULTANEOUS_WINDOW = 0.45
EVENT = struct.Struct("llHHI")


def log(message):
    print(message, flush=True)


def run(*command):
    log("running: " + " ".join(command))
    subprocess.run(command, check=False)


def retroarch(command):
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as sock:
        sock.sendto((command + "\n").encode(), ("127.0.0.1", 55355))


def temperature_overlay():
    """Show a small temperature notification while RetroArch is running."""
    time.sleep(15)
    while True:
        try:
            with open("/sys/class/thermal/thermal_zone0/temp", encoding="ascii") as source:
                celsius = int(source.read().strip()) / 1000.0
            fahrenheit = celsius * 9.0 / 5.0 + 32.0
            if subprocess.run(
                ["pgrep", "-x", "retroarch"],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                check=False,
            ).returncode == 0:
                retroarch(f"SHOW_MSG CPU: {celsius:.0f} C / {fahrenheit:.0f} F")
        except (OSError, ValueError) as exc:
            log("temperature unavailable: " + str(exc))
        time.sleep(60)


def perform(action):
    if action == "start":
        run("pkill", "-KILL", "-x", "retroarch")
    elif action == "left":
        log("resetting current game")
        retroarch("RESET")
    elif action == "both":
        run("pkill", "-KILL", "-x", "retroarch")
        run("systemctl", "restart", "getty@tty1.service")


def monitor(fd):
    pressed = {START: False, LEFT_SIDE: False}
    chord_since = None
    primed = False
    rebooted = False
    armed_until = 0.0
    pending_since = None

    while True:
        now = time.monotonic()
        ready, _, _ = select.select([fd], [], [], 0.05)
        if ready:
            data = os.read(fd, EVENT.size * 32)
            for offset in range(0, len(data) - EVENT.size + 1, EVENT.size):
                _, _, event_type, code, value = EVENT.unpack_from(data, offset)
                if event_type != EV_KEY or code not in pressed or value == 2:
                    continue
                pressed[code] = bool(value)
                now = time.monotonic()

                if armed_until > now and value == 1 and pending_since is None:
                    pending_since = now

        now = time.monotonic()
        both = pressed[START] and pressed[LEFT_SIDE]

        if armed_until <= now:
            armed_until = 0.0
            pending_since = None
            if both:
                if chord_since is None:
                    chord_since = now
                    primed = False
                    rebooted = False
                held = now - chord_since
                if held >= ARM_SECONDS and not primed:
                    primed = True
                    log("shortcut mode primed; release both buttons to arm")
                if held >= REBOOT_SECONDS and not rebooted:
                    rebooted = True
                    log("eight-second chord: rebooting cleanly")
                    run("systemctl", "reboot")
                    return
            elif chord_since is not None:
                if primed and not rebooted:
                    armed_until = now + ARM_TIMEOUT
                    log("shortcut mode armed for ten seconds")
                chord_since = None
                primed = False
        elif pending_since is not None:
            if both:
                action = "both"
            elif now - pending_since < SIMULTANEOUS_WINDOW:
                continue
            elif pressed[START]:
                action = "start"
            elif pressed[LEFT_SIDE]:
                action = "left"
            else:
                pending_since = None
                continue
            armed_until = 0.0
            pending_since = None
            perform(action)


def main():
    threading.Thread(target=temperature_overlay, daemon=True).start()
    while True:
        try:
            log("waiting for cabinet controller: " + DEVICE)
            with open(DEVICE, "rb", buffering=0) as device:
                log("cabinet controller connected")
                monitor(device.fileno())
        except (FileNotFoundError, OSError) as exc:
            log("controller unavailable: " + str(exc))
            time.sleep(2)


if __name__ == "__main__":
    main()
