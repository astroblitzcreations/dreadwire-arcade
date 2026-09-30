#!/usr/bin/env python3
"""Joystick-friendly Players 1-4 assignment screen for the cabinet."""

import curses
import json
from pathlib import Path
import re
import subprocess

CONFIG = Path("/opt/retropie/configs/all/controller-assignments.json")
MANAGER = "/usr/local/bin/cabinet-controller-manager.py"
FALLBACK = "usb-DragonRise_Inc._Generic_USB_Joystick-joystick"


def detected():
    devices = {}
    nodes = set()
    by_id = Path("/dev/input/by-id")
    for link in sorted(by_id.glob("*-joystick")) if by_id.exists() else []:
        if "event-joystick" in link.name:
            continue
        try:
            node = link.resolve().name
            name = (Path("/sys/class/input") / node / "device/name").read_text().strip()
            if not name.startswith("Dreadwire Player"):
                devices[link.name] = name
                nodes.add(node)
        except OSError:
            pass
    for js in sorted(Path("/sys/class/input").glob("js*")):
        if js.name in nodes:
            continue
        try:
            name = (js / "device/name").read_text().strip()
            if name.startswith("Dreadwire Player"):
                continue
            try:
                unique = (js / "device/uniq").read_text().strip()
            except OSError:
                unique = ""
            stable = unique or re.sub(r"[^A-Za-z0-9_.-]+", "_", name).strip("_")
            devices[("bluetooth-" if unique else "gamepad-") + stable] = name
        except OSError:
            pass
    return devices


def load_assignments():
    defaults = {f"player{i}": FALLBACK if i == 1 else None for i in range(1, 5)}
    try:
        defaults.update(json.loads(CONFIG.read_text()))
    except (OSError, ValueError, TypeError):
        pass
    return defaults


def save_assignments(values):
    CONFIG.parent.mkdir(parents=True, exist_ok=True)
    temporary = CONFIG.with_suffix(".tmp")
    temporary.write_text(json.dumps(values, indent=2) + "\n")
    temporary.replace(CONFIG)
    subprocess.run([MANAGER, "--apply", "--quiet"], check=False)
    subprocess.run([MANAGER, "--generate-menu"], check=False)


def app(screen):
    curses.curs_set(0)
    screen.keypad(True)
    curses.start_color()
    curses.use_default_colors()
    curses.init_pair(1, curses.COLOR_CYAN, -1)
    curses.init_pair(2, curses.COLOR_BLACK, curses.COLOR_CYAN)
    curses.init_pair(3, curses.COLOR_YELLOW, -1)
    devices = detected()
    assignments = load_assignments()
    selected = 0
    message = "LEFT / RIGHT changes a controller"
    rows = ["PLAYER 1", "PLAYER 2", "PLAYER 3", "PLAYER 4", "SAVE SETTINGS", "CANCEL"]

    def choices(player):
        values = list(devices)
        return values if player == 1 else [None] + values

    while True:
        height, width = screen.getmaxyx()
        screen.erase()
        title = "DREADWIRE CONTROLLER ASSIGNMENT"
        screen.addstr(1, max(0, (width - len(title)) // 2), title, curses.color_pair(1) | curses.A_BOLD)
        screen.addstr(3, 3, "UP / DOWN: choose player     LEFT / RIGHT: cycle detected pads")
        screen.addstr(4, 3, "A / ENTER: select             Changes apply only after SAVE")
        for index, row in enumerate(rows):
            y = 7 + index * 3
            style = curses.color_pair(2) | curses.A_BOLD if index == selected else curses.A_BOLD
            if index < 4:
                identity = assignments[f"player{index + 1}"]
                label = devices.get(identity, "AUTOMATIC / UNASSIGNED" if identity is None else "DISCONNECTED")
                if identity == FALLBACK:
                    label += "  [CABINET]"
                text = f" {row:<10}  <  {label[:max(12, width - 31)]:<{max(12, width - 31)}}  > "
            else:
                text = f" {row} "
            screen.addstr(y, 5, text[:max(1, width - 10)], style)
        screen.addstr(min(height - 2, 27), 3, message[:max(1, width - 6)], curses.color_pair(3))
        screen.refresh()
        key = screen.getch()
        if key == curses.KEY_UP:
            selected = (selected - 1) % len(rows)
        elif key == curses.KEY_DOWN:
            selected = (selected + 1) % len(rows)
        elif key in (curses.KEY_LEFT, curses.KEY_RIGHT) and selected < 4:
            options = choices(selected + 1)
            current = assignments[f"player{selected + 1}"]
            position = options.index(current) if current in options else 0
            step = -1 if key == curses.KEY_LEFT else 1
            choice = options[(position + step) % len(options)]
            if choice:
                for player in range(1, 5):
                    if assignments[f"player{player}"] == choice:
                        assignments[f"player{player}"] = None
            assignments[f"player{selected + 1}"] = choice
            message = f"Player {selected + 1} pending: {devices.get(choice, 'Automatic / unassigned')}"
        elif key in (10, 13, curses.KEY_ENTER):
            if selected < 4:
                options = choices(selected + 1)
                current = assignments[f"player{selected + 1}"]
                position = options.index(current) if current in options else 0
                choice = options[(position + 1) % len(options)]
                if choice:
                    for player in range(1, 5):
                        if assignments[f"player{player}"] == choice:
                            assignments[f"player{player}"] = None
                assignments[f"player{selected + 1}"] = choice
            elif selected == 4:
                if not assignments["player1"]:
                    assignments["player1"] = FALLBACK
                save_assignments(assignments)
                return
            else:
                return
        elif key in (27, ord("q"), ord("Q")):
            return


if __name__ == "__main__":
    curses.wrapper(app)
