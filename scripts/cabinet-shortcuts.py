#!/usr/bin/env python3
"""Two-button safety shortcuts for the Raspberry Pi arcade cabinet."""

import os
import fcntl
import select
import socket
import struct
import subprocess
import threading
import time

DEVICE = "/dev/input/by-id/usb-DragonRise_Inc._Generic_USB_Joystick-event-joystick"
EV_KEY = 1
START = 295  # joystick button 7
SELECT = 293  # joystick button 5
LEFT_SIDE = 297  # joystick button 9 / BTN_BASE4
RIGHT_SIDE = 296  # joystick button 8 / BTN_BASE3
ARM_SECONDS = 3.0
GAME_EXIT_SECONDS = 3.0
PARTY_QR_SECONDS = 2.0
REBOOT_SECONDS = 8.0
ARM_TIMEOUT = 10.0
SIMULTANEOUS_WINDOW = 0.45
FLIPPER_REPEAT_DELAY = 0.55
FLIPPER_REPEAT_SECONDS = 0.22
EVENT = struct.Struct("llHHI")
KEY_BITMAP_BYTES = 96
EVIOCGKEY = (2 << 30) | (KEY_BITMAP_BYTES << 16) | (ord("E") << 8) | 0x18
overlay_process = None
volume_mode = False


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
    if action == "game_exit":
        log("start + select held: exiting current game")
        run("pkill", "-TERM", "-x", "retroarch")
    elif action == "start":
        run("pkill", "-KILL", "-x", "retroarch")
    elif action == "left":
        log("resetting current game")
        retroarch("RESET")
    elif action == "both":
        run("pkill", "-KILL", "-x", "retroarch")
        run("systemctl", "restart", "getty@tty1.service")


def emulationstation_has_focus():
    """True only while browsing ES, never while a launched game owns it."""
    if subprocess.run(
        ["pgrep", "-f", "/opt/retropie/supplementary/emulationstation/emulationstation"],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False,
    ).returncode != 0:
        return False
    game_patterns = [
        "runcommand.sh", "retroarch", "arena-brawl", "speedbike", "goldmaze",
        "void_run", "mupen64plus", "ppsspp", "dolphin-emu", "dosbox", "scummvm",
    ]
    for pattern in game_patterns:
        if subprocess.run(
            ["pgrep", "-f", pattern],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False,
        ).returncode == 0:
            return False
    return True


def adjust_menu_music(command):
    """Change only jukebox gain; game/master volume remains untouched."""
    run("/usr/local/bin/dreadwire-musicctl.py", command)
    log("EmulationStation flipper: jukebox " + command)


def key_is_down(fd, code):
    """Read the controller's real key state, recovering missed releases."""
    bitmap = bytearray(KEY_BITMAP_BYTES)
    try:
        fcntl.ioctl(fd, EVIOCGKEY, bitmap, True)
    except OSError:
        return False
    return bool(bitmap[code // 8] & (1 << (code % 8)))


def pipewire(*arguments, capture=False):
    command = [
        "runuser", "-u", "pi", "--", "env", "XDG_RUNTIME_DIR=/run/user/1000",
        "pactl", *arguments,
    ]
    if capture:
        return subprocess.check_output(command, text=True, stderr=subprocess.DEVNULL)
    run(*command)


def current_volume():
    try:
        output = pipewire("get-sink-volume", "@DEFAULT_SINK@", capture=True)
        return int(output.split("%", 1)[0].rsplit(None, 1)[-1])
    except (OSError, subprocess.SubprocessError, ValueError, IndexError):
        return 100


def set_volume(percent):
    percent = max(0, min(150, percent))
    pipewire("set-sink-mute", "@DEFAULT_SINK@", "0")
    pipewire("set-sink-volume", "@DEFAULT_SINK@", f"{percent}%")
    show_volume_overlay(percent)
    log(f"cabinet volume set to {percent}%")
    return percent


def show_volume_overlay(percent=None):
    global overlay_process, volume_mode
    close_overlay()
    volume_mode = True
    if percent is None:
        percent = current_volume()
    overlay_process = subprocess.Popen(
        ["/usr/local/bin/dreadwire-volume-overlay", str(percent)],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def close_overlay():
    global overlay_process
    if overlay_process and overlay_process.poll() is None:
        overlay_process.terminate()
        try:
            overlay_process.wait(timeout=2)
        except subprocess.TimeoutExpired:
            overlay_process.kill()
    overlay_process = None


def show_party_overlay():
    global overlay_process, volume_mode
    close_overlay()
    volume_mode = False
    overlay_process = subprocess.Popen(
        ["/usr/local/bin/dreadwire-party-overlay"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    log("party QR overlay opened; next cabinet button closes it")


def close_party_overlay():
    global overlay_process, volume_mode
    if volume_mode:
        return False
    if overlay_process and overlay_process.poll() is None:
        overlay_process.terminate()
        try: overlay_process.wait(timeout=2)
        except subprocess.TimeoutExpired: overlay_process.kill()
        overlay_process = None
        log("party QR overlay closed")
        return True
    overlay_process = None
    return False


def monitor(fd):
    global volume_mode
    pressed = {START: False, SELECT: False, LEFT_SIDE: False, RIGHT_SIDE: False}
    chord_since = None
    game_exit_since = None
    game_exit_fired = False
    primed = False
    rebooted = False
    armed_until = 0.0
    pending_since = None
    volume = current_volume()
    flipper_held = {LEFT_SIDE: False, RIGHT_SIDE: False}
    flipper_next = {LEFT_SIDE: 0.0, RIGHT_SIDE: 0.0}

    while True:
        now = time.monotonic()
        if volume_mode and armed_until and armed_until <= now:
            close_overlay()
            volume_mode = False
        ready, _, _ = select.select([fd], [], [], 0.05)
        if ready:
            data = os.read(fd, EVENT.size * 32)
            for offset in range(0, len(data) - EVENT.size + 1, EVENT.size):
                _, _, event_type, code, value = EVENT.unpack_from(data, offset)
                if event_type != EV_KEY or value == 2:
                    continue
                if value == 1 and close_party_overlay():
                    continue
                if code in (LEFT_SIDE, RIGHT_SIDE):
                    if value == 0:
                        flipper_held[code] = False
                        if emulationstation_has_focus():
                            pressed[code] = False
                            continue
                    elif value == 1 and emulationstation_has_focus():
                        pressed[code] = False
                        adjust_menu_music("volumedown" if code == LEFT_SIDE else "volumeup")
                        flipper_held[code] = True
                        flipper_next[code] = time.monotonic() + FLIPPER_REPEAT_DELAY
                        # Consume the cabinet shortcut internally. Games still
                        # receive these buttons normally; only ES uses them as
                        # hold-to-repeat jukebox volume controls.
                        continue
                if code not in pressed:
                    continue
                pressed[code] = bool(value)
                now = time.monotonic()

                if armed_until > now and value == 1 and pending_since is None:
                    pending_since = now

        now = time.monotonic()
        for code in (LEFT_SIDE, RIGHT_SIDE):
            if flipper_held[code] and now >= flipper_next[code]:
                if not key_is_down(fd, code):
                    flipper_held[code] = False
                    pressed[code] = False
                elif emulationstation_has_focus():
                    adjust_menu_music("volumedown" if code == LEFT_SIDE else "volumeup")
                    flipper_next[code] = now + FLIPPER_REPEAT_SECONDS
                else:
                    flipper_held[code] = False

        game_exit_combo = pressed[START] and pressed[SELECT]
        if game_exit_combo:
            if game_exit_since is None:
                game_exit_since = now
                game_exit_fired = False
            elif now - game_exit_since >= GAME_EXIT_SECONDS and not game_exit_fired:
                game_exit_fired = True
                perform("game_exit")
        else:
            game_exit_since = None
            game_exit_fired = False

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
                held = now - chord_since
                if primed and not rebooted:
                    armed_until = now + ARM_TIMEOUT
                    volume = current_volume()
                    show_volume_overlay(volume)
                    log("shortcut mode armed for ten seconds")
                elif held >= PARTY_QR_SECONDS and not rebooted:
                    show_party_overlay()
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
            if volume_mode and action == "start":
                volume = set_volume(volume + 10)
                armed_until = now + ARM_TIMEOUT
            elif volume_mode and action == "left":
                volume = set_volume(volume - 10)
                armed_until = now + ARM_TIMEOUT
            else:
                close_overlay()
                volume_mode = False
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
